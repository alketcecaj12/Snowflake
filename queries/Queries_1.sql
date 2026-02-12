-- Get all columns
SELECT * FROM SNOWFLAKE_LEARNING_DB.ALKETCECAJ_LOAD_SAMPLE_DATA_FROM_S3.CUSTOMERS;

-- Get specific columns
SELECT first_name, last_name, email FROM SNOWFLAKE_LEARNING_DB.ALKETCECAJ_LOAD_SAMPLE_DATA_FROM_S3.CUSTOMERS;

-- Column aliases
SELECT first_name AS name, email AS contact_email FROM SNOWFLAKE_LEARNING_DB.ALKETCECAJ_LOAD_SAMPLE_DATA_FROM_S3.CUSTOMERS;

-- Simple conditions
SELECT * FROM orders WHERE order_date = '2024-01-15';
SELECT * FROM products WHERE price > 100;

-- Multiple conditions
SELECT * FROM customers 
WHERE country = 'USA' AND age >= 18;

-- IN operator
SELECT * FROM orders WHERE status IN ('pending', 'processing');

-- Pattern matching
SELECT * FROM customers WHERE email LIKE '%@gmail.com';

-- NULL handling
SELECT * FROM customers WHERE phone IS NULL;
SELECT * FROM customers WHERE phone IS NOT NULL;


-- Sort ascending/descending
SELECT * FROM products ORDER BY price DESC;
SELECT * FROM customers ORDER BY last_name ASC, first_name ASC;

-- Limit results
SELECT * FROM orders ORDER BY order_date DESC LIMIT 10;

-- Snowflake specific: TOP
SELECT TOP 10 * FROM orders ORDER BY order_date DESC;

-- Common aggregates
SELECT COUNT(*) FROM orders;
SELECT SUM(amount) FROM orders;
SELECT AVG(price) FROM products;
SELECT MAX(order_date), MIN(order_date) FROM orders;

-- COUNT DISTINCT
SELECT COUNT(DISTINCT customer_id) FROM orders;

-- Group and aggregate
SELECT customer_id, COUNT(*) as order_count
FROM orders
GROUP BY customer_id
ORDER BY order_count DESC;

-- Multiple grouping columns
SELECT country, city, COUNT(*) as customer_count
FROM customers
GROUP BY country, city
ORDER BY customer_count DESC;

-- HAVING (filter after grouping)
SELECT customer_id, SUM(amount) as total_spent
FROM orders
GROUP BY customer_id
HAVING SUM(amount) > 100;

