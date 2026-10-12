=== UJI 1: Jurnal seimbang (500.000 vs 500.000) -> DITERIMA
STATUS: ✅ BERHASIL TERSIMPAN & POSTED

=== UJI 2: Jurnal TIDAK seimbang dikirim langsung via API (750.000 vs 700.000) -> DITOLAK saat COMMIT
psql: ERROR: Jurnal 2 tidak seimbang: Total Debit = 750000.00, Total Kredit = 700000.00

=== UJI 3: Nominal debit negatif -> DITOLAK
psql: ERROR: new row for relation "journal_lines" violates check constraint "ck_lines_debit_nonneg"

=== UJI 4: Debit dan kredit sama-sama nol -> DITOLAK
psql: ERROR: new row for relation "journal_lines" violates check constraint "ck_lines_not_both_zero"

=== UJI 5: Hapus akun Kas yang sudah memiliki transaksi -> DITOLAK (RESTRICT)
psql: ERROR: update or delete on table "chart_of_accounts" violates foreign key constraint "fk_lines_account"

=== UJI 6: Hapus header jurnal yang memiliki baris rincian -> DITOLAK (RESTRICT)
psql: ERROR: update or delete on table "journal_headers" violates foreign key constraint "fk_lines_header"

=== UJI 7: Posting jurnal yang memiliki 0 baris rincian -> DITOLAK
psql: ERROR: Jurnal 3 tidak dapat di-POSTED: minimal 2 baris (debit & kredit)

=== UJI 8: Menggunakan account_id yang tidak terdaftar di COA -> DITOLAK
psql: ERROR: insert or update on table "journal_lines" violates foreign key constraint "fk_lines_account"
