-- Function untuk Menghitung Keseimbangan Total Debit dan Total Kredit Per Transaksi
CREATE OR REPLACE FUNCTION fn_check_journal_balance()
RETURNS TRIGGER AS $$
DECLARE
    v_total_debit  NUMERIC(18,2);
    v_total_credit NUMERIC(18,2);
    v_line_count   INTEGER;
BEGIN
    -- Menghitung total debit, kredit, dan jumlah baris untuk header transaksi terkait
    SELECT COALESCE(SUM(debit), 0), COALESCE(SUM(credit), 0), COUNT(*)
    INTO v_total_debit, v_total_credit, v_line_count
    FROM journal_lines
    WHERE header_id = NEW.header_id;

    -- Validasi 1: Total Debit harus sama dengan Total Kredit (Zero Discrepancy)
    IF v_total_debit <> v_total_credit THEN
        RAISE EXCEPTION 'Transaksi ID % tidak seimbang: Total Debit (Rp %) != Total Kredit (Rp %)',
            NEW.header_id, v_total_debit, v_total_credit;
    END IF;

    -- Validasi 2: Minimal terdiri dari 2 baris rincian (Asas Berpasangan)
    IF v_line_count < 2 THEN
        RAISE EXCEPTION 'Transaksi ID % ditolak: Jurnal minimal harus memiliki 2 baris (Debit & Kredit)',
            NEW.header_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Constraint Trigger yang Ditunda Pengecekannya Sampai Perintah COMMIT
CREATE CONSTRAINT TRIGGER trg_check_journal_balance
AFTER INSERT OR UPDATE ON journal_lines
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION fn_check_journal_balance();
