-- Fungsi Khusus Transfer Internal Kas/Setara Kas
CREATE OR REPLACE FUNCTION rpc_create_cash_transfer(
    p_trx_date DATE,
    p_ref_no VARCHAR,
    p_description TEXT,
    p_from_account_id INTEGER, -- Akun Sumber (Kredit)
    p_to_account_id INTEGER,   -- Akun Tujuan (Debit)
    p_amount NUMERIC
) RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    v_header_id BIGINT;
    v_is_from_cash BOOLEAN;
    v_is_to_cash BOOLEAN;
BEGIN
    -- Validasi Kedua Akun Harus Berklasifikasi KAS atau SETARA_KAS
    SELECT (report_classification IN ('KAS', 'SETARA_KAS')) INTO v_is_from_cash 
    FROM chart_of_accounts WHERE account_id = p_from_account_id;
    
    SELECT (report_classification IN ('KAS', 'SETARA_KAS')) INTO v_to_cash 
    FROM chart_of_accounts WHERE account_id = p_to_account_id;

    IF NOT (v_is_from_cash AND v_is_to_cash) THEN
        RAISE EXCEPTION 'Mutasi kas internal hanya diizinkan antar akun KAS/SETARA_KAS (PSAK 207).';
    END IF;

    -- Simpan Jurnal dengan Jenis 'MUTASI_KAS' (Dikecualikan dari Laporan Arus Kas)
    INSERT INTO journal_headers (transaction_date, reference_no, description, journal_type, posting_status)
    VALUES (p_trx_date, p_ref_no, p_description, 'MUTASI_KAS', 'POSTED')
    RETURNING id INTO v_header_id;

    INSERT INTO journal_lines (header_id, account_id, debit, credit) VALUES
        (v_header_id, p_to_account_id, p_amount, 0),        -- Debit Akun Tujuan
        (v_header_id, p_from_account_id, 0, p_amount);       -- Kredit Akun Sumber

    RETURN jsonb_build_object('status', 'SUCCESS', 'header_id', v_header_id);
END;
$$;
