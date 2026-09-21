/*markdown
# Q1
Using the e-commerce tables (customers, orders, products, order_items), write the following DML statements: 

(a) INSERT a new customer. Write an INSERT adding 3 order_items rows in a single statement. 

(b) UPDATE all Electronics products: increase price by 10%. UPDATE to set stock_qty=0 for products never ordered (use subquery). 

(c) DELETE all orders placed before 2020 where total_amount < 100. Explain why you should test with SELECT first before running DELETE. 

(d) Write a transaction: insert new order, insert 2 order_items, update customer's last_order_date -- all atomically. 

(e) Predict the result: -- products: (1,'Phone',100.00,'Electronics'),(2,'Shirt',200.00,'Clothing') UPDATE products SET price=price*1.10 WHERE category='Electronics'; SELECT id, price FROM products ORDER BY id; 


*/

-- (a)
insert into customers (id,name ,city,email,registration_date) values(202,'john','bangalore','john@gmail.com',current_date);
INSERT INTO order_items (order_id, product_id, quantity)
VALUES
    (1001, 1, 2),
    (1001, 2, 1),
    (1001, 3, 3);

ALTER TABLE customers
ADD COLUMN last_order_date DATE;

-- (b)
update products
set price=price*1.10
where category='Electronics';

-- update products
-- set stock_qty=0
-- where id not in(select product_id from order_items);
UPDATE products p
SET stock_qty = 0
WHERE NOT EXISTS (
    SELECT 1
    FROM order_items oi
    WHERE oi.product_id = p.id
);

-- (c)
select * from orders
where order_date <'2020-01-01' and total_amount<100;

delete from orders where order_date<'2020-01-01' and total_amount<100;

-- select is used first to verify which rows will be deleted and ensure that where condition is correct .
-- this helps to prevent accidental deletion of incorrect or important data


-- (d)
begin;
-- insert new order
insert into orders (id , customer_id,order_date,total_amount,product_id)
values (1002,101,current_date,300.00,1);

-- insert order items
insert into order_items(order_id,product_id,quantity) VALUES   (1002,1,1),(1002,2,1);

--update customers late order date
update customers set last_order_date=current_date
where id=101;

commit;


--(e) Predict the result: 
-- products: (1,'Phone',100.00,'Electronics'),(2,'Shirt',200.00,'Clothing') 
UPDATE products 
SET price=price*1.10 
WHERE category='Electronics'; 
SELECT id, price 
FROM products ORDER BY id;

--output
id       price
1        110.00
2        200.00

/*markdown
# Q2
You receive a daily file of updated customer records. Write a MERGE / UPSERT statement: 

(a) MERGE: if customer exists (matched on customer_id) -- UPDATE name, email, city; if new -- INSERT all columns. 

(b) Rewrite using PostgreSQL INSERT ... ON CONFLICT DO UPDATE (UPSERT). Explain the difference between MERGE and ON CONFLICT. 

(c) MERGE implementing SCD Type 2: expire old record (set effective_to, is_current=false) and INSERT new version for city changes. Insert normally for new customers. 

(d) Explain when MERGE can cause performance issues on large tables and what alternatives exist (staging tables + DELETE + INSERT pattern). 

(e) Predict the result: -- target customers: (1,'Alice','Delhi'),(2,'Bob','Mumbai') -- source: (1,'Alice','Pune'),(3,'Carol','Chennai') -- After MERGE (update city for match, insert for new): SELECT id,name,city FROM customers ORDER BY id; 


*/

CREATE TEMP TABLE new_customers (
    id INTEGER,
    name VARCHAR(100),
    city VARCHAR(100),
    email VARCHAR(100),
    registration_date DATE
);
INSERT INTO new_customers
    (id, name, city, email, registration_date)
VALUES
    (9, 'Alice', 'Pune', 'alice@gmail.com', CURRENT_DATE),
    (10, 'Carol', 'Chennai', 'carol@gmail.com', CURRENT_DATE);

CREATE TEMP TABLE new_cus (
    customer_id INTEGER,
    name VARCHAR(100),
    email VARCHAR(150),
    city VARCHAR(100)
);
INSERT INTO new_cus (customer_id, name, email, city)
VALUES
    (101, 'John', 'john@gmail.com', 'Mumbai'),
    (105, 'Alice', 'alice@gmail.com', 'Delhi');

-- (a)
merge into customers as c using new_customers as nc
on c.id=nc.id  
when matched then 
update set name=nc.name,
email=nc.email,
city=nc.city

when not matched then
insert (id,name,city,email,registration_date) values (nc.id,nc.name,nc.city,nc.email,nc.registration_date);

--(b)
insert into customers (id,name,city,email,registration_date)
select id ,name,city,email,registration_date from new_customers
on conflict(id)
do update set name=excluded.name,email=excluded.email,city=excluded.city;

-- merge matches rows between source and targetand allows differnet actions using when matched and matched.
-- on conflict is postgresql's upsert that attempts an insert and performs an upadte or do nothing when unique or primary key conflict occur



--(c)
-- expire the old record
MERGE INTO dim_customer AS dc
USING new_cus AS nc
ON dc.customer_id = nc.customer_id
   AND dc.is_current = TRUE

WHEN MATCHED
     AND dc.city <> nc.city
THEN
    UPDATE SET
        effective_to = CURRENT_DATE,
        is_current = FALSE;


-- Insert new version of changed customers
INSERT INTO dim_customer
    (customer_key, customer_id, name, email, city,
     effective_from, effective_to, is_current)
SELECT
    COALESCE((SELECT MAX(customer_key) FROM dim_customer), 0) + 1,
    nc.customer_id,
    nc.name,
    nc.email,
    nc.city,
    CURRENT_DATE,
    NULL,
    TRUE
FROM new_cus nc
JOIN dim_customer dc
    ON dc.customer_id = nc.customer_id
WHERE dc.is_current = FALSE
  AND dc.effective_to = CURRENT_DATE;

-- Insert  new customers
INSERT INTO dim_customer
    (customer_key, customer_id, name, email, city,
     effective_from, effective_to, is_current)
SELECT
    COALESCE((SELECT MAX(customer_key) FROM dim_customer), 0) + 1,
    nc.customer_id,
    nc.name,
    nc.email,
    nc.city,
    CURRENT_DATE,
    NULL,
    TRUE
FROM new_cus nc
WHERE NOT EXISTS (
    SELECT 1
    FROM dim_customer dc
    WHERE dc.customer_id = nc.customer_id
);


-- INSERT INTO dim_customer
--     (customer_id, name, email, city,
--      effective_from, effective_to, is_current)
-- SELECT
--     nc.customer_id,
--     nc.name,
--     nc.email,
--     nc.city,
--     CURRENT_DATE,
--     NULL,
--     TRUE
-- FROM new_cus nc
-- JOIN dim_customer dc
--     ON dc.customer_id = nc.customer_id
-- WHERE dc.is_current = FALSE
--   AND dc.effective_to = CURRENT_DATE;


-- -- Insert completely new customers
-- INSERT INTO dim_customer
--     (customer_id, name, email, city,
--      effective_from, effective_to, is_current)
-- SELECT
--     nc.customer_id,
--     nc.name,
--     nc.email,
--     nc.city,
--     CURRENT_DATE,
--     NULL,
--     TRUE
-- FROM new_cus nc
-- WHERE NOT EXISTS (
--     SELECT 1
--     FROM dim_customer dc
--     WHERE dc.customer_id = nc.customer_id
-- );


-- (d)
-- merge can cause performance issues on large tables because it must match source and target rows which invlove expensive table scans and joins.
-- alternative way is to load data into staging table and use seperate delete/update and insert operations.

--(e) Predict the result: 
-- target customers: (1,'Alice','Delhi'),(2,'Bob','Mumbai') 
-- source: (1,'Alice','Pune'),(3,'Carol','Chennai') 
-- After MERGE (update city for match, insert for new): 
SELECT id,name,city FROM customers ORDER BY id;

-- output
id     name       city
1      alice      pune
2      bob        mumbai
3      carol      chennai

/*markdown
# Q3
You have an orders table with 500 million rows. Implement partitioning: 

(a) CREATE TABLE for a partitioned orders table using RANGE partitioning on order_date. Create partitions for 2023, 2024, 2025. 

(b) CREATE TABLE for customers partitioned by LIST on region ('North','South','East','West'). Add a DEFAULT partition for unknown regions. 

(c) CREATE TABLE for order_items partitioned by HASH on order_id into 4 buckets. Explain when hash partitioning is better than range or list. 

(d) Show how partitioning improves performance: write a query with WHERE order_date>'2024-01-01' and explain 'partition pruning' and why it reduces I/O. 

(e) Predict which partition each row goes to: CREATE TABLE orders(id INT, order_date DATE) PARTITION BY RANGE(order_date); CREATE TABLE orders_2023 PARTITION OF orders FOR VALUES FROM('2023-01-01') TO ('2024-01-01'); CREATE TABLE orders_2024 PARTITION OF orders FOR VALUES FROM('2024-01-01') TO ('2025-01-01'); INSERT INTO orders VALUES(1,'2023-06-15'),(2,'2024-03-20'); SELECT tableoid::regclass, id FROM orders ORDER BY id; 


*/

-- (a)
CREATE TABLE orders_partitioned (
    id INT,
    customer_id INT,
    order_date DATE,
    total_amount NUMERIC,
    product_id INT
)
PARTITION BY RANGE (order_date);
CREATE TABLE orders_2023
PARTITION OF orders_partitioned
FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');

CREATE TABLE orders_2024
PARTITION OF orders_partitioned
FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

CREATE TABLE orders_2025
PARTITION OF orders_partitioned
FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

-- (b)
CREATE TABLE customers_partitioned (
    id INT,
    name VARCHAR(100),
    city VARCHAR(100),
    email VARCHAR(150),
    registration_date DATE,
    region VARCHAR(50)
)
PARTITION BY LIST (region);
CREATE TABLE customers_north
PARTITION OF customers_partitioned
FOR VALUES IN ('North');

CREATE TABLE customers_south
PARTITION OF customers_partitioned
FOR VALUES IN ('South');

CREATE TABLE customers_east
PARTITION OF customers_partitioned
FOR VALUES IN ('East');

CREATE TABLE customers_west
PARTITION OF customers_partitioned
FOR VALUES IN ('West');

CREATE TABLE customers_default
PARTITION OF customers_partitioned
DEFAULT;

--(c)
CREATE TABLE order_items_partitioned (
    order_id INT,
    product_id INT,
    quantity INT
)
PARTITION BY HASH (order_id);
CREATE TABLE order_items_p0
PARTITION OF order_items_partitioned
FOR VALUES WITH (MODULUS 4, REMAINDER 0);

CREATE TABLE order_items_p1
PARTITION OF order_items_partitioned
FOR VALUES WITH (MODULUS 4, REMAINDER 1);

CREATE TABLE order_items_p2
PARTITION OF order_items_partitioned
FOR VALUES WITH (MODULUS 4, REMAINDER 2);

CREATE TABLE order_items_p3
PARTITION OF order_items_partitioned
FOR VALUES WITH (MODULUS 4, REMAINDER 3);

-- (d)
SELECT *
FROM orders_partitioned
WHERE order_date > '2024-01-01';

-- Partition pruning allows  to skip partitions that cannot satisfy the WHERE condition. 
-- This reduces the amount of data that must be scanned, thereby reducing I/O and potentially improving query performance.

--(e) Predict which partition each row goes to: 
CREATE TABLE orders(id INT, order_date DATE) 
PARTITION BY RANGE(order_date); 
CREATE TABLE orders_2023 PARTITION OF orders 
FOR VALUES FROM('2023-01-01') TO ('2024-01-01'); 
CREATE TABLE orders_2024 PARTITION OF orders FOR VALUES FROM('2024-01-01') TO ('2025-01-01'); 
INSERT INTO orders VALUES(1,'2023-06-15'),(2,'2024-03-20'); 
SELECT tableoid::regclass, id FROM orders ORDER BY id;

-- output
tableoid           id
orders_test_2023    1
orders_test_2024    2

/*markdown
# Q4
You need to load 10 million rows from a CSV file into PostgreSQL efficiently: 

(a) Write the COPY command to load orders_2024.csv (header row, comma-separated). Show both server-side COPY and client-side \copy versions and explain the difference. 

(b) Load only specific columns (customer_id, order_date, total_amount) from the CSV, skipping the rest. 

(c) List 5 best practices for bulk loading performance (e.g., disabling indexes, UNLOGGED tables, TRUNCATE before load). 

(d) After bulk loading, which maintenance commands should you run (ANALYZE, VACUUM, REINDEX) and in what order? Explain what each does. 

(e) Predict the result: -- orders table is empty before COPY -- orders_2024.csv contains 3 rows COPY orders FROM '/tmp/orders_2024.csv' CSV HEADER; SELECT COUNT(*), MAX(total_amount), MIN(total_amount) FROM orders; 


*/

-- (a)
COPY orders
FROM '/tmp/orders_2024.csv'
WITH (
    FORMAT CSV,
    HEADER TRUE
);

-- (b)
COPY orders
    (customer_id, order_date, total_amount)
FROM '/tmp/orders_2024.csv'
WITH (
    FORMAT CSV,
    HEADER TRUE
);


--(c)
-- 1. Use COPY instead of individual INSERT statements.

-- 2. Disable or remove unnecessary indexes before
--    a large initial load and create them afterward.

-- 3. Use an UNLOGGED staging table when appropriate.

CREATE UNLOGGED TABLE orders_staging (
    id INT,
    customer_id INT,
    order_date DATE,
    total_amount NUMERIC,
    product_id INT
);


-- 4. Use TRUNCATE before a complete reload.

-- TRUNCATE TABLE orders;


-- 5. Load into a staging table first, validate the data,
--    and then insert into the final table.

INSERT INTO orders
    (id, customer_id, order_date, total_amount, product_id)
SELECT
    id,
    customer_id,
    order_date,
    total_amount,
    product_id
FROM orders_staging;

-- (d)

-- Update table statistics
ANALYZE orders;
-- Remove dead tuples and maintain table health
VACUUM orders;
-- Rebuild indexes when necessary
REINDEX TABLE orders;
-- Explanation:
-- ANALYZE updates statistics used by the query planner.
-- VACUUM cleans up dead tuples.
-- REINDEX rebuilds indexes.

-- (e)
-- orders table is empty before COPY
-- orders_2024.csv contains 3 rows

COPY orders
FROM '/tmp/orders_2024.csv'
CSV HEADER;
SELECT
    COUNT(*),
    MAX(total_amount),
    MIN(total_amount)
FROM orders;
-- predicted:
-- COUNT(*) = 3
-- MAX(total_amount) = largest amount among the 3 rows
-- MIN(total_amount) = smallest amount among the 3 rows

/*markdown
# Q5
Optimizing a slow reporting query joining orders and customers with multiple column filters: 

(a) Explain the difference between B-tree, Hash, and GIN indexes. Give one use case where each is the best choice. 

(b) Create a COMPOSITE index on orders(customer_id, order_date DESC). Explain the column order rule and what 'left-prefix' means. 

(c) Create a PARTIAL index on orders(total_amount) WHERE status='completed'. Explain when partial is better than full and how much storage it saves. 

(d) Create a COVERING index including all columns for: SELECT order_date, total_amount FROM orders WHERE customer_id=42. Explain 'index-only scan'. 

(e) Predict what EXPLAIN will show: -- No index on orders EXPLAIN SELECT order_date, total_amount FROM orders WHERE customer_id=42; -- Shows: Seq Scan, cost=0.00..450.00 CREATE INDEX idx_cov ON orders(customer_id) INCLUDE(order_date,total_amount); EXPLAIN SELECT order_date, total_amount FROM orders WHERE customer_id=42; -- Now shows: ____? 


*/

-- (a)
-- Difference between B-tree, Hash and GIN indexes
--
-- B-tree:
-- Default PostgreSQL index type.
-- Best for equality, range comparisons and sorting.
-- Example use case: searching orders by customer_id or order_date.
--
-- Hash:
-- Best mainly for exact equality comparisons (=).
-- Example use case: searching users by an exact ID or exact key.
--
-- GIN (Generalized Inverted Index):
-- Best for searching within composite values such as arrays,
-- JSONB and full-text search data.
-- Example use case: searching for a value inside a JSONB column.

-- (b)
CREATE INDEX idx_orders_customer_date
ON orders(customer_id, order_date DESC);


-- Column order matters.
-- customer_id is the first (leading) column.
-- order_date is the second column.
-- The index is especially useful for:
-- WHERE customer_id = 42
-- and:
-- WHERE customer_id = 42
-- AND order_date >= '2024-01-01'
--
-- Left-prefix means PostgreSQL can effectively use the
-- beginning/leftmost columns of a composite index.
--
-- For:
-- (customer_id, order_date)
--
-- customer_id alone        -> can use the index
-- customer_id + order_date -> can use the index
-- order_date alone         -> generally cannot use the
--                             leading part efficiently
--
-- DESC means order_date is stored in descending index order.

-- (c)
CREATE INDEX idx_completed_orders_amount
ON orders(total_amount)
WHERE status = 'completed';

--A partial index is better than a full index when queries frequently access only a subset of rows, such as status='completed'.
-- It creates an index only for those rows, making the index smaller and reducing index maintenance overhead.

-- (d)
CREATE INDEX idx_orders_customer_covering
ON orders(customer_id)
INCLUDE (order_date, total_amount);

SELECT
    order_date,
    total_amount
FROM orders
WHERE customer_id = 42;

--An Index-Only Scan happens when PostgreSQL can get all the data needed by a query directly from the index, without having to read the actual table rows.

(e) Predict what EXPLAIN will show: 
-- No index on orders 
EXPLAIN SELECT order_date, total_amount FROM orders WHERE customer_id=42; 
-- Shows: Seq Scan, cost=0.00..450.00 
CREATE INDEX idx_cov ON orders(customer_id) INCLUDE(order_date,total_amount); 
EXPLAIN SELECT order_date, total_amount FROM orders WHERE customer_id=42;
 -- Now shows: ____?

-- Expected result:
 -- Index Only Scan using idx_cov on orders

--  Before creating the index, PostgreSQL uses a Seq Scan because there is no suitable index.
--   After creating the covering index, PostgreSQL can use an Index Only Scan because customer_id, order_date, and total_amount are all available in the index. 
--   This can reduce table I/O and improve query performance.

/*markdown
# Q6
Products table has a jsonb column 'attributes' storing: {"color":"red","weight":1.2,"tags":["sale","new"]} 

(a) Use ->> to extract 'color' as text and -> to extract 'tags' as JSON. Filter to only products where color='red'. 

(b) Use JSON_AGG to return each customer_id with a JSON array of all their order IDs and amounts. 

(c) Use jsonb_set to update the 'weight' attribute of product id=1 from 1.2 to 1.5 without replacing the entire column. 

(d) Create a GIN index on attributes. Write a query using @> to find all products tagged with 'sale'. Explain why GIN is right for jsonb containment queries. 

(e) Predict the result set: -- products: (id=1, attributes='{"color":"red","weight":1.2,"tags":["sale"]}') SELECT id,   attributes->>'color' AS color,   (attributes->>'weight')::float + 0.3 AS new_weight,   attributes->'tags' AS tags FROM products WHERE id=1; 


*/




-- (a)
-- Use ->> to extract color as text and -> to extract tags as JSON.
-- Filter only products where color = 'red'.

SELECT
    id,
    attributes ->> 'color' AS color,
    attributes -> 'tags' AS tags
FROM products
WHERE attributes ->> 'color' = 'red';


-- Explanation:
-- ->> extracts the value as TEXT.
-- -> extracts the value as JSONB.
-- Therefore:
-- attributes ->> 'color' gives: red
-- attributes -> 'tags' gives: ["sale","new"]


-- (b)
-- Return each customer_id with a JSON array
-- containing their order IDs and amounts.

SELECT
    customer_id,
    JSON_AGG(
        JSON_BUILD_OBJECT(
            'order_id', id,
            'amount', total_amount
        )
    ) AS orders
FROM orders
GROUP BY customer_id;


-- Explanation:
-- JSON_BUILD_OBJECT creates a JSON object for each order.
-- JSON_AGG combines all orders belonging to a customer
-- into one JSON array.
--
-- Example:
-- customer_id = 101
-- [
--     {"order_id":1001,"amount":500},
--     {"order_id":1002,"amount":300}
-- ]


-- (c)
-- Update the weight attribute of product id = 1
-- from 1.2 to 1.5 using jsonb_set.

UPDATE products
SET attributes = jsonb_set(
    attributes,
    '{weight}',
    '1.5'::jsonb
)
WHERE id = 1;


-- Explanation:
-- jsonb_set() changes a specific value inside JSONB.
-- '{weight}' specifies the JSON key to update.
-- '1.5'::jsonb is the new JSONB value.
--
-- Before:
-- {"color":"red","weight":1.2,"tags":["sale","new"]}
--
-- After:
-- {"color":"red","weight":1.5,"tags":["sale","new"]}


-- (d)
-- Create a GIN index on the attributes JSONB column.

CREATE INDEX idx_products_attributes_gin
ON products
USING GIN (attributes);


-- Find products where the tags contain "sale".

SELECT *
FROM products
WHERE attributes @> '{"tags":["sale"]}'::jsonb;


-- Explanation:
-- @> means "contains".
-- The query finds products whose JSONB attributes
-- contain "sale" inside the tags array.
--
-- GIN is suitable for JSONB because it efficiently indexes
-- keys and values inside JSONB data and supports containment
-- queries such as @>.


-- (e)
-- Predict the result:
--
-- Product:
-- id = 1
-- attributes =
-- {"color":"red","weight":1.2,"tags":["sale"]}

SELECT
    id,
    attributes ->> 'color' AS color,
    (attributes ->> 'weight')::float + 0.3 AS new_weight,
    attributes -> 'tags' AS tags
FROM products
WHERE id = 1;


-- Expected output:
--
-- id | color | new_weight | tags
-- ---+-------+------------+---------
-- 1  | red   | 1.5        | ["sale"]