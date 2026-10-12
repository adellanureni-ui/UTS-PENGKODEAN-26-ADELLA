-- =============================================================================
-- FUNCTION & TRIGGER: MUTASI STOK & JURNAL PERSEDIAAN/HPP OTOMATIS
-- =============================================================================

CREATE OR REPLACE FUNCTION fn_update_stock_and_journal()
RETURNS TRIGGER AS $$
DECLARE
    v_item         inventory_items%ROWTYPE;
    v_delta        INTEGER;
    v_new_stock    INTEGER;
    v_total_amount NUMERIC(18,2);
    v_header_id    BIGINT;
    v_account_inv  INTEGER; -- 1301: Persediaan Barang Dagang
    v_account_hpp  INTEGER; -- 5101: Beban Pokok Pendapatan / HPP
    v_account_ap   INTEGER; -- 2101: Utang Usaha
    v_account_adj  INTEGER; -- 5901/4901: Beban/Pendapatan Selisih
BEGIN
    -- Step 1: Validasi Nilai Kuantitas Transaksi
    IF NEW.trx_type IN ('PURCHASE', 'SALE') AND NEW.qty <= 0 THEN
        RAISE EXCEPTION 'Transaksi % ditolak: Kuantitas harus bernilai positif (> 0). Input: %',
            NEW.trx_type, NEW.qty;
    END IF;

    IF NEW.trx_type = 'ADJUSTMENT' AND NEW.qty = 0 THEN
        RAISE EXCEPTION 'Transaksi ADJUSTMENT ditolak: Kuantitas tidak boleh nol.';
    END IF;

    -- Step 2: Penguncian Baris Barang (Pessimistic Locking) & Ambil Data Item
    SELECT * INTO v_item
    FROM inventory_items
    WHERE item_id = NEW.item_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Barang dengan Kode % tidak ditemukan di Master Persediaan.', NEW.item_id;
    END IF;

    -- Step 3: Hitung Perubahan Stok (Delta) Berdasarkan Tipe Transaksi
    v_delta := CASE NEW.trx_type
        WHEN 'PURCHASE'   THEN NEW.qty
        WHEN 'SALE'       THEN -NEW.qty
        WHEN 'ADJUSTMENT' THEN NEW.qty
    END;

    v_new_stock := v_item.stock_qty + v_delta;

    -- Step 4: Proteksi Anti-Negative Inventory
    IF v_new_stock < 0 THEN
        RAISE EXCEPTION 'Transaksi % DITOLAK: Stok barang % (%) tidak mencukupi. Saldo saat ini: % unit, diminta: % unit.',
            NEW.trx_type, v_item.item_name, v_item.item_id, v_item.stock_qty, ABS(v_delta);
    END IF;

    -- Step 5: Update Stok Fisik di Master Persediaan
    UPDATE inventory_items
    SET stock_qty = v_new_stock
    WHERE item_id = NEW.item_id;

    -- Step 6: Otomasi Pembentukan Jurnal Umum di Buku Besar (GL)
    v_total_amount := ABS(NEW.qty) * v_item.unit_cost;

    -- Ambil ID Akun dari Bagan Akun (Chart of Accounts)
    SELECT account_id INTO v_account_inv FROM chart_of_accounts WHERE account_code = '1301';
    SELECT account_id INTO v_account_hpp FROM chart_of_accounts WHERE account_code = '5101';
    SELECT account_id INTO v_account_ap  FROM chart_of_accounts WHERE account_code = '2101';
    SELECT account_id INTO v_account_adj FROM chart_of_accounts WHERE account_code = '5901';

    -- Buat Header Jurnal (journal_headers)
    INSERT INTO journal_headers (transaction_date, reference_no, description, posting_status)
    VALUES (
        NEW.trx_date,
        'INV-TRX-' || TO_CHAR(CURRENT_TIMESTAMP, 'YYYYMMDDHH24MISSMS'),
        'Jurnal Otomatis Mutasi Persediaan (' || NEW.trx_type || ') - ' || v_item.item_name,
        'POSTED'
    )
    RETURNING id INTO v_header_id;

    -- Rincian Baris Jurnal (journal_lines) Sesuai Jenis Transaksi
    IF NEW.trx_type = 'PURCHASE' THEN
        -- Debit: Persediaan Barang Dagang (1301), Kredit: Utang Usaha (2101)
        INSERT INTO journal_lines (header_id, account_id, debit, credit) VALUES
            (v_header_id, v_account_inv, v_total_amount, 0),
            (v_header_id, v_account_ap,  0, v_total_amount);

    ELSIF NEW.trx_type = 'SALE' THEN
        -- Debit: Beban Pokok Pendapatan / HPP (5101), Kredit: Persediaan Barang Dagang (1301)
        INSERT INTO journal_lines (header_id, account_id, debit, credit) VALUES
            (v_header_id, v_account_hpp, v_total_amount, 0),
            (v_header_id, v_account_inv, 0, v_total_amount);

    ELSIF NEW.trx_type = 'ADJUSTMENT' THEN
        IF NEW.qty > 0 THEN
            -- Penyesuaian Positif: Debit Persediaan (1301), Kredit Pendapatan Selisih
            INSERT INTO journal_lines (header_id, account_id, debit, credit) VALUES
                (v_header_id, v_account_inv, v_total_amount, 0),
                (v_header_id, v_account_adj, 0, v_total_amount);
        ELSE
            -- Penyesuaian Negatif (Rusak/Hilang): Debit Beban Selisih (5901), Kredit Persediaan (1301)
            INSERT INTO journal_lines (header_id, account_id, debit, credit) VALUES
                (v_header_id, v_account_adj, v_total_amount, 0),
                (v_header_id, v_account_inv, 0, v_total_amount);
        END IF;
    END IF;

    -- Tautkan ID Header Jurnal ke Transaksi Persediaan
    NEW.journal_header_id := v_header_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- TRIGGER BEFORE INSERT ON INVENTORY_TRANSACTIONS
CREATE TRIGGER trg_update_stock_and_journal
BEFORE INSERT ON inventory_transactions
FOR EACH ROW
EXECUTE FUNCTION fn_update_stock_and_journal();
