--CTEs are especially useful when you're building complex analytical queries. 
--They help you (and anyone reading your code) understand the logic flow much better than deeply nested subqueries.

-- basic CTE
WITH cte_name AS (
    -- Your query here
    SELECT column1, column2
    FROM table_name
    WHERE condition
)
-- Now use the CTE
SELECT * FROM cte_name;



--Use a CTE for clarity:
WITH customer_totals AS (
    SELECT customer_id, SUM(amount) as total_spent
    FROM orders
    GROUP BY customer_id
)
SELECT c.customer_name, ct.total_spent
FROM customers c
JOIN customer_totals ct ON c.customer_id = ct.customer_id;



--Multiple CTEs You can chain multiple CTEs together:
WITH 
step1 AS (
    SELECT customer_id, COUNT(*) as order_count
    FROM orders
    GROUP BY customer_id
),
step2 AS (
    SELECT customer_id, AVG(amount) as avg_order_value
    FROM orders
    GROUP BY customer_id
)
SELECT s1.customer_id, s1.order_count, s2.avg_order_value
FROM step1 s1
JOIN step2 s2 ON s1.customer_id = s2.customer_id;


-- Recursive CTE (for hierarchical data)
WITH RECURSIVE date_series AS (
    SELECT '2024-01-01'::DATE as date
    UNION ALL
    SELECT DATEADD(day, 1, date)
    FROM date_series
    WHERE date < '2024-01-31'
)
SELECT * FROM date_series;