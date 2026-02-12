-- SELF JOIN: Compare rows within same table
SELECT o1.order_id as order1, 
       o2.order_id as order2,
       o1.customer_id
FROM orders o1
JOIN orders o2 ON o1.customer_id = o2.customer_id 
              AND o1.order_id < o2.order_id;

-- CROSS JOIN: Cartesian product
SELECT c.customer_name, p.product_name
FROM customers c
CROSS JOIN products p
WHERE c.country = 'USA' AND p.category = 'Electronics';


-- This gets the 3 most recent orders per customer using QUALIFY (which is much more Snowflake-native).

SELECT c.customer_name, 
       o.order_id, 
       o.order_date, 
       o.amount
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
QUALIFY ROW_NUMBER() OVER (PARTITION BY c.customer_id ORDER BY o.order_date DESC) <= 3;


-- number the orders for each customer : This is customer John's 1st order, 2nd order, 3rd order..."
SELECT c.customer_name,
       o.order_date,
       o.amount,
       ROW_NUMBER() OVER (PARTITION BY c.customer_id ORDER BY o.order_date) as order_number
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id;


-- rank customers by total spending 
SELECT customer_id,
       SUM(amount) as total_spent,
       RANK() OVER (ORDER BY SUM(amount) DESC) as spending_rank
FROM orders
GROUP BY customer_id;


-- Running total of sales over time: cumulative revenue
SELECT order_date,
       amount,
       SUM(amount) OVER (ORDER BY order_date) as running_total
FROM orders
ORDER BY order_date;


-- Compare each order to customer's average
SELECT c.customer_name,
       o.order_date,
       o.amount,
       ROUND(AVG(o.amount) OVER (PARTITION BY c.customer_id), 2) as customer_avg
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id;


-- LAG - Compare current order to previous order
SELECT c.customer_name,
       o.order_date,
       o.amount,
       LAG(o.amount) OVER (PARTITION BY c.customer_id ORDER BY o.order_date) as previous_order_amount
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id;

-- Show each customer's first order amount
SELECT c.customer_name,
       o.order_date,
       o.amount,
       FIRST_VALUE(o.amount) OVER (PARTITION BY c.customer_id ORDER BY o.order_date) as first_order_amount
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id;