-- =============================================================================
-- SOAL 3.2: DDL AUDIT TRAIL, SHA-256 HASH CHAIN, & TRIGGER IMMUTABILITY
-- Berkas Repositori GitHub: soal3/supabase/01_audit_trail_immutability.sql
-- =============================================================================

-- Enable extension pgcrypto untuk fungsi digest/SHA-256
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 1. EXTEND TABEL JOURNAL HEADERS DENGAN KOLOM AUDIT
ALTER TABLE journal_headers 
    ADD COLUMN IF NOT EXISTS created_by      VARCHAR(100) DEFAULT 'SYSTEM',
    ADD COLUMN IF NOT EXISTS created_at      TIMESTAMPTZ  DEFAULT now(),
    ADD COLUMN IF NOT EXISTS posted_by       VARCHAR(100),
    ADD COLUMN IF NOT EXISTS posted_at       TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS hash_checksum   VARCHAR(64),
    ADD COLUMN IF NOT EXISTS prev_hash       VARCHAR(64),
    ADD COLUMN IF NOT EXISTS reversal_of     BIGINT UNIQUE REFERENCES journal_headers(id);

-- 2. TABEL AUDIT LOG (APPEND-ONLY)
CREATE TABLE IF NOT EXISTS audit_log (
    log_id      BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    table_name  VARCHAR(50)  NOT NULL,
    action_type VARCHAR(10)  NOT NULL,
    record_id   BIGINT       NOT NULL,
    actor_email VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
    performed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    old_data    JSONB,
    new_data    JSONB
);

-- Protect Audit Log agar bersifat Append-Only
CREATE OR REPLACE FUNCTION fn_prevent_audit_log_tamper()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'Tabel audit_log bersifat Append-Only: UPDATE/DELETE/TRUNCATE DITOLAK!';
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_protect_audit_log
BEFORE UPDATE OR DELETE ON audit_log
FOR EACH ROW EXECUTE FUNCTION fn_prevent_audit_log_tamper();


-- 3. FUNGSI PENGHITUNG SHA-256 HASH CHAIN
CREATE OR REPLACE FUNCTION fn_calculate_journal_hash(p_header_id BIGINT)
RETURNS VARCHAR(64) AS $$
DECLARE
    v_header_text TEXT;
    v_lines_text  TEXT;
    v_prev_hash   VARCHAR(64);
    v_combined    TEXT;
BEGIN
    -- Ambil data header
    SELECT 
        id || '|' || transaction_date || '|' || reference_no || '|' || 
        COALESCE(description,'') || '|' || posting_status || '|' || 
        COALESCE(created_by,'') || '|' || TO_CHAR(created_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:[link mencurigakan dihapus]"Z"')
    INTO v_header_text
    FROM journal_headers WHERE id = p_header_id;

    -- Ambil dan urutkan seluruh baris detail jurnal
    SELECT COALESCE(STRING_AGG(account_id || ':' || debit || ':' || credit, ';' ORDER BY id), '')
    INTO v_lines_text
    FROM journal_lines WHERE header_id = p_header_id;

    -- Ambil hash_checksum transaksi POSTED sebelumnya
    SELECT COALESCE(hash_checksum, 'GENESIS_HASH_ROOT_0000000000000000000000000000000000000000000')
    INTO v_prev_hash
    FROM journal_headers
    WHERE posting_status = 'POSTED' AND id < p_header_id
    ORDER BY id DESC LIMIT 1;

    -- Gabungkan data menjadi string kanonis
    v_combined := v_header_text || '|' || v_lines_text || '|' || v_prev_hash;

    -- Return SHA-256 Hex Digest
    RETURN encode(digest(v_combined, 'sha256'), 'hex');
END;
$$ LANGUAGE plpgsql;


-- 4. TRIGGER IMMUTABILITY: MENOLAK UPDATE & DELETE PADA JURNAL POSTED
CREATE OR REPLACE FUNCTION fn_enforce_journal_immutability()
RETURNS TRIGGER AS $$
BEGIN
    -- Jika transaksi lama berstatus POSTED, tolak UPDATE dan DELETE
    IF TG_OP = 'DELETE' THEN
        IF OLD.posting_status = 'POSTED' THEN
            RAISE EXCEPTION 'Jurnal ID % (%) sudah POSTED dan bersifat FINAL: DELETE DITOLAK! Gunakan storno (rpc_reverse_journal).',
                [link mencurigakan dihapus], OLD.reference_no;
        END IF;
        RETURN OLD;
    ELSIF TG_OP = 'UPDATE' THEN
        IF OLD.posting_status = 'POSTED' THEN
            RAISE EXCEPTION 'Jurnal ID % (%) sudah POSTED dan bersifat FINAL: UPDATE DITOLAK! Gunakan storno (rpc_reverse_journal).',
                [link mencurigakan dihapus], OLD.reference_no;
        END IF;
        RETURN NEW;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_journal_headers_immutable
BEFORE UPDATE OR DELETE ON journal_headers
FOR EACH ROW EXECUTE FUNCTION fn_enforce_journal_immutability();


-- 5. TRIGGER PROTEKSI BARIS JURNAL (JOURNAL_LINES IMMUTABILITY)
CREATE OR REPLACE FUNCTION fn_enforce_lines_immutability()
RETURNS TRIGGER AS $$
DECLARE
    v_status VARCHAR(20);
BEGIN
    IF TG_OP = 'DELETE' THEN
        SELECT posting_status INTO v_status FROM journal_headers WHERE id = OLD.header_id;
        IF v_status = 'POSTED' THEN
            RAISE EXCEPTION 'Baris detail milik Jurnal ID % yang sudah POSTED tidak dapat DIHAPUS!', OLD.header_id;
        END IF;
        RETURN OLD;
    ELSIF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        SELECT posting_status INTO v_status FROM journal_headers WHERE id = NEW.header_id;
        IF v_status = 'POSTED' THEN
            RAISE EXCEPTION 'Jurnal ID % sudah POSTED: Penambahan/Perubahan baris detail DITOLAK!', NEW.header_id;
        END IF;
        RETURN NEW;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_journal_lines_immutable
BEFORE INSERT OR UPDATE OR DELETE ON journal_lines
FOR EACH ROW EXECUTE FUNCTION fn_enforce_lines_immutability();


-- 6. TRIGGER LARANGAN TRUNCATE
CREATE OR REPLACE FUNCTION fn_prevent_truncate()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'TRUNCATE dilarang demi menjaga keutuhan jejak audit!';
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_no_truncate_headers BEFORE TRUNCATE ON journal_headers FOR EACH STATEMENT EXECUTE FUNCTION fn_prevent_truncate();
CREATE TRIGGER trg_no_truncate_lines   BEFORE TRUNCATE ON journal_lines   FOR EACH STATEMENT EXECUTE FUNCTION fn_prevent_truncate();
