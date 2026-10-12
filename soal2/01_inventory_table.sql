-- =============================================================================
-- SOAL 2.1: DDL TABEL MASTER & TRANSAKSI PERSEDIAAN
-- Berkas Repositori GitHub: soal2/01_inventory_trigger.sql
-- =============================================================================

-- 1. TABEL MASTER PERSEDIAAN (inventory_items)
CREATE TABLE inventory_items (
    item_id     VARCHAR(20)   NOT NULL,
    item_name   VARCHAR(100)  NOT NULL,
    stock_qty   INTEGER       NOT NULL DEFAULT 0,
    unit_cost   NUMERIC(18,2) NOT NULL DEFAULT 0,

    -- Constraints
    CONSTRAINT pk_inventory_items PRIMARY KEY (item_id),
    CONSTRAINT ck_items_stock_nonneg CHECK (stock_qty >= 0),
    CONSTRAINT ck_items_cost_nonneg CHECK (unit_cost >= 0)
);

-- 2. TABEL TRANSAKSI MUTASI PERSEDIAAN (inventory_transactions)
CREATE TABLE inventory_transactions (
    trx_id            BIGINT GENERATED ALWAYS AS IDENTITY,
    item_id           VARCHAR(20) NOT NULL,
    trx_type          VARCHAR(20) NOT NULL,
    qty               INTEGER     NOT NULL,
    trx_date          DATE        NOT NULL DEFAULT CURRENT_DATE,
    journal_header_id BIGINT,

    -- Constraints
    CONSTRAINT pk_inventory_transactions PRIMARY KEY (trx_id),
    CONSTRAINT fk_trans_item FOREIGN KEY (item_id)
        REFERENCES inventory_items (item_id) ON DELETE RESTRICT,
    CONSTRAINT fk_trans_journal_header FOREIGN KEY (journal_header_id)
        REFERENCES journal_headers (id) ON DELETE SET NULL,
    CONSTRAINT ck_trans_trx_type CHECK (trx_type IN ('PURCHASE', 'SALE', 'ADJUSTMENT'))
);
