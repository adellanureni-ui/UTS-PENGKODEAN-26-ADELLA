-- 1. Aktifkan Row Level Security (RLS) pada Seluruh Tabel Utama
ALTER TABLE chart_of_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE journal_headers   ENABLE ROW LEVEL SECURITY;
ALTER TABLE journal_lines     ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_log         ENABLE ROW LEVEL SECURITY;

-- 2. Cabut (REVOKE) Hak Akses Tulis Langsung dari Role Anon dan Authenticated
REVOKE INSERT, UPDATE, DELETE ON journal_headers FROM anon, authenticated;
REVOKE INSERT, UPDATE, DELETE ON journal_lines   FROM anon, authenticated;
REVOKE INSERT, UPDATE, DELETE ON audit_log       FROM anon, authenticated;

-- 3. Berikan Hak Akses Baca (SELECT) yang Dibatasi
CREATE POLICY pol_select_journal_headers ON journal_headers FOR SELECT TO authenticated USING (true);
CREATE POLICY pol_select_journal_lines   ON journal_lines   FOR SELECT TO authenticated USING (true);

-- 4. Berikan Hak Eksekusi Hanya pada Fungsi RPC (Encapsulated Entry Points)
GRANT EXECUTE ON FUNCTION rpc_create_cash_voucher TO authenticated;
GRANT EXECUTE ON FUNCTION rpc_reverse_journal     TO authenticated;
GRANT EXECUTE ON FUNCTION rpc_verify_journal_integrity TO authenticated;
