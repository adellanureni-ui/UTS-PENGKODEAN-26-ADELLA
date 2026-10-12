=== UJI AUTOMATED PLAYWRIGHT BROWSER TEST (VOUCHER KAS KELUAR) ===

1. Pengujian Keseimbangan Saldo:
   - Debit: Rp750.000, Kredit: Rp900.000 (Selisih: Rp150.000)
   --> Banner: "TIDAK SEIMBANG (Selisih: Rp150.000)" (Warna Merah)
   --> Tombol Submit: DISABLED (Terkunci)

2. Pengujian Akun Kas di Sisi Debit:
   - Debit: Kas (1101) Rp500.000, Kredit: Beban Sewa (6103) Rp500.000
   --> Checklist: "Akun Kas/Bank WAJIB berada di posisi KREDIT" -> SILANG MERAH (X)
   --> Tombol Submit: DISABLED (Terkunci)

3. Pengujian Transaksi Seimbang & Valid:
   - Debit: Beban Listrik (6102) Rp750.000 + Beban Transportasi (6105) Rp250.000 = Rp1.000.000
   - Kredit: Kas (1101) Rp1.000.000
   --> Banner: "SEIMBANG - Debit = Kredit" (Warna Hijau)
   --> Checklist 5/5: CENTANG HIJAU (V)
   --> Tombol Submit: ENABLED (Aktif & Siap Kirim JSON)
