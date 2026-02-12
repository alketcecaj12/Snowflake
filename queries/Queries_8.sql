-- Multiple aggregates with conditions
SELECT customer_id,
       COUNT(*) as total_orders,
       COUNT(CASE WHEN status = 'completed' THEN 1 END) as completed_orders,
       COUNT(CASE WHEN status = 'pending' THEN 1 END) as pending_orders,
       SUM(CASE WHEN status = 'completed' THEN amount ELSE 0 END) as completed_revenue
FROM orders
GROUP BY customer_id;


-- ARRAY_AGG: Create arrays
SELECT customer_id,
       ARRAY_AGG(order_id) as order_ids,
       ARRAY_AGG(OBJECT_CONSTRUCT('order_id', order_id, 'amount', amount)) as order_details
FROM orders
GROUP BY customer_id;

-- Flatten arrays (if you have semi-structured data)
SELECT value::VARCHAR as product
FROM TABLE(FLATTEN(INPUT => PARSE_JSON('["Laptop", "Mouse", "Keyboard"]')));