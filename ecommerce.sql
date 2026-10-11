CREATE DATABASE ecommerce_olist;
USE ecommerce_olist;

CREATE TABLE customers (
    customer_id VARCHAR(50),
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state VARCHAR(10)
);

CREATE TABLE orders (
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_status VARCHAR(50),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME
);

CREATE TABLE order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date DATETIME,
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2)
);

CREATE TABLE order_payments (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(50),
    payment_installments INT,
    payment_value DECIMAL(10,2)
);

CREATE TABLE order_reviews (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INT,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date DATETIME,
    review_answer_timestamp DATETIME
);

CREATE TABLE products (
    product_id VARCHAR(50),
    product_category_name VARCHAR(100),
    product_name_lenght INT,
    product_description_lenght INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

CREATE TABLE sellers (
    seller_id VARCHAR(50),
    seller_zip_code_prefix INT,
    seller_city VARCHAR(100),
    seller_state VARCHAR(10)
);

CREATE TABLE product_translation (
    product_category_name VARCHAR(100),
    product_category_name_english VARCHAR(100)
);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\olist_customers_dataset(1).csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\olist_customers_dataset(1).csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SET GLOBAL local_infile = 1;
LOAD DATA LOCAL INFILE 
'C:\\Users\\Pranav shahapure\\Desktop\\ecommerce analytics\\Project Files\\olist_customers_dataset.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) FROM customers;

LOAD DATA LOCAL INFILE 
'C:\\Users\\Pranav shahapure\\Desktop\\ecommerce analytics\\Project Files\\olist_orders_dataset.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 
'C:\\Users\\Pranav shahapure\\Desktop\\ecommerce analytics\\Project Files\\olist_order_items_dataset.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 
'C:\\Users\\Pranav shahapure\\Desktop\\ecommerce analytics\\Project Files\\olist_order_payments_dataset.csv'
INTO TABLE order_payments
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 
'C:\\Users\\Pranav shahapure\\Desktop\\ecommerce analytics\\Project Files\\olist_order_reviews_dataset.csv'
INTO TABLE order_reviews
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 
'C:\\Users\\Pranav shahapure\\Desktop\\ecommerce analytics\\Project Files\\olist_products_dataset.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 
'C:\\Users\\Pranav shahapure\\Desktop\\ecommerce analytics\\Project Files\\olist_sellers_dataset.csv'
INTO TABLE sellers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 
'C:\\Users\\Pranav shahapure\\Desktop\\ecommerce analytics\\Project Files\\product_category_name_translation.csv'
INTO TABLE product_translation
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM order_items;
SELECT COUNT(*) FROM order_payments;
SELECT COUNT(*) FROM order_reviews;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM sellers;


SELECT sum (payment_value) as total_revenue 
from order_payments;

SELECT ROUND(SUM(payment_value),2) AS total_revenue
FROM order_payments;

SELECT COUNT(order_id) AS total_orders
FROM orders;

select round(avg(review_score),2) as avg_review_score
from order_reviews;


-- Top 10 Revenue Generating Products

SELECT 
    p.product_category_name,
    ROUND(SUM(oi.price),2) AS total_revenue
FROM order_items oi
JOIN products p
ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY total_revenue DESC
LIMIT 10;


-- Top 10 Customers by Spending
SELECT 
    c.customer_unique_id,
    ROUND(SUM(op.payment_value),2) AS total_spent
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN order_payments op
ON o.order_id = op.order_id
GROUP BY c.customer_unique_id
ORDER BY total_spent DESC
LIMIT 10;


-- Monthly Revenue Trend
SELECT 
    MONTHNAME(order_purchase_timestamp) AS month_name,
    ROUND(SUM(payment_value),2) AS total_revenue
FROM orders o
JOIN order_payments op
ON o.order_id = op.order_id
GROUP BY MONTH(order_purchase_timestamp), month_name
ORDER BY MONTH(order_purchase_timestamp);


-- Average Delivery Time by State
SELECT 
    c.customer_state,
    ROUND(AVG(
        DATEDIFF(
            o.order_delivered_customer_date,
            o.order_purchase_timestamp
        )
    ),2) AS avg_delivery_days
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY avg_delivery_days;


-- Most Preferred Payment Method
SELECT 
    payment_type,
    COUNT(*) AS total_transactions,
    ROUND(SUM(payment_value),2) AS total_revenue
FROM order_payments
GROUP BY payment_type
ORDER BY total_transactions DESC;


-- Orders by Order Status
SELECT 
    order_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;


-- Revenue by Customer State
SELECT 
    c.customer_state,
    ROUND(SUM(op.payment_value),2) AS total_revenue
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN order_payments op
ON o.order_id = op.order_id
GROUP BY c.customer_state
ORDER BY total_revenue DESC;


-- Top Cities by Revenue
SELECT 
    c.customer_city,
    ROUND(SUM(op.payment_value),2) AS total_revenue
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN order_payments op
ON o.order_id = op.order_id
GROUP BY c.customer_city
ORDER BY total_revenue DESC
LIMIT 10;


-- Average Review Score by Product Category
SELECT 
    p.product_category_name,
    ROUND(AVG(r.review_score),2) AS avg_review_score
FROM products p
JOIN order_items oi
ON p.product_id = oi.product_id
JOIN order_reviews r
ON oi.order_id = r.order_id
GROUP BY p.product_category_name
ORDER BY avg_review_score DESC;


-- Revenue Generated on Weekdays vs Weekends

SELECT 
    CASE
        WHEN DAYOFWEEK(o.order_purchase_timestamp) IN (1,7)
        THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    
    ROUND(SUM(op.payment_value),2) AS total_revenue
FROM orders o
JOIN order_payments op
ON o.order_id = op.order_id
GROUP BY day_type;


-- Seller Performance Analysis
SELECT 
    seller_id,
    COUNT(order_id) AS total_orders,
    ROUND(SUM(price),2) AS total_sales
FROM order_items
GROUP BY seller_id
ORDER BY total_sales DESC
LIMIT 10;

-- Average Order Value
SELECT 
    ROUND(
        SUM(payment_value) / COUNT(DISTINCT order_id),
    2) AS avg_order_value
FROM order_payments;

--  Top Product Categories by Orders
SELECT 
    p.product_category_name,
    COUNT(oi.order_id) AS total_orders
FROM products p
JOIN order_items oi
ON p.product_id = oi.product_id
GROUP BY p.product_category_name
ORDER BY total_orders DESC
LIMIT 10;
