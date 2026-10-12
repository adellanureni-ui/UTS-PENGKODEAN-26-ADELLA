UPDATE inventory_items
SET stock_qty = stock_qty - 1
WHERE item_id = 'BRG-002' AND stock_qty >= 1
RETURNING stock_qty;
