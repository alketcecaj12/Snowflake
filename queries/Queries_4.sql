-- Fixed version
SELECT customer_name, 
       order_date, 
       amount,
       ROW_NUMBER() OVER (PARTITION BY o.customer_id ORDER BY order_date) as order_sequence
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id;

-- RANK and DENSE_RANK: Handle ties differently
SELECT product_name,
       price,
       RANK() OVER (ORDER BY price DESC) as price_rank,
       DENSE_RANK() OVER (ORDER BY price DESC) as dense_rank
FROM products;

-- Running totals with SUM
SELECT order_date,
       amount,
       SUM(amount) OVER (ORDER BY order_date) as running_total
FROM orders;

-- Moving average
SELECT order_date,
       amount,
       AVG(amount) OVER (ORDER BY order_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as moving_avg_3day
FROM orders;

-- LAG and LEAD: Access previous/next rows
SELECT order_date,
       amount,
       LAG(amount) OVER (ORDER BY order_date) as previous_order_amount,
       LEAD(amount) OVER (ORDER BY order_date) as next_order_amount,
       amount - LAG(amount) OVER (ORDER BY order_date) as difference_from_previous
FROM orders;

-- FIRST_VALUE and LAST_VALUE
SELECT customer_id,
       order_date,
       amount,
       FIRST_VALUE(amount) OVER (PARTITION BY customer_id ORDER BY order_date) as first_order_amount,
       LAST_VALUE(amount) OVER (PARTITION BY customer_id ORDER BY order_date 
                                ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as last_order_amount
FROM orders;

-- NTILE: Divide into buckets
SELECT customer_name,
       age,
       NTILE(4) OVER (ORDER BY age) as age_quartile
FROM customers;

-- Simple example of partitioning
SELECT product_name,
       category,
       price,
       RANK() OVER (PARTITION BY category ORDER BY price DESC) as price_rank
FROM products;


-- Find each customer's most recent order
SELECT c.customer_name, o.order_date, o.amount
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
QUALIFY ROW_NUMBER() OVER (PARTITION BY o.customer_id ORDER BY o.order_date DESC) = 1;

-- Top 3 best-selling products in each category
SELECT product_name, category, total_sold
FROM (
    SELECT p.product_name, 
           p.category,
           SUM(oi.quantity) as total_sold,
           RANK() OVER (PARTITION BY p.category ORDER BY SUM(oi.quantity) DESC) as rank_in_category
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    GROUP BY p.product_name, p.category
)
WHERE rank_in_category <= 3;


-- Create monthly spending data, then calculate month-over-month growth
WITH monthly_customer_spend AS (
    SELECT 
        customer_id,
        DATE_TRUNC('month', order_date) as order_month,
        SUM(amount) as monthly_spend
    FROM orders
    GROUP BY customer_id, DATE_TRUNC('month', order_date)
)
SELECT 
    customer_id,
    order_month,
    monthly_spend,
    LAG(monthly_spend) OVER (PARTITION BY customer_id ORDER BY order_month) as prev_month_spend,
    monthly_spend - LAG(monthly_spend) OVER (PARTITION BY customer_id ORDER BY order_month) as growth
FROM monthly_customer_spend;