BEGIN ISOLATION LEVEL SERIALIZABLE;

  SELECT stock_qty FROM inventory_items WHERE item_id = 'BRG-002';
  
  UPDATE inventory_items 
  SET stock_qty = stock_qty - 1 
  WHERE item_id = 'BRG-002';

COMMIT;
