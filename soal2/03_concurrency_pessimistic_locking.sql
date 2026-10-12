BEGIN;
  -- Baris barang dikunci pesimistik (transaksi lain antre di baris ini)
  SELECT stock_qty 
  FROM inventory_items 
  WHERE item_id = 'BRG-002' 
  FOR UPDATE;

  -- Lakukan pemrosesan mutasi (trigger akan mengeksekusi validasi & update)
  INSERT INTO inventory_transactions (item_id, trx_type, qty)
  VALUES ('BRG-002', 'SALE', 1);

COMMIT; -- Kunci dilepas; transaksi berikutnya baru bisa membaca stok terbaru (0)
