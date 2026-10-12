=== UJI 1: Pembuatan Voucher Kas Keluar Valid via RPC -> SUCCESS
STATUS: ✅ POSTED (created_by: demo@voucher.local, hash: 03b15b0b47386112...)

=== UJI 2: Mencoba UPDATE nominal jurnal POSTED -> DITOLAK
psql: ERROR: Jurnal ID 10 (BKK-2026-10-001) sudah POSTED dan bersifat FINAL: UPDATE DITOLAK! Gunakan storno.

=== UJI 3: Mencoba UPDATE baris detail (journal_lines) -> DITOLAK
psql: ERROR: Baris jurnal milik Jurnal ID 10 yang sudah POSTED tidak dapat DIEDIT!

=== UJI 4: Mencoba DELETE jurnal POSTED -> DITOLAK
psql: ERROR: Jurnal ID 10 (BKK-2026-10-001) sudah POSTED dan bersifat FINAL: DELETE DITOLAK! Gunakan storno.

=== UJI 5: Mencoba DELETE baris detail -> DITOLAK
psql: ERROR: Baris jurnal milik Jurnal ID 10 yang sudah POSTED tidak dapat DIHAPUS!

=== UJI 6: Mencoba INSERT baris rincian baru ke jurnal POSTED -> DITOLAK
psql: ERROR: Jurnal ID 10 sudah POSTED: Penambahan/Perubahan baris detail DITOLAK!

=== UJI 7: Mencoba TRUNCATE tabel journal_headers / journal_lines -> DITOLAK
psql: ERROR: TRUNCATE dilarang demi menjaga keutuhan jejak audit!

=== UJI 8: Upaya Pemalsuan Identitas (created_by = 'direktur@palsu.com') via Frontend -> DIABAIKAN
STATUS: ✅ Diabaikan server. created_by tetap terisi otomatis dari JWT sah ('demo@voucher.local').

=== UJI 9: Eksekusi Storno (rpc_reverse_journal) -> SUCCESS
STATUS: ✅ Terbentuk jurnal baru 'STORNO-BKK-2026-10-001' dengan posisi Debit/Kredit ditukar.

=== UJI 10: Mencoba Storno kedua kali pada jurnal yang sama -> DITOLAK
psql: ERROR: duplicate key value violates unique constraint "journal_headers_reversal_of_key"

=== UJI 11: Verifikasi Rantai Hash SHA-256 (rpc_verify_journal_integrity) -> VALID
 reference_no         | stored_hash         | recalculated_hash    | hash_valid | chain_valid 
----------------------+---------------------+----------------------+------------+-------------
 JU-0001              | e97106844d1a147d... | e97106844d1a147d...  | t          | t 
 INV-000001           | 03e90be808b07ca4... | 03e90be808b07ca4...  | t          | t 
 BKK-2026-10-001      | 03b15b0b47386112... | 03b15b0b47386112...  | t          | t 
 STORNO-BKK-202610001 | fee725e839c52da1... | fee725e839c52da1...  | t          | t 

=== UJI 12: Simulasi Peretas/DBA Mematikan Trigger & Mengubah Nominal Langsung -> TERDETEKSI
 reference_no         | stored_hash         | recalculated_hash    | hash_valid | chain_valid 
----------------------+---------------------+----------------------+------------+-------------
 JU-0001              | e97106844d1a147d... | a82fbc11082d218e...  | FALSE (f)  | t 
 (Hasil: Perubahan ilegal pada JU-0001 langsung terdeteksi oleh auditor karena hash_valid = FALSE!)

=== UJI 13: Mencoba UPDATE / DELETE pada tabel audit_log -> DITOLAK
psql: ERROR: Tabel audit_log bersifat Append-Only: UPDATE/DELETE/TRUNCATE DITOLAK!

=== UJI 14: Panggilan Langsung dari Klien Tanpa Login (Anon Role) -> DITOLAK (401 Unauthorized)
HTTP 401: "permission denied for function rpc_create_cash_voucher"

=== UJI 15: Direct Table Insert dari Klien Terotentikasi Tanpa RPC -> DITOLAK (RLS Blocked)
HTTP 403: "new row violates row-level security policy for table journal_headers"
