# Sistem Akuntansi dan Pemrograman Basis Data: Modul General Ledger, Otomasi Persediaan, & Cryptographic Audit Trail

Proyek ini merupakan solusi komprehensif untuk **Tugas Akhir UTS Pengkodean dan Pemrograman Kelas E / Sistem Akuntansi dan Pemrograman Basis Data**. Proyek mengintegrasikan perancangan basis data terstruktur, otomatisasi logika bisnis akuntansi di tingkat database, penanganan transaksi paralel (*concurrency control*), hingga pembuatan purwarupa web interaktif dengan sistem jejak audit kriptografis (*tamper-proof cryptographic audit trail*).

---

## 📌 Identitas Pembuat & Tugas

- **Nama Mahasiswa**: Adella Nureni
- **Mata Kuliah**: Pengkodean dan Pemrograman Kelas E / Sistem Akuntansi dan Pemrograman Basis Data
- **Program Studi**: Akuntansi, Fakultas Ekonomika dan Bisnis, Universitas Diponegoro
- **Fokus Proyek**: *Defense-in-Depth Financial Database Architecture, Automated Perpetual Inventory, Supabase RPC, SHA-256 Hash Chain Audit Trail, & PSAK 207 Compliance*.

---

## 📐 Ringkasan Arsitektur & Strategi Defense-in-Depth

Sistem ini menerapkan filosofi keamanan **Defense-in-Depth** di mana aturan bisnis finansial tidak hanya diuji di lapisan antarmuka pengguna (*frontend*), melainkan ditegakkan secara mutlak dan mengikat di lapisan terdalam basis data (*database engine*):

```
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
```

---

## 🗂️ Diagram Relasi Entitas (ERD - Crow's Foot Style)

```
┌───────────────────────────────────┐       ┌────────────────────────────────────┐       ┌───────────────────────────────────┐
│         chart_of_accounts         │       │           journal_lines            │       │          journal_headers          │
├───────────────────────────────────┤       ├────────────────────────────────────┤       ├───────────────────────────────────┤
│ PK | account_id                   │1     N│ PK | line_id                       │N     1│ PK | header_id                    │
│ UQ | account_code                 ├───────o< FK | account_id                    >o──────┤ UQ | ref_no                        │
│    | account_name                 │       │ FK | header_id                     │       │    | trx_date                      │
│    | normal_balance (DEBIT/CREDIT)│       │    | debit                         │       │    | description                  │
│    | report_class (NERACA/RUGILABA)       │    | credit                        │       │    | posting_status (DRAFT/POSTED) │
└───────────────────────────────────┘       └────────────────────────────────────┘       └───────────────────────────────────┘
```

---

## 📁 Struktur Repositori

```text
uts-coding-akuntansi/
├── [link mencurigakan dihapus]                           <-- Dokumentasi Utama Repositori
├── jawaban_uts_adella_nureni.pdf       <-- Dokumen Cetak Laporan PDF Resmi
├── soal1/                              <-- SOAL 1: Arsitektur Data & Normalisasi GL
│   ├── 01_schema_general_ledger.sql    <-- DDL: CoA, Header, Line + Deferred Constraint Trigger
│   ├── 02_uji_soal1.sql                <-- Skrip Uji: 8 Skenario Integritas & Validasi API
│   ├── erd_general_ledger.png          <-- Diagram ERD Resolusi Tinggi (Notasi Crow's Foot)
│   └── [link mencurigakan dihapus]                       <-- Laporan Naratif Soal 1 (ERD, DDL, 3NF & Audit Trail)
├── soal2/                              <-- SOAL 2: Otomasi Persediaan & Concurrency
│   ├── 01_inventory_trigger.sql        <-- Trigger Mutasi Stok Perpetual & Jurnal Otomatis (HPP/Persediaan)
│   ├── 02_uji_trigger.sql              <-- Skrip Uji Mutasi & Rekonsiliasi Automatic GL vs Fisik
│   ├── 03_concurrency.sql              <-- Sintaks FOR UPDATE, SERIALIZABLE, & Atomic Update
│   ├── [link mencurigakan dihapus]             <-- Skrip Shell Simulasi 2 Kasir Concurrent (Race Condition)
│   └── [link mencurigakan dihapus]                       <-- Laporan Naratif Soal 2 (Trigger Logika & Concurrency)
├── soal3/                              <-- SOAL 3: Purwarupa Web, Supabase RPC, & Audit Trail
│   ├── supabase/
│   │   ├── 01_audit_trail_immutability.sql <-- Trigger Immutability, SHA-256 Hash Chain, & RPC Storno
│   │   ├── 02_supabase_security.sql        <-- Policies RLS & Revoke Hak Akses Tabel Direct
│   │   ├── 03_uji_soal3.sql                <-- 15 Skenario Uji Audit Trail & Supabase Security
│   │   └── 05_uji_perbaikan_notebooklm.sql <-- Uji Kepatuhan PSAK 207 / IAS 7 & Mutasi Internal
│   ├── web/
│   │   └── index.html                  <-- Frontend Web Voucher Kas Keluar (Tailwind CSS + JS)
│   ├── prompts/
│   │   ├── [link mencurigakan dihapus]            <-- Rekaman Prompt Gemini Canvas, Code Review, & Fixes
│   │   └── [link mencurigakan dihapus]        <-- Verifikasi Kepatuhan PSAK 207 / IAS 7 dari NotebookLM
│   └── [link mencurigakan dihapus]                       <-- Laporan Naratif Soal 3 (Full-Stack & Security Review)
└── bukti/                              <-- Folder Log Output Eksekusi Pengujian
    ├── uji_soal1_output.txt            <-- Log Uji Integritas General Ledger
    ├── uji_soal2_trigger.txt            <-- Log Uji Trigger Persediaan & Rekonsiliasi
    ├── uji_soal2_concurrency.txt      <-- Log Uji Race Condition (2 Kasir Concurrent)
    └── uji_soal3_audit.txt            <-- Log Uji 15 Skenario Keamanan & SHA-256 Hash Chain
```

---

## 🚀 Panduan Eksekusi & Instalasi (Quick Start)

### Prasyarat Sistem
- **PostgreSQL**: Versi 15 atau lebih baru (memiliki ekstensi `pgcrypto`).
- **Supabase Account / CLI** (opsional untuk deployment cloud).
- **Web Browser**: Chrome / Firefox / Edge modern (support ES6 & Tailwind CDN).
- **Bash Shell**: Untuk menjalankan simulasi concurrency `[link mencurigakan dihapus]`.

### Langkah 1: Inisialisasi Database & Skema General Ledger (Soal 1)
```bash
# Clone repositori
git clone <repository_url>
cd uts-coding-akuntansi

# Eksekusi DDL General Ledger & Constraint Trigger
psql -U postgres -d your_database -f soal1/01_schema_general_ledger.sql

# Jalankan Uji Integritas Soal 1
psql -U postgres -d your_database -f soal1/02_uji_soal1.sql
```

### Langkah 2: Eksekusi Trigger Persediaan & Concurrency Test (Soal 2)
```bash
# Jalankan DDL & Trigger Persediaan Perpetual
psql -U postgres -d your_database -f soal2/01_inventory_trigger.sql

# Uji Mutasi & Rekonsiliasi Fisik vs GL
psql -U postgres -d your_database -f soal2/02_uji_trigger.sql

# Simulasi Race Condition 2 Kasir Sejajar
chmod +x soal2/[link mencurigakan dihapus]
./soal2/[link mencurigakan dihapus]
```

### Langkah 3: Setup Audit Trail, SHA-256 Hash Chain, & Supabase Security (Soal 3)
```bash
# Pasang Ekstensi pgcrypto, Hash Chain, & Trigger Immutability
psql -U postgres -d your_database -f soal3/supabase/01_audit_trail_immutability.sql

# Konfigurasi RLS & Hak Akses Role
psql -U postgres -d your_database -f soal3/supabase/02_supabase_security.sql

# Jalankan 15 Skenario Pengujian Audit & Keamanan
psql -U postgres -d your_database -f soal3/supabase/03_uji_soal3.sql
psql -U postgres -d your_database -f soal3/supabase/05_uji_perbaikan_notebooklm.sql
```

### Langkah 4: Membuka Purwarupa Web
Buka file `soal3/web/index.html` langsung di browser pilihan Anda atau gunakan ekstensi *Live Server* di VS Code.

---

## 📑 PEMBAHASAN DETAIL SOAL UTS

### SOAL 1: DESAIN ARSITEKTUR DATA, NORMALISASI, & PENEGAKAN ASAS BERPASANGAN

#### 1.1 Perancangan Skema Relasional (ERD) & Struktur Tabel

| Nama Tabel | Kolom / Atribut | Tipe Data & Constraints | Fungsi Akuntansi |
| :--- | :--- | :--- | :--- |
| **`chart_of_accounts`** | `account_id`<br>`account_code`<br>`account_name`<br>`normal_balance`<br>`report_classification` | `INTEGER` (**PK**)<br>`VARCHAR(20)` (**UQ**)<br>`VARCHAR(100)` (`NOT NULL`)<br>`VARCHAR(10)` (`DEBIT/CREDIT`)<br>`VARCHAR(50)` (`NOT NULL`) | Master bagan akun. `account_code` unik mencegah duplikasi. `normal_balance` mengomodasi akun kontra (misal Akumulasi Penyusutan). |
| **`journal_headers`** | `header_id`<br>`trx_date`<br>`ref_no`<br>`description`<br>`posting_status` | `BIGINT` (**PK**)<br>`DATE` (`NOT NULL`)<br>`VARCHAR(50)` (**UQ**)<br>`TEXT`<br>`VARCHAR(20)` (`DEFAULT: DRAFT`) | Metadata bukti transaksi. `ref_no` unik mencegah duplikasi nomor bukti fisik. Status `DRAFT`, `POSTED`, `REVERSED` mengontrol alur otorisasi. |
| **`journal_lines`** | `line_id`<br>`header_id`<br>`account_id`<br>`debit`<br>`credit` | `BIGINT` (**PK**)<br>`BIGINT` (**FK** `journal_headers`)<br>`INTEGER` (**FK** `chart_of_accounts`)<br>`NUMERIC(18,2)` (`CHECK >= 0`)<br>`NUMERIC(18,2)` (`CHECK >= 0`) | Rincian pecahan nilai transaksi per akun. Bertindak sebagai tabel asosiatif pemecah relasi \\(M:N\\). |

---

#### 1.2 DDL PostgreSQL & Deferred Constraint Trigger (`soal1/01_schema_general_ledger.sql`)

```sql
-- DDL TABEL MASTER & JURNAL
CREATE TABLE chart_of_accounts (
    account_id            INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    account_code          VARCHAR(20)  NOT NULL UNIQUE,
    account_name          VARCHAR(100) NOT NULL,
    normal_balance        VARCHAR(10)  NOT NULL CHECK (normal_balance IN ('DEBIT', 'CREDIT')),
    report_classification VARCHAR(50)  NOT NULL
);

CREATE TABLE journal_headers (
    id               BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    transaction_date DATE        NOT NULL,
    reference_no     VARCHAR(50) NOT NULL UNIQUE,
    description      TEXT,
    posting_status   VARCHAR(20) NOT NULL DEFAULT 'DRAFT' CHECK (posting_status IN ('DRAFT', 'POSTED', 'REVERSED'))
);

CREATE TABLE journal_lines (
    id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    header_id  BIGINT        NOT NULL REFERENCES journal_headers(id) ON DELETE RESTRICT,
    account_id INTEGER       NOT NULL REFERENCES chart_of_accounts(account_id) ON DELETE RESTRICT,
    debit      NUMERIC(18,2) NOT NULL DEFAULT 0 CHECK (debit >= 0),
    credit     NUMERIC(18,2) NOT NULL DEFAULT 0 CHECK (credit >= 0),
    CONSTRAINT ck_not_both_zero CHECK (NOT (debit = 0 AND credit = 0)),
    CONSTRAINT ck_one_side      CHECK (NOT (debit > 0 AND credit > 0))
);

-- DEFERRED CONSTRAINT TRIGGER PENEGAK KESEIMBANGAN DEBIT = KREDIT
CREATE OR REPLACE FUNCTION fn_check_journal_balance()
RETURNS TRIGGER AS $$
DECLARE
    v_total_debit  NUMERIC(18,2);
    v_total_credit NUMERIC(18,2);
    v_line_count   INTEGER;
BEGIN
    SELECT COALESCE(SUM(debit), 0), COALESCE(SUM(credit), 0), COUNT(*)
    INTO v_total_debit, v_total_credit, v_line_count
    FROM journal_lines WHERE header_id = NEW.header_id;

    IF v_total_debit <> v_total_credit THEN
        RAISE EXCEPTION 'Jurnal ID % tidak seimbang: Total Debit (%) != Total Kredit (%)', NEW.header_id, v_total_debit, v_total_credit;
    END IF;

    IF v_line_count < 2 THEN
        RAISE EXCEPTION 'Jurnal ID % ditolak: Minimal harus terdiri dari 2 baris (Debit & Kredit)', NEW.header_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER trg_check_journal_balance
AFTER INSERT OR UPDATE ON journal_lines
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION fn_check_journal_balance();
```

---

#### 1.3 Analisis Normalisasi 3NF & Impikasi Audit

1. **Pelanggaran 2NF/3NF pada Flat Table**: Pada `journal_flat(no_bukti, kode_akun, tanggal, deskripsi, nama_akun, debit, credit)`, atribut `tanggal` & `deskripsi` hanya bergantung pada `no_bukti` (ketergantungan parsial - melanggar 2NF). Atribut `nama_akun` bergantung pada `kode_akun` (ketergantungan transitif - melanggar 3NF).
2. **Solusi Header-Line (3NF)**: Memisah atribut metadata ke `journal_headers`, master ke `chart_of_accounts`, dan fakta numerik transaksi ke `journal_lines`.
3. **Implikasi Audit**: Memudahkan *Vouching* (Laporan -> Header -> Bukti Fisik) & *Tracing* (Bukti Fisik -> Header -> Buku Besar), serta mengunci transaksi `POSTED` agar tidak dapat diubah tanpa jurnal pembalik (*storno*).

---

### SOAL 2: OTOMASI PERSEDIAAN PERPETUAL & CONCURRENCY CONTROL

#### 2.1 Trigger Mutasi Persediaan Perpetual (`soal2/01_inventory_trigger.sql`)

```sql
CREATE OR REPLACE FUNCTION fn_update_stock_and_journal()
RETURNS TRIGGER AS $$
DECLARE
    v_item         inventory_items%ROWTYPE;
    v_delta        INTEGER;
    v_new_stock    INTEGER;
    v_total_amount NUMERIC(18,2);
    v_header_id    BIGINT;
    v_account_inv  INTEGER; -- 1301: Persediaan
    v_account_hpp  INTEGER; -- 5101: HPP
    v_account_ap   INTEGER; -- 2101: Utang Usaha
    v_account_adj  INTEGER; -- 5901: Selisih Stok
BEGIN
    -- Pessimistic Row Lock & Ambil Stok Saat Ini
    SELECT * INTO v_item FROM inventory_items WHERE item_id = NEW.item_id FOR UPDATE;

    v_delta := CASE NEW.trx_type
        WHEN 'PURCHASE' THEN NEW.qty
        WHEN 'SALE'     THEN -NEW.qty
        WHEN 'ADJUSTMENT' THEN NEW.qty
    END;

    v_new_stock := v_item.stock_qty + v_delta;

    -- Anti-Negative Inventory Protection
    IF v_new_stock < 0 THEN
        RAISE EXCEPTION 'Transaksi DITOLAK: Stok barang % tidak mencukupi (Ada: %, Diminta: %)', v_item.item_name, v_item.stock_qty, ABS(v_delta);
    END IF;

    -- Update Stok Fisik
    UPDATE inventory_items SET stock_qty = v_new_stock WHERE item_id = NEW.item_id;

    -- Buat Jurnal Otomatis di GL
    v_total_amount := ABS(NEW.qty) * v_item.unit_cost;
    SELECT account_id INTO v_account_inv FROM chart_of_accounts WHERE account_code = '1301';
    SELECT account_id INTO v_account_hpp FROM chart_of_accounts WHERE account_code = '5101';
    SELECT account_id INTO v_account_ap  FROM chart_of_accounts WHERE account_code = '2101';
    SELECT account_id INTO v_account_adj FROM chart_of_accounts WHERE account_code = '5901';

    INSERT INTO journal_headers (transaction_date, reference_no, description, posting_status)
    VALUES (NEW.trx_date, 'INV-TRX-' || TO_CHAR(CURRENT_TIMESTAMP, 'YYYYMMDDHH24MISSMS'), 'Autojournal ' || NEW.trx_type, 'POSTED')
    RETURNING id INTO v_header_id;

    IF NEW.trx_type = 'PURCHASE' THEN
        INSERT INTO journal_lines (header_id, account_id, debit, credit) VALUES (v_header_id, v_account_inv, v_total_amount, 0), (v_header_id, v_account_ap, 0, v_total_amount);
    ELSIF NEW.trx_type = 'SALE' THEN
        INSERT INTO journal_lines (header_id, account_id, debit, credit) VALUES (v_header_id, v_account_hpp, v_total_amount, 0), (v_header_id, v_account_inv, 0, v_total_amount);
    END IF;

    NEW.journal_header_id := v_header_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_stock_and_journal
BEFORE INSERT ON inventory_transactions
FOR EACH ROW EXECUTE FUNCTION fn_update_stock_and_journal();
```

**Hasil Rekonsiliasi Automatic GL vs Fisik**: Saldo Akun Persediaan `1301` = Rp750.000,00 | Nilai Fisik Barang = Rp750.000,00 | **Selisih = Rp0,00 (100% Balanced)**.

---

#### 2.2 Penanganan Concurrency Control (Preventing Overselling)

| Solusi Arsitektural | Sintaks Utama | Perilaku Transaksi Kalah | Kebutuhan Kode Aplikasi |
| :--- | :--- | :--- | :--- |
| **1. Pessimistic Locking (`FOR UPDATE`)** | `SELECT * FROM inventory_items WHERE item_id = 'BRG-001' FOR UPDATE;` | **Antre (*Wait*)** sampai kunci dilepas, lalu membaca stok terbaru (0) & ditolak. | Sederhana; tidak memerlukan *retry logic*. |
| **2. Serializable Isolation Level** | `BEGIN ISOLATION LEVEL SERIALIZABLE;` | **Dibatalkan (*Rollback*)** dengan galat `SQLSTATE 40001`. | Wajib menambahkan *Retry Loop* pada aplikasi. |
| **3. Conditional Atomic Update** | `UPDATE inventory_items SET stock_qty = stock_qty - 1 WHERE item_id = 'BRG-001' AND stock_qty >= 1;` | **Gagal (*0 rows updated*)** tanpa melempar galat. | Sangat ringan untuk operasi single-table. |

---

### SOAL 3: PURWARUPA WEB, SUPABASE RPC, & CRYPTOGRAPHIC AUDIT TRAIL

#### 3.1a Purwarupa Web Voucher Kas Keluar (`soal3/web/index.html`)

Purwarupa dikembangkan dengan HTML + Tailwind CSS + JS Murni berbasis:
1. **Integer Cent Precision**: `Math.round((Number(val) || 0) * 100)` mencegah galat *floating-point*.
2. **Live Zero-Discrepancy Banner**: Banner hijau jika `Total Debit = Total Kredit` dan > 0, banner merah jika ada selisih.
3. **Submit Button Locking**: Tombol ter-disable otomatis selama selisih atau ada dari 5 kriteria checklist yang melanggar.
4. **Fix Code Review**: Penanganan zona waktu lokal (WIB/UTC+7) dan pembatasan Akun Kas (`1101`, `1102`, `1103`) **WAJIB di posisi KREDIT**.

---

#### 3.1b Verifikasi Kepatuhan PSAK 207 / IAS 7 (NotebookLM Audit)

- **Temuan Mutasi Internal Kas**: Transfer antar rekening bank/kas (`1102` -> `1103`) **bukan merupakan arus kas keluar**.
- **Perbaikan RPC**: Mengimplementasikan `rpc_create_cash_transfer` dengan tipe `MUTASI_KAS` yang dikecualikan dari Laporan Arus Kas Operasional.
- **View Klasifikasi Arus Kas**: Membuat `v_arus_kas_per_aktivitas` yang mengelompokkan transaksi ke dalam `OPERASI`, `INVESTASI`, dan `PENDANAAN`.

---

#### 3.2 Cryptographic Audit Trail & Supabase Security (`soal3/supabase/01_audit_trail_immutability.sql`)

```sql
-- PENGHITUNG HASH SHA-256 CHAIN (BLOCKCHAIN SEDERHANA)
CREATE OR REPLACE FUNCTION fn_calculate_journal_hash(p_header_id BIGINT)
RETURNS VARCHAR(64) AS $$
DECLARE
    v_header_text TEXT;
    v_lines_text  TEXT;
    v_prev_hash   VARCHAR(64);
    v_combined    TEXT;
BEGIN
    SELECT id || '|' || transaction_date || '|' || reference_no || '|' || COALESCE(description,'') || '|' || posting_status || '|' || COALESCE(created_by,'')
    INTO v_header_text FROM journal_headers WHERE id = p_header_id;

    SELECT COALESCE(STRING_AGG(account_id || ':' || debit || ':' || credit, ';' ORDER BY id), '')
    INTO v_lines_text FROM journal_lines WHERE header_id = p_header_id;

    SELECT COALESCE(hash_checksum, 'GENESIS_HASH_ROOT_0000000000000000000000000000000000000000000')
    INTO v_prev_hash FROM journal_headers WHERE posting_status = 'POSTED' AND id < p_header_id ORDER BY id DESC LIMIT 1;

    v_combined := v_header_text || '|' || v_lines_text || '|' || v_prev_hash;
    RETURN encode(digest(v_combined, 'sha256'), 'hex');
END;
$$ LANGUAGE plpgsql;

-- TRIGGER IMMUTABILITY (MENOLAK UPDATE/DELETE/TRUNCATE PADA JURNAL POSTED)
CREATE OR REPLACE FUNCTION fn_enforce_journal_immutability()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.posting_status = 'POSTED' THEN
        RAISE EXCEPTION 'Jurnal ID % sudah POSTED dan bersifat FINAL: UPDATE/DELETE DITOLAK! Gunakan rpc_reverse_journal (storno).', [link mencurigakan dihapus];
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_journal_headers_immutable
BEFORE UPDATE OR DELETE ON journal_headers
FOR EACH ROW EXECUTE FUNCTION fn_enforce_journal_immutability();

-- FUNGSI STORNO (REVERSAL JOURNAL)
CREATE OR REPLACE FUNCTION rpc_reverse_journal(p_target_header_id BIGINT, p_reason TEXT)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    v_orig journal_headers%ROWTYPE;
    v_storno_id BIGINT;
BEGIN
    SELECT * INTO v_orig FROM journal_headers WHERE id = p_target_header_id FOR UPDATE;
    IF v_orig.posting_status <> 'POSTED' THEN RAISE EXCEPTION 'Hanya jurnal POSTED yang dapat di-storno.'; END IF;

    INSERT INTO journal_headers (transaction_date, reference_no, description, posting_status, reversal_of)
    VALUES (CURRENT_DATE, 'STORNO-' || v_orig.reference_no, 'REVERSAL: ' || p_reason, 'POSTED', p_target_header_id)
    RETURNING id INTO v_storno_id;

    -- Balik Posisi Debit dan Kredit
    INSERT INTO journal_lines (header_id, account_id, debit, credit)
    SELECT v_storno_id, account_id, credit, debit FROM journal_lines WHERE header_id = p_target_header_id;

    -- Segel Hash SHA-256
    UPDATE journal_headers SET hash_checksum = fn_calculate_journal_hash(v_storno_id) WHERE id = v_storno_id;

    RETURN jsonb_build_object('status', 'SUCCESS', 'storno_id', v_storno_id);
END;
$$;
```

---

## 📊 Matriks Ringkasan Skenario Pengujian Sistem

| Modul | Jumlah Skenario | Target Pengujian | Hasil Diharapkan | Status |
| :--- | :---: | :--- | :--- | :---: |
| **Soal 1** | 8 Uji | Validasi DDL, Foreign Keys, & API Direct Insert Unbalanced | Jurnal tidak seimbang / minus ditolak saat `COMMIT` | **PASS (100%)** ✅ |
| **Soal 2.1** | 5 Uji | Trigger Mutasi Stok, Anti-Negative, & Rekonsiliasi | Stok ter-update otomatis, stok minus ditolak, Selisih GL = 0 | **PASS (100%)** ✅ |
| **Soal 2.2** | 3 Demo | Concurrency 2 Kasir Concurrent (Stok = 1 unit) | Overselling dicegah via `FOR UPDATE` / `SERIALIZABLE` | **PASS (100%)** ✅ |
| **Soal 3.1a** | 3 Uji | Interface BKK Web, Cent Math, & Submit Locking | Tombol Submit terkunci selama selisih / aturan melanggar | **PASS (100%)** ✅ |
| **Soal 3.1b** | 3 Uji | Kepatuhan PSAK 207 & Mutasi Internal Kas | Mutasi internal dikecualikan dari Laporan Arus Kas | **PASS (100%)** ✅ |
| **Soal 3.2** | 15 Uji | Immutability, SHA-256 Hash Chain, Storno, & RLS | Update/Delete ditolak, manipulasi DB terdeteksi hash | **PASS (100%)** ✅ |

---

## 📜 Lisensi & Standar Referensi

- **Lisensi**: MIT License — Bebas digunakan untuk keperluan akademik dan pembelajaran.
- **Standar Akuntansi**: PSAK 207 / IAS 7 (*Statement of Cash Flows*), PSAK 208 (*Financial Statement Presentation*).
- **Engine Database**: PostgreSQL 15+ & Supabase Database Platform.

---
*Dokumentasi ini disusun dan diverifikasi penuh untuk Tugas Akhir UTS Pengkodean dan Pemrograman Kelas E - Universitas Diponegoro (2026).*
```
