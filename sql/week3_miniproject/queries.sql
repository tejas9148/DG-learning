/*markdown
Create dim_customer with SCD Type 2 columns. Insert 10 sample customers. 

Write a MERGE statement processing 5 incoming records: 3 updates (city changed with SCD Type 2 logic: expire old, insert new), 2 new customers. 

Create a partitioned orders table using RANGE partitioning on order_date. Create partitions for 2022, 2023, 2024. Insert 30 sample rows. 

Write and run EXPLAIN ANALYZE on a query filtering by order_date. Show partition pruning is active. Capture the output. 

Write COPY command to bulk-load orders_2024.csv into the 2024 partition. Include pre-load (disable index, TRUNCATE) and post-load steps (ANALYZE, rebuild index). 

Create 3 index types: composite on (customer_id, order_date), partial for status='completed', covering for a specific reporting query. Run EXPLAIN ANALYZE before and after each. 
*/

SELECT current_database();


/*markdown
Create dim_customer with SCD Type 2 columns. Insert 10 sample customers. 
*/

CREATE TABLE dim_customer (
    customer_id INT,
    customer_name VARCHAR(100),
    email VARCHAR(100),
    city VARCHAR(50),
    effective_date DATE,
    end_date DATE,
    is_current BOOLEAN
);

INSERT INTO dim_customer
(customer_id, customer_name, email, city, effective_date, end_date, is_current)
VALUES
(1, 'Rahul', 'rahul@gmail.com', 'Bangalore', '2026-01-01', NULL, TRUE),
(2, 'Amit', 'amit@gmail.com', 'Chennai', '2026-01-01', NULL, TRUE),
(3, 'Priya', 'priya@gmail.com', 'Mumbai', '2026-01-01', NULL, TRUE),
(4, 'Sneha', 'sneha@gmail.com', 'Hyderabad', '2026-01-01', NULL, TRUE),
(5, 'Karan', 'karan@gmail.com', 'Pune', '2026-01-01', NULL, TRUE),
(6, 'Anjali', 'anjali@gmail.com', 'Delhi', '2026-01-01', NULL, TRUE),
(7, 'Vikram', 'vikram@gmail.com', 'Kolkata', '2026-01-01', NULL, TRUE),
(8, 'Neha', 'neha@gmail.com', 'Mysore', '2026-01-01', NULL, TRUE),
(9, 'Arjun', 'arjun@gmail.com', 'Kochi', '2026-01-01', NULL, TRUE),
(10, 'Meera', 'meera@gmail.com', 'Jaipur', '2026-01-01', NULL, TRUE);

/*markdown
Write a MERGE statement processing 5 incoming records: 3 updates (city changed with SCD Type 2 logic: expire old, insert new), 2 new customers. 
*/

CREATE TEMP TABLE incoming_customer (
    customer_id INT,
    customer_name VARCHAR(100),
    email VARCHAR(100),
    city VARCHAR(50)
);

INSERT INTO incoming_customer
(customer_id, customer_name, email, city)
VALUES
(1, 'Rahul', 'rahul@gmail.com', 'Hyderabad'),
(2, 'Amit', 'amit@gmail.com', 'Pune'),
(3, 'Priya', 'priya@gmail.com', 'Delhi'),
(11, 'Arjun', 'arjun_new@gmail.com', 'Bangalore'),
(12, 'Nisha', 'nisha@gmail.com', 'Chennai');

UPDATE dim_customer d
SET
    end_date = CURRENT_DATE - 1,
    is_current = FALSE
FROM incoming_customer i
WHERE d.customer_id = i.customer_id
  AND d.is_current = TRUE
  AND d.city <> i.city;

  INSERT INTO dim_customer
(customer_id, customer_name, email, city, effective_date, end_date, is_current)
SELECT
    i.customer_id,
    i.customer_name,
    i.email,
    i.city,
    CURRENT_DATE,
    NULL,
    TRUE
FROM incoming_customer i
LEFT JOIN dim_customer d
    ON i.customer_id = d.customer_id
   AND d.is_current = TRUE
WHERE d.customer_id IS NULL
   OR d.city <> i.city;

/*markdown
Create a partitioned orders table using RANGE partitioning on order_date. Create partitions for 2022, 2023, 2024. Insert 30 sample rows. 
*/

CREATE TABLE orders (
    order_id INT,
    customer_id INT,
    order_date DATE,
    status VARCHAR(20),
    amount DECIMAL(10,2)
)
PARTITION BY RANGE (order_date);

CREATE TABLE orders_2022
PARTITION OF orders
FOR VALUES FROM ('2022-01-01') TO ('2023-01-01');

CREATE TABLE orders_2023
PARTITION OF orders
FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');

CREATE TABLE orders_2024
PARTITION OF orders
FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');



INSERT INTO orders
(order_id, customer_id, order_date, status, amount)
VALUES
-- 2022
(1, 1, '2022-01-15', 'completed', 500.00),
(2, 2, '2022-02-20', 'pending', 750.00),
(3, 3, '2022-03-10', 'completed', 1200.00),
(4, 4, '2022-05-25', 'cancelled', 300.00),
(5, 5, '2022-07-14', 'completed', 950.00),
(6, 6, '2022-08-30', 'pending', 450.00),
(7, 7, '2022-09-12', 'completed', 1800.00),
(8, 8, '2022-10-05', 'completed', 650.00),
(9, 9, '2022-11-18', 'pending', 1100.00),
(10, 10, '2022-12-20', 'completed', 850.00),

-- 2023
(11, 1, '2023-01-12', 'completed', 700.00),
(12, 2, '2023-02-18', 'pending', 900.00),
(13, 3, '2023-03-25', 'completed', 1500.00),
(14, 4, '2023-04-10', 'cancelled', 400.00),
(15, 5, '2023-06-15', 'completed', 1250.00),
(16, 6, '2023-07-22', 'pending', 550.00),
(17, 7, '2023-08-19', 'completed', 2000.00),
(18, 8, '2023-09-05', 'completed', 800.00),
(19, 9, '2023-11-11', 'pending', 1350.00),
(20, 10, '2023-12-28', 'completed', 950.00),

-- 2024
(21, 1, '2024-01-10', 'completed', 800.00),
(22, 2, '2024-02-14', 'pending', 1000.00),
(23, 3, '2024-03-20', 'completed', 1750.00),
(24, 4, '2024-04-18', 'cancelled', 500.00),
(25, 5, '2024-05-25', 'completed', 1400.00),
(26, 6, '2024-06-30', 'pending', 600.00),
(27, 7, '2024-08-12', 'completed', 2200.00),
(28, 8, '2024-09-17', 'completed', 900.00),
(29, 9, '2024-10-21', 'pending', 1450.00),
(30, 10, '2024-12-15', 'completed', 1100.00);

SELECT COUNT(*) FROM orders_2022;

/*markdown
Write and run EXPLAIN ANALYZE on a query filtering by order_date. Show partition pruning is active. Capture the output. 
*/

EXPLAIN ANALYZE
SELECT *
FROM orders
WHERE order_date >= '2024-01-01'
  AND order_date < '2025-01-01';

TRUNCATE TABLE orders_2024;

COPY orders_2024
FROM 'C:/Program Files/PostgreSQL/18/data/import/orders_2024.csv'
WITH (FORMAT csv);


EXPLAIN ANALYZE
SELECT *
FROM orders
WHERE customer_id = 5
  AND order_date >= '2024-01-01'
  AND order_date < '2025-01-01';

CREATE INDEX idx_orders_customer_date
ON orders (customer_id, order_date);

EXPLAIN ANALYZE
SELECT *
FROM orders
WHERE customer_id = 5
  AND order_date >= '2024-01-01'
  AND order_date < '2025-01-01';

EXPLAIN ANALYZE
SELECT *
FROM orders
WHERE status = 'completed';

CREATE INDEX idx_orders_completed
ON orders (order_date)
WHERE status = 'completed';

EXPLAIN ANALYZE
SELECT *
FROM orders
WHERE status = 'completed';

EXPLAIN ANALYZE
SELECT customer_id, order_date, amount
FROM orders
WHERE customer_id = 5
  AND order_date >= '2024-01-01'
  AND order_date < '2025-01-01';

CREATE INDEX idx_orders_reporting
ON orders (customer_id, order_date)
INCLUDE (amount);

EXPLAIN ANALYZE
SELECT customer_id, order_date, amount
FROM orders
WHERE customer_id = 5
  AND order_date >= '2024-01-01'
  AND order_date < '2025-01-01';

