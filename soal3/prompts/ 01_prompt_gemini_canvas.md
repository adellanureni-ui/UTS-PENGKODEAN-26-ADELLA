Kamu adalah seorang Senior Full-Stack Frontend Developer untuk Sistem Informasi Akuntansi Ritel & Logistik.
Buatkan di Canvas satu file HTML tunggal (HTML + Tailwind CSS via CDN + JavaScript murni, TANPA React/Framework) untuk formulir "Voucher Kas Keluar (Bukti Kas Keluar / BKK)".

BERIKUT ADALAH BATASAN TEKNIS & ATURAN BISNIS WAJIB:
1. Header Formulir: Tanggal Transaksi, No. Bukti (format: BKK-YYYYMMDD-XXXX), Deskripsi / Dibayarkan Kepada.
2. Rincian Baris Jurnal Dinamis: Tabel input minimal 2 baris awal dengan tombol (+ Tambah Baris) dan (Hapus Baris).
3. Kalkulasi Integer Sen (Presisi Finansial): Seluruh perhitungan matematika wajib dikonversi ke sen (Math.round(val * 100)) untuk menghindari galat floating-point.
4. Indikator Keseimbangan Live (Zero Discrepancy): 
   - Hitung Total Debit, Total Kredit, dan Selisih secara real-time.
   - Tampilkan banner status "SEIMBANG (BALANCED)" berwarna hijau jika Total Debit = Total Kredit dan > 0.
   - Tampilkan banner status "TIDAK SEIMBANG" berwarna merah beserta nominal selisih jika Total Debit != Total Kredit.
5. Checklist Aturan Bisnis Live (5 Kriteria Testable):
   - [ ] Tanggal, No. Bukti, & Deskripsi terisi lengkap.
   - [ ] Tanggal transaksi tidak berada di masa depan.
   - [ ] Minimal 2 baris jurnal terisi.
   - [ ] Setiap baris terisi akun, nominal > 0 (non-negatif), dan hanya terisi satu sisi (Debit ATAU Kredit).
   - [ ] Akun Kas/Bank (1101, 1102, 1103) WAJIB ada dan HANYA berada di posisi KREDIT (Kas Keluar).
6. Penguncian Tombol Submit: Tombol "Submit & Posting Jurnal" WAJIB disabled/locked selama checklist aturan bisnis belum tercentang hijau 100%.
7. Kontrak Payload JSON: Saat Submit diklik, hasilkan objek JSON siap kirim ke Supabase RPC rpc_create_cash_voucher.
