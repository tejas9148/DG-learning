/*markdown
# Q1
Using orders (id, customer_id, order_date, total_amount): 

(a) ROW_NUMBER() to assign a sequential number to each customer's orders by order_date (row 1 = first order ever). 

(b) RANK() and DENSE_RANK() together to rank all orders by total_amount descending. Show a row where they differ. 

(c) LAG() for prev_order_amount and LEAD() for next_order_amount per customer. Show NULL where no previous/next. 

(d) 3-order rolling average of total_amount per customer using SUM() OVER() with ROWS BETWEEN 2 PRECEDING AND CURRENT ROW. 

(e) Predict the result set: -- orders: (1,1,'2024-01-01',100),(2,1,'2024-02-01',300),(3,2,'2024-01-01',400) SELECT customer_id, total_amount,   RANK() OVER(ORDER BY total_amount DESC) AS rnk,   LAG(total_amount) OVER(PARTITION BY customer_id ORDER BY order_date) AS prev FROM orders; 


*/

-- (a)
select id , customer_id , order_date , total_amount ,row_number() over (partition by customer_id order by order_date) as order_number
from orders;

-- (b)
select id , customer_id , total_amount ,
rank() over (order by total_amount desc) as rnk,
dense_rank() over (order by total_amount desc ) as dense_rnk 
from orders ;

-- (c)
select id , customer_id , total_amount , lag(total_amount) over (partition by customer_id order by order_date) as prev_order_amount,
lead(total_amount) over (partition by customer_id order by order_date) as next_order_amount
from orders;


-- (d)  average
select id , customer_id , order_date , total_amount,
avg(total_amount) over ( partition by customer_id order by order_date rows between 2 preceding and current row) as rolling_avg
from orders;

-- sum()
select id , customer_id , order_date , total_amount,
sum(total_amount) over ( partition by customer_id order by order_date rows between 2 preceding and current row) as rolling_sum
from orders;

-- (d)Predict the result set: 
-- orders: (1,1,'2024-01-01',100),(2,1,'2024-02-01',300),(3,2,'2024-01-01',400) 
SELECT customer_id, total_amount, order_date,  
RANK() OVER(ORDER BY total_amount DESC) AS rnk,   
LAG(total_amount) OVER(PARTITION BY customer_id ORDER BY order_date) AS prev 
FROM orders order by total_amount desc;

-- output
customer_id  total_amount  rnk  prev
2            400            1   null
1            300            2   100
1            100            3   null

/*markdown

# Q2
Using the same e-commerce tables: 

(a) CTE named top_customers: top 5 customers by total spending. Join the CTE with orders to show their most recent purchase. 

(b) Recursive CTE generating numbers 1 to 10. Explain when recursive CTEs are useful (e.g., hierarchical data, org trees). 

(c) UNION ALL combining 2023 and 2024 orders with a year column. Wrap in CTE, GROUP BY year to compare totals. Use INTERSECT to find customer_ids ordering in BOTH years. 

(d) ROLLUP on (category, city) showing revenue at: individual, category subtotal, and grand total. Rewrite using GROUPING SETS for only 2 of the 3 levels. 

(e) Predict the result set: -- sales(category,city,amount): ('A','X',100),('A','Y',200),('B','X',300) SELECT category, city, SUM(amount) FROM sales GROUP BY ROLLUP(category,city); 


*/

-- (a)
with top_customers as (
    select customer_id , sum(total_amount) as total_spending 
    from orders group by customer_id order by total_spending desc limit 5
) ,
latest_orders as (
    select * , row_number() over (partition by customer_id order by order_date desc) as rn from orders
)

select tc.customer_id , tc.total_spending , lo.order_date , lo.total_amount
from top_customers tc join latest_orders lo on tc.customer_id = lo.customer_id where lo.rn=1; 

-- (b)
with recursive numbers as (
    select 1 as n 
    union ALL
    select n+1
    from numbers
    where n<10
)
select * from numbers;

-- recursive are useful when data has a hierarchical or parent child relationship with multiple levels .
-- it allow to repeatedly process the related rows until a stopping condition is reached.
-- they can also useful in generating the numbers or dates


INSERT INTO orders (id, customer_id, order_date, total_amount)
VALUES
(101, 1, '2023-03-15', 500),
(102, 2, '2023-05-20', 800),
(103, 3, '2023-07-10', 300),
(104, 5, '2023-09-25', 1000);

-- (c)
with all_orders as (
    select customer_id , order_date , total_amount , 2023 as year from orders where extract(year from order_date)=2023

    union all 
        select customer_id , order_date , total_amount , 2024 as year from orders where extract(year from order_date)=2024
  
)
-- SELECT *
-- FROM all_orders
-- ORDER BY year, order_date;
select year , sum(total_amount) as total_sales
from all_orders group by year;

-- customers who ordered in both 2023 and 2024
select customer_id from orders where extract(year from order_date)=2023
intersect
select customer_id  from orders where extract(year from order_date)=2024
order by customer_id;

CREATE TABLE sales (
    category VARCHAR(50),
    city VARCHAR(50),
    amount DECIMAL(10,2)
);

INSERT INTO sales (category, city, amount)
VALUES
('A', 'X', 100),
('A', 'Y', 200),
('B', 'X', 300),
('B', 'Y', 400);

-- (d)
select category , city , sum(amount) as revenue
from sales group by rollup(category,city);

-- using grouping sets
select
    category,
    city,
    SUM(amount) AS revenue
FROM sales
GROUP BY GROUPING SETS (
    (category, city),
    (category)
);

--(e) Predict the result set: 
-- sales(category,city,amount): ('A','X',100),('A','Y',200),('B','X',300) 
SELECT category, city, SUM(amount) 
FROM sales GROUP BY ROLLUP(category,city);

-- predicted output
category city amount
A         X    100
A         Y    200 
B         X    300
A         NULL 300
B         NULL 300
NULL      NULL 600

/*markdown
# Q3
Given: SELECT * FROM orders o JOIN customers c ON o.customer_id=c.id WHERE c.city='Mumbai' AND o.order_date>'2024-01-01' ORDER BY o.total_amount DESC; 

(a) Write the EXPLAIN ANALYZE version. Describe what to look for: Seq Scan vs Index Scan, actual rows, cost, buffers. 

(b) Propose and write CREATE INDEX statements. Explain why a composite index on (customer_id, order_date) is better than two single-column indexes. 

(c) Rewrite SELECT * to select only needed columns. Explain why SELECT * is harmful on wide tables. 

(d) Create a materialized view mv_customer_revenue computing total revenue per customer. Write the REFRESH MATERIALIZED VIEW command and explain when to use it vs regular views. 

(e) Predict what changes: -- Before index: EXPLAIN shows Seq Scan, cost=0.00..450.00, rows=10000 CREATE INDEX idx_ord ON orders(customer_id, order_date); -- After index: EXPLAIN shows ______, cost=0.00..___? 


*/

-- (a)
explain (analyze , buffers)
select * from orders o join customers c on o.customer_id =c.id 
where c.city ='Mumbai'  and o.order_date >'2024-01-01' order by o.total_amount desc;

-- explain analyze is used to examine how postgresql actually executes the query.
-- the query uses the squentital scan on both order and customers .
-- The orders table has 49 actual rows scanned, with 4 rows removed
-- by the date filter. The customers table has 9 rows scanned, with
-- 5 rows removed by the Mumbai filter. The Hash Join produces 21 rows.
-- The cost represents PostgreSQL's estimated effort to execute the query and
-- is not measured in seconds.


-- (b)
-- create indexs to improve filtering and joining.

-- index on customers(city):
-- helps psotgresql find the customers from mumbai efficiently

-- composite index on orders (customer_id , order_date):
-- helps queries that use customer_id together with order_date
-- it can be more useful tha tw seperate indexex when these columns are frequently used together in the same query
-- customer id is used for joining and order date used for filtering

create index idx_customer_city on customers(city);

create index idx_orders_customer_date on orders(customer_id,order_date);

-- (c)
SELECT
    c.id AS customer_id,
    c.city,
    o.order_date,
    o.total_amount
FROM orders o
JOIN customers c
    ON o.customer_id = c.id
WHERE c.city = 'Mumbai'
  AND o.order_date > '2024-01-01'
ORDER BY o.total_amount DESC;

-- rewrite the select * statement to select only the required columns 
-- selecting only required columns reduces unnecessary data retrival , memory usage 
-- select * can be especially inefficient when the tables contain many columns because it need to retrive and display all the columns even the columns which are unnecessary.

-- (d)
create materialized view mv_customer_revenue as 
select customer_id , sum(total_amount) as total_revenue
from orders group by customer_id;

-- refresh the materialized view
refresh materialized view mv_customer_revenue;

-- (e)
-- (e) Predict what changes: 
-- Before index: EXPLAIN shows Seq Scan, cost=0.00..450.00, rows=10000 
-- CREATE INDEX idx_ord ON orders(customer_id, order_date); 
-- After index: EXPLAIN shows seq scan, cost=0.00..3.05? 

explain 
select * from orders o join customers c on o.customer_id =c.id 
where c.city ='Mumbai'  and o.order_date >'2024-01-01' order by o.total_amount desc;


-- QUERY PLAN
-- Sort (cost=3.04..3.05 rows=5 width=881)
-- Sort Key: o.total_amount DESC
-- -> Hash Join (cost=1.12..2.98 rows=5 width=881)
-- Hash Cond: (o.customer_id = c.id)
-- -> Seq Scan on orders o (cost=0.00..1.66 rows=53 width=21)
-- Filter: (order_date > '2024-01-01'::date)
-- -> Hash (cost=1.11..1.11 rows=1 width=860)
-- -> Seq Scan on customers c (cost=0.00..1.11 rows=1 width=860)
-- Filter: ((city)::text = 'Mumbai'::text)


/*markdown
# Q4
Bank transfer (accounts: id, balance; transactions: id, from_account, to_account, amount, created_at): 

(a) Transaction: deduct 5000 from account 101, credit 5000 to account 202, insert a transactions record. Rollback if balance < 0. 

(b) Add a check so insufficient funds triggers rollback and error message. 

(c) Explain 'dirty read', 'non-repeatable read', and 'phantom read'. Which isolation level prevents each? 

(d) Explain optimistic vs pessimistic locking. Give a real-world scenario where each is appropriate. 

(e) Predict the result: -- accounts: (1,5000),(2,5000) BEGIN; UPDATE accounts SET balance=balance-1000 WHERE id=1; UPDATE accounts SET balance=balance+1000 WHERE id=2; COMMIT; SELECT balance FROM accounts ORDER BY id; 


*/

CREATE TABLE accounts (
    id INT PRIMARY KEY,
    balance NUMERIC(10,2) NOT NULL
);

-- Insert account data

INSERT INTO accounts (id, balance)
VALUES
(101, 10000),
(202, 5000);


-- Create transactions table

CREATE TABLE transactions (
    id SERIAL PRIMARY KEY,
    from_account INT,
    to_account INT,
    amount NUMERIC(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- (a)
begin;

update accounts
set balance = balance-5000
where id =101;

update accounts
set balance = balance+5000
where id = 202;

insert into transactions ( from_account  , to_account , amount) values (101,202,5000);

commit;

-- (b)
-- check insufficient funds and rollback with error message
do $$
declare current_balance numeric;
    transfer_amount numeric :=5000;
BEGIN
   select balance into current_balance from accounts
   where id =101 for update;

   if current_balance <transfer_amount then raise exception
   'insufficient funds . avaliable : % , required : %',current_balance , transfer_amount;
   end if;

   UPDATE accounts
    SET balance = balance - transfer_amount
    WHERE id = 101;

    UPDATE accounts
    SET balance = balance + transfer_amount
    WHERE id = 202;

    INSERT INTO transactions (from_account, to_account, amount)
    VALUES (101, 202, transfer_amount);

end $$;

-- (c)
-- Dirty Read:
-- A dirty read occurs when one transaction reads data that has been
-- changed by another transaction but has not been committed yet.
-- If the first transaction rolls back, the value read by the second
-- transaction was never permanently saved.
-- READ COMMITTED and stronger isolation levels prevent dirty reads.
-- In PostgreSQL, READ UNCOMMITTED behaves the same as READ COMMITTED,
-- so PostgreSQL does not allow dirty reads.

-- Non-Repeatable Read:
-- A non-repeatable read occurs when a transaction reads the same row
-- twice and gets different values because another transaction changed
-- and committed the row between the two reads.
-- REPEATABLE READ and SERIALIZABLE prevent non-repeatable reads.

-- Phantom Read:
-- A phantom read occurs when a transaction executes the same query
-- twice and gets a different set of rows because another transaction
-- inserted or deleted rows that match the query condition.
-- SERIALIZABLE prevents phantom reads. PostgreSQL's REPEATABLE READ
-- also prevents ordinary phantom reads because it uses a consistent
-- transaction snapshot.

-- (d)
-- Optimistic Locking:
-- Optimistic locking assumes that conflicts between transactions
-- are uncommon. Transactions are allowed to proceed without locking
-- the data immediately. Before updating, the system checks whether
-- another transaction has changed the data. If a conflict is found,
-- the transaction can be rejected or retried.
-- Real-world example:
-- Online shopping inventory can use optimistic locking. If two users
-- try to purchase the same product, a version number can be checked
-- before updating the stock. If another transaction changed the stock
-- first, the update fails and can be retried.

-- Pessimistic Locking:
-- Pessimistic locking assumes that conflicts are likely to happen.
-- The data is locked before it is read or modified, preventing other
-- transactions from changing the same data until the lock is released.
-- In PostgreSQL, SELECT ... FOR UPDATE can be used for row locking.
-- Real-world example:
-- Bank transfers are suitable for pessimistic locking. When transferring
-- money, the account row can be locked using FOR UPDATE so that another
-- transaction cannot modify the same account balance at the same time.

--(e) Predict the result: 
-- accounts: (1,5000),(2,5000) 
BEGIN; 
UPDATE accounts 
SET balance=balance-1000 
WHERE id=1; 
UPDATE accounts 
SET balance=balance+1000 
WHERE id=2; 
COMMIT; 
SELECT balance 
FROM accounts ORDER BY id; 
-- predicted output :
balance
4000
6000

/*markdown
# Q5
Designing a data warehouse for the e-commerce platform: 

(a) Design a star schema: name fact table and at least 3 dimension tables. List columns with PKs and FKs. Explain your choices. 

(b) CREATE TABLE for dim_customer with SCD Type 2 columns: customer_key, customer_id, name, email, city, effective_from, effective_to (nullable), is_current. 

(c) SQL to handle customer changing city 'Delhi' to 'Pune': UPDATE to expire old record, INSERT new version with is_current = true. 

(d) Explain how snowflake schema differs from star schema. When would you choose snowflake? Give one concrete trade-off. 

(e) Predict the result: -- dim_customer: (key=1,cust_id=101,city='Delhi',is_current=TRUE) UPDATE dim_customer SET effective_to='2024-06-01', is_current=FALSE WHERE customer_key=1; INSERT INTO dim_customer VALUES (2,101,'Priya','p@x.com','Pune','2024-06-01',NULL,TRUE); SELECT customer_key,city,is_current FROM dim_customer WHERE customer_id=101 ORDER BY customer_key; 
*/

/*markdown
-- (a)
star schema design 
dimension -1 : customer   , stores customer information

dim_customer:
customer_key (Pk)
customer_id 
name 
email
city
effective_from
effective_to
is_current

dimension 2 : product   , stores the product information

dim_product:
product_key (pk)
product_id 
product_name 
category
price

dimension 3 : date  , stores the date related information

dim_date:
date_key (pk)
full_date 
day
month
year


fact_table:   sales  , stores sales transcations and references the dimensions

fact_table:
sale_id (pk)
customer_key (fk)
product_key (fk)
date_key (fk)
quantity
amount


*/

-- (b)
-- create customer dimension using scd type 2

create table dim_customer(
    customer_key int primary key,
    customer_id int not null ,
    name varchar(100),
    email varchar(150),
    city varchar(100),
    effective_from DATE NOT NULL,
    effective_to DATE,
    is_current BOOLEAN NOT NULL
);
-- Sample records for dim_customer

INSERT INTO dim_customer (
    customer_key,
    customer_id,
    name,
    email,
    city,
    effective_from,
    effective_to,
    is_current
)
VALUES
(1, 101, 'Priya', 'p@x.com', 'Delhi', '2024-01-01', NULL, TRUE),
(2, 102, 'Rahul', 'r@x.com', 'Mumbai', '2024-01-01', NULL, TRUE),
(3, 103, 'Anita', 'a@x.com', 'Bangalore', '2024-01-01', NULL, TRUE),
(4, 104, 'Arun', 'arun@x.com', 'Chennai', '2024-01-01', NULL, TRUE);

-- (c)
-- customer 101 changes city from delhi to pune

update dim_customer 
set effective_to ='2024-06-01',
is_current = false
where customer_id =101
and is_current=True;

-- insert new pune version
insert into dim_customer(
    customer_key,
    customer_id,
    name,
    email,
    city,
    effective_from,
    effective_to,
    is_current
)
VALUES (
    5,
    101,
    'Priya',
    'p@x.com',
    'Pune',
    '2024-06-01',
    NULL,
    TRUE
);


select * from dim_customer where customer_id = 101

-- (d)

-- Star Schema:
-- A star schema has one central fact table connected directly
-- to multiple dimension tables. Dimension tables are usually
-- denormalized, so the design has fewer tables and fewer joins.
-- Example:
--             dim_customer
--                  |
--                  |
-- dim_product -- fact_sales -- dim_date
--                  |
--               dim_store

-- Snowflake Schema:
-- A snowflake schema is a normalized version of a star schema.
-- Dimension tables are divided into multiple related tables
-- to reduce data redundancy.
-- Example:
-- fact_sales
--     |
-- dim_product
--     |
-- dim_category
--     |
-- dim_department

-- When to choose Snowflake:
-- We choose a snowflake schema when dimensions contain a lot
-- of repeated data or have complex hierarchical relationships.
-- Normalizing the dimensions can reduce data redundancy and
-- improve storage efficiency.

-- Concrete trade-off:
-- Snowflake reduces duplicate data and saves storage, but it
-- requires more tables and JOIN operations, making queries more
-- complex than queries in a star schema.

-- (e) predict output:
-- dim_customer:
-- (key=1, cust_id=101, city='Delhi', is_current=TRUE)

UPDATE dim_customer
SET effective_to='2024-06-01',
    is_current=FALSE
WHERE customer_key=1;

INSERT INTO dim_customer
VALUES (
    2,
    101,
    'Priya',
    'p@x.com',
    'Pune',
    '2024-06-01',
    NULL,
    TRUE
);

SELECT customer_key, city, is_current
FROM dim_customer
WHERE customer_id=101
ORDER BY customer_key;

-- predicted output:
customer_key    city     is_current
    1          delhi       false
    2          pune        true