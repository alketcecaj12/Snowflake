-- PIVOT: Turn rows into columns
SELECT *
FROM (
    SELECT customer_id, 
           DATE_TRUNC('month', order_date) as month,
           amount
    FROM orders
)
PIVOT (SUM(amount) FOR month IN ('2024-01-01', '2024-02-01'))
AS pivoted_data;



-- UNION: Combine results (removes duplicates)
SELECT customer_id FROM orders WHERE order_date > '2024-02-01'
UNION
SELECT customer_id FROM orders WHERE amount > 1000;

-- UNION ALL: Combine results (keeps duplicates - faster)
SELECT customer_id FROM orders WHERE status = 'completed'
UNION ALL
SELECT customer_id FROM orders WHERE status = 'processing';

-- INTERSECT: Common records
SELECT customer_id FROM orders WHERE amount > 500
INTERSECT
SELECT customer_id FROM orders WHERE order_date > '2024-02-01';

-- EXCEPT: Records in first but not second
SELECT customer_id FROM customers
EXCEPT
SELECT customer_id FROM orders;


-- GROUPING SETS
SELECT country, city, COUNT(*) as customer_count
FROM customers
GROUP BY GROUPING SETS (
    (country, city),
    (country),
    ()
);

-- ROLLUP: Hierarchical aggregation
SELECT country, city, COUNT(*) as customer_count
FROM customers
GROUP BY ROLLUP (country, city);

-- CUBE: All combinations
SELECT country, city, COUNT(*) as customer_count
FROM customers
GROUP BY CUBE (country, city);

-- LISTAGG: Concatenate values
SELECT customer_id,
       LISTAGG(product_name, ', ') WITHIN GROUP (ORDER BY product_name) as products_ordered
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY customer_id;