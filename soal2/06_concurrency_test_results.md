================================================================================
DEMO A: TANPA PENGUNCIAN (Pola Baca-Cek-Tulis Sederhana di Aplikasi)
================================================================================
[Kasir A] membaca stok = 1 (Cukup)
[Kasir B] membaca stok = 1 (Cukup)
[Kasir A] PENJUALAN BERHASIL (Stok di-update = 0)
[Kasir B] PENJUALAN BERHASIL (Stok di-update = 0)

>>> HASIL AKHIR DEMO A:
  stok_akhir | total_unit_terjual 
------------+--------------------
          0 |                  2 
❌ ANOMALI OVERSELLING TERCAPAI: 2 unit terjual padahal fisik hanya ada 1 unit!

================================================================================
DEMO B: PENGUNCIAN PESIMISTIK (SELECT ... FOR UPDATE di dalam Trigger)
================================================================================
[Kasir A] BEGIN + INSERT SALE 1 unit 'BRG-002' -> BARIS TERKUNCI FOR UPDATE
[Kasir B] BEGIN + INSERT SALE 1 unit 'BRG-002' -> TERTAHAN (Antre menunggu kunci Kasir A)
[Kasir A] Pemrosesan transaksi 2 detik... Executing COMMIT -> Sukses!
[Kasir B] Kunci dilepas. Kasir B membaca stok terbaru = 0
[Kasir B] ERROR: Transaksi SALE ditolak: stok BRG-002 hanya 0 unit, diminta 1 unit.

>>> HASIL AKHIR DEMO B:
  stok_akhir | total_unit_terjual 
------------+--------------------
          0 |                  1 
✅ BERHASIL MENCEGAH OVERSELLING: Hanya 1 penjualan tersimpan. Kasir B ditolak!

================================================================================
DEMO C: ISOLASI SERIALIZABLE
================================================================================
[Kasir A] (SERIALIZABLE) membaca stok = 1 -> COMMIT (Penjualan Berhasil)
[Kasir B] (SERIALIZABLE) membaca stok = 1 -> COMMIT
[Kasir B] ERROR 40001: could not serialize access due to concurrent update

>>> HASIL AKHIR DEMO C:
  stok_akhir | total_unit_terjual 
------------+--------------------
          0 |                  1 
✅ BERHASIL MENCEGAH OVERSELLING: Transaksi Kasir B dibatalkan oleh PostgreSQL
