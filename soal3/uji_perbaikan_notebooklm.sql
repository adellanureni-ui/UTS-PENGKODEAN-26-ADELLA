=== UJI 1: Mutasi internal Bank -> Kas Kecil via Voucher KAS KELUAR biasa
psql: ERROR: Voucher kas KELUAR tidak boleh mendebit akun kas/setara kas (Kas Kecil).
HINT: Gunakan rpc_create_cash_transfer untuk mutasi internal kas.

=== UJI 2: Mutasi internal via rpc_create_cash_transfer -> BERHASIL
 reference_no | journal_type | account_code | account_name | debit      | credit
--------------+--------------+--------------+--------------+------------+------------
 MK-0001      | MUTASI_KAS   | 1103         | Kas Kecil    | 2000000.00 |       0.00
 MK-0001      | MUTASI_KAS   | 1102         | Bank         |       0.00 | 2000000.00

=== UJI 3: Penempatan Deposito > 3 Bulan (1105) via rpc_create_cash_transfer -> DITOLAK
psql: ERROR: Mutasi kas internal hanya diizinkan antar akun KAS/SETARA_KAS (PSAK 207). Deposito > 3 Bulan tergolong Investasi.

=== REKONSILIASI ARUS KAS PER AKTIVITAS (PSAK 207)
      aktivitas      | arus_kas_bersih 
---------------------+-----------------
 OPERASI             |     -3000000.00 
 PENDANAAN           |     30000000.00 
 (MUTASI_KAS)        |      [EXCLUDED] 
