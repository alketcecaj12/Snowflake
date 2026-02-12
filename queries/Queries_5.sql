-- Advanced JOINS

-- Get most recent order per customer
SELECT customer_id, order_date, amount
FROM orders
QUALIFY ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) = 1;

-- Top 3 products by price in each category
SELECT category, product_name, price
FROM products
QUALIFY RANK() OVER (PARTITION BY category ORDER BY price DESC) <= 3;

-- Orders above average for each customer
SELECT customer_id, order_date, amount
FROM orders
QUALIFY amount > AVG(amount) OVER (PARTITION BY customer_id);