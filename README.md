# UTS-PENGKODEAN-26-ADELLA
Sistem Akuntansi dan Pemrograman Basis Data: Modul General Ledger, Otomasi Persediaan, & Cryptographic Audit Trail
Proyek ini merupakan solusi komprehensif untuk Tugas Akhir UTS Pengkodean dan Pemrograman Kelas E / Sistem Akuntansi dan Pemrograman Basis Data. Proyek mengintegrasikan perancangan basis data terstruktur, otomatisasi logika bisnis akuntansi di tingkat database, penanganan transaksi paralel (concurrency control), hingga pembuatan purwarupa web interaktif dengan sistem jejak audit kriptografis (tamper-proof cryptographic audit trail).

📌 Identitas Pembuat & Tugas
Nama Mahasiswa: Adella Nureni
Mata Kuliah: Pengkodean dan Pemrograman Kelas E / Sistem Akuntansi dan Pemrograman Basis Data
Program Studi: Akuntansi, Fakultas Ekonomika dan Bisnis, Universitas Diponegoro
Fokus Proyek: Defense-in-Depth Financial Database Architecture, Automated Perpetual Inventory, Supabase RPC, SHA-256 Hash Chain Audit Trail, & PSAK 207 Compliance.
📐 Ringkasan Arsitektur & Strategi Defense-in-Depth
Sistem ini menerapkan filosofi keamanan Defense-in-Depth di mana aturan bisnis finansial tidak hanya diuji di lapisan antarmuka pengguna (frontend), melainkan ditegakkan secara mutlak dan mengikat di lapisan terdalam basis data (database engine):

┌────────────────────────────────────────────────────────────────────────┐
│                        LAPISAN 1: FRONTEND WEB                         │
│  - Live Zero-Discrepancy Banner (Total Debit = Total Kredit)           │
│  - Integer Cent Precision Math (Math.round(val * 100))                 │
│  - Live 5-Rule Checklist Validation & Submit Button Locking            │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ JSON Payload (RPC Call)
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                    LAPISAN 2: SUPABASE RPC & SECURITY                  │
│  - SECURITY DEFINER Function Encapsulation                             │
│  - Row Level Security (RLS) Blocking Direct Table Insert/Update/Delete │
│  - Server-side JWT Identity Tracking (auth.uid() / auth.jwt())         │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ Executed inside Transaction
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│               LAPISAN 3: DATABASE ENGINE (POSTGRESQL)                  │
│  - Foreign Keys with ON DELETE RESTRICT (Anti-Orphan Rows)             │
│  - CHECK Constraints (debit >= 0, credit >= 0, non-zero, single-side)  │
│  - Deferred Constraint Trigger for Double-Entry Balance Verification   │
│  - Pessimistic Row Lock (SELECT ... FOR UPDATE) for Inventory Mutex    │
│  - SHA-256 Hash Chain & Immutability Triggers (Anti-Update/Delete)     │
└────────────────────────────────────────────────────────────────────────┘
📁 Struktur Repositori
uts-coding-akuntansi/
├── README.md                           <-- Dokumentasi Utama Repositori
├── jawaban_uts_adella_nureni.pdf       <-- Dokumen Cetak Laporan PDF Resmi
├── soal1/                              <-- SOAL 1: Arsitektur Data & Normalisasi GL
│   ├── 01_schema_general_ledger.sql    <-- DDL: CoA, Header, Line + Deferred Constraint Trigger
│   ├── 02_uji_soal1.sql                <-- Skrip Uji: 8 Skenario Integritas & Validasi API
│   ├── erd_general_ledger.png          <-- Diagram ERD Resolusi Tinggi (Notasi Crow's Foot)
│   └── README.md                       <-- Laporan Naratif Soal 1 (ERD, DDL, 3NF & Audit Trail)
├── soal2/                              <-- SOAL 2: Otomasi Persediaan & Concurrency
│   ├── 01_inventory_trigger.sql        <-- Trigger Mutasi Stok Perpetual & Jurnal Otomatis (HPP/Persediaan)
│   ├── 02_uji_trigger.sql              <-- Skrip Uji Mutasi & Rekonsiliasi Automatic GL vs Fisik
│   ├── 03_concurrency.sql              <-- Sintaks FOR UPDATE, SERIALIZABLE, & Atomic Update
│   ├── demo_concurrency.sh             <-- Skrip Shell Simulasi 2 Kasir Concurrent (Race Condition)
│   └── README.md                       <-- Laporan Naratif Soal 2 (Trigger Logika & Concurrency)
├── soal3/                              <-- SOAL 3: Purwarupa Web, Supabase RPC, & Audit Trail
│   ├── supabase/
│   │   ├── 01_audit_trail_immutability.sql <-- Trigger Immutability, SHA-256 Hash Chain, & RPC Storno
│   │   ├── 02_supabase_security.sql        <-- Policies RLS & Revoke Hak Akses Tabel Direct
│   │   ├── 03_uji_soal3.sql                <-- 15 Skenario Uji Audit Trail & Supabase Security
│   │   └── 05_uji_perbaikan_notebooklm.sql <-- Uji Kepatuhan PSAK 207 / IAS 7 & Mutasi Internal
│   ├── web/
│   │   └── index.html                  <-- Frontend Web Voucher Kas Keluar (Tailwind CSS + JS)
│   ├── prompts/
│   │   ├── prompt_gemini_canvas.md     <-- Rekaman Prompt Gemini Canvas, Code Review, & Fixes
│   │   └── memo_notebooklm_psak207.md  <-- Verifikasi Kepatuhan PSAK 207 / IAS 7 dari NotebookLM
│   └── README.md                       <-- Laporan Naratif Soal 3 (Full-Stack & Security Review)
└── bukti/                              <-- Folder Log Output Eksekusi Pengujian
    ├── uji_soal1_output.txt            <-- Log Uji Integritas General Ledger
    ├── uji_soal2_trigger.txt            <-- Log Uji Trigger Persediaan & Rekonsiliasi
    ├── uji_soal2_concurrency.txt      <-- Log Uji Race Condition (2 Kasir Concurrent)
    └── uji_soal3_audit.txt            <-- Log Uji 15 Skenario Keamanan & SHA-256 Hash Chain
🚀 Panduan Eksekusi & Instalasi (Quick Start)
Prasyarat System
PostgreSQL: Versi 15 atau lebih baru (memiliki ekstensi pgcrypto).
Supabase Account / CLI (opsional untuk deployment cloud).
Web Browser: Chrome/Firefox/Edge modern (support ES6 & Tailwind CDN).
Bash Shell: Untuk menjalankan simulasi concurrency demo_concurrency.sh.
Langkah 1: Inisialisasi Database & Skema General Ledger (Soal 1)
# Clone repositori
git clone <repository_url>
cd uts-coding-akuntansi

# Eksekusi DDL General Ledger & Constraint Trigger
psql -U postgres -d your_database -f soal1/01_schema_general_ledger.sql

# Jalankan Uji Integritas Soal 1
psql -U postgres -d your_database -f soal1/02_uji_soal1.sql
Langkah 2: Eksekusi Trigger Persediaan & Concurrency Test (Soal 2)
# Jalankan DDL & Trigger Persediaan Perpetual
psql -U postgres -d your_database -f soal2/01_inventory_trigger.sql

# Uji Mutasi & Rekonsiliasi Fisik vs GL
psql -U postgres -d your_database -f soal2/02_uji_trigger.sql

# Simulasi Race Condition 2 Kasir Sejajar
chmod +x soal2/demo_concurrency.sh
./soal2/demo_concurrency.sh
Langkah 3: Setup Audit Trail, SHA-256 Hash Chain, & Supabase Security (Soal 3)
# Pasang Ekstensi pgcrypto, Hash Chain, & Trigger Immutability
psql -U postgres -d your_database -f soal3/supabase/01_audit_trail_immutability.sql

# Konfigurasi RLS & Hak Akses Role
psql -U postgres -d your_database -f soal3/supabase/02_supabase_security.sql

# Jalankan 15 Skenario Pengujian Audit & Keamanan
psql -U postgres -d your_database -f soal3/supabase/03_uji_soal3.sql
psql -U postgres -d your_database -f soal3/supabase/05_uji_perbaikan_notebooklm.sql
Langkah 4: Membuka Purwarupa Web
Buka file soal3/web/index.html langsung di browser pilihan Anda atau gunakan ekstensi Live Server di VS Code.

📑 Rincian Dokumen & Pembahasan per Soal
SOAL 1: Desain Arsitektur Data, Normalisasi, & Penegakan Asas Berpasangan
1.1 Perancangan Skema Relasional (ERD): Memisahkan entitas menjadi chart_of_accounts, journal_headers, dan journal_lines (struktur Header-Line dinormalisasi 3NF). Menyelesaikan relasi Many-to-Many antara transaksi dan bagan akun.
1.2 Kekangan Integritas (PostgreSQL DDL): Menerapkan PRIMARY KEY, FOREIGN KEY ON DELETE RESTRICT (anti-orphan rows), CHECK constraints (debit >= 0, credit >= 0, not_both_zero, one_side), serta CONSTRAINT TRIGGER bertipe DEFERRABLE INITIALLY DEFERRED untuk penegakan SUM(debit) = SUM(credit) saat COMMIT.
1.3 Analisis Normalisasi 3NF & Jejak Audit: Membedah anomali ketergantungan parsial (2NF) dan transitif (3NF) pada skema Flat Journal Table, menyajikan matriks evaluasi 5 dimensi, serta menjelaskan implikasi arsitektur terhadap Vouching, Tracing, dan Storno Reversal.
SOAL 2: Otomasi Persediaan Perpetual & Concurrency Control
2.1 Otomatisasi Mutasi Persediaan Perpetual: Mengimplementasikan BEFORE INSERT TRIGGER pada inventory_transactions yang meng-UPDATE stok barang fisik, melakukan proteksi Anti-Negative Inventory, serta membentuk jurnal HPP dan Persediaan secara otomatis di Buku Besar. Menyajikan bukti Rekonsiliasi GL vs Fisik dengan Selisih Rp0,00.
2.2 Penanganan Concurrency & Overselling: Menganalisis anomali Race Condition & Lost Update saat stok fisik tinggal 1 unit dan diakses 2 kasir sejajar. Mengimplementasikan 3 solusi arsitektural:
Pessimistic Row Locking (SELECT ... FOR UPDATE) — Rekomendasi Utama.
Serializable Isolation Level (BEGIN ISOLATION LEVEL SERIALIZABLE + Application Retry Logic SQLSTATE 40001).
Conditional Atomic Update (UPDATE ... WHERE stock_qty >= qty).
SOAL 3: Purwarupa Web, Supabase RPC, & Cryptographic Audit Trail
3.1a Purwarupa Web Voucher Kas Keluar: Mengembangkan formulir BKK interaktif (Tailwind CSS + JS) berbasis presisi sen (Math.round(val * 100)), indikator keseimbangan live, checklist 5 aturan bisnis, penguncian tombol Submit, serta hasil Code Review perbaikan batas waktu WIB dan pembatasan akun kas di sisi Kredit.
3.1b Verifikasi Standar PSAK 207 / IAS 7: Mengaudit logika kode menggunakan NotebookLM terhadap standar Laporan Arus Kas, memisahkan transaksi mutasi kas internal (rpc_create_cash_transfer), dan menyajikan view arus kas per aktivitas (OPERASI, INVESTASI, PENDANAAN).
3.2 Audit Trail, SHA-256 Hash Chain, & Supabase Security:
Kolom audit server-side (created_by dari JWT, created_at timestamp server).
Penyegelan kriptografi SHA-256 Hash Chain (fn_calculate_journal_hash) yang mengikat hash transaksi sebelumnya (prev_hash).
Immutability Triggers: Menolak UPDATE, DELETE, dan TRUNCATE pada transaksi berstatus POSTED.
Storno Reversal: Fungsi rpc_reverse_journal untuk pembalikan jurnal secara transparan.
Cryptographic Verification: Fungsi rpc_verify_journal_integrity untuk mendeteksi perubahan data ilegal oleh DBA/peretas.
Supabase RLS & Grants: Menutup akses tabel langsung dan memaksa eksekusi via RPC Security Definer.
📊 Matriks Ringkasan Skenario Pengujian Sistem
Modul	Jumlah Skenario	Target Pengujian	Hasil Diharapkan	Status
Soal 1	8 Uji	Validasi DDL, Foreign Keys, & API Direct Insert Unbalanced	Jurnal tidak seimbang / minus ditolak saat COMMIT	PASS (100%) ✅
Soal 2.1	5 Uji	Trigger Mutasi Stok, Anti-Negative, & Rekonsiliasi	Stok ter-update otomatis, stok minus ditolak, Selisih GL = 0	PASS (100%) ✅
Soal 2.2	3 Demo	Concurrency 2 Kasir Concurrent (Stok = 1 unit)	Overselling dicegah via FOR UPDATE / SERIALIZABLE	PASS (100%) ✅
Soal 3.1a	3 Uji	Interface BKK Web, Cent Math, & Submit Locking	Tombol Submit terkunci selama selisih / aturan melanggar	PASS (100%) ✅
Soal 3.1b	3 Uji	Kepatuhan PSAK 207 & Mutasi Internal Kas	Mutasi internal dikecualikan dari Laporan Arus Kas	PASS (100%) ✅
Soal 3.2	15 Uji	Immutability, SHA-256 Hash Chain, Storno, & RLS	Update/Delete ditolak, manipulasi DB terdeteksi hash	PASS (100%) ✅
📜 Lisensi & Standar Referensi
Lisensi: MIT License — Bebas digunakan untuk keperluan akademik dan pembelajaran.
Standar Akuntansi: PSAK 207 / IAS 7 (Statement of Cash Flows), PSAK 208 (Financial Statement Presentation).
Engine Database: PostgreSQL 15+ & Supabase Database Platform.
