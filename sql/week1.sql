/*markdown


# Q1
Topic: SELECT, WHERE, ORDER BY, LIMIT, Aliases & NULL Handling 

Using a products table (id, name, category, price, stock_qty, supplier_id -- supplier_id may be NULL): 

(a) List all 'Electronics' products costing more than 500, ordered by price descending. Alias name as product_name, price as unit_price. 

(b) Find the 5 most expensive products overall. 

(c) Use COALESCE to show supplier_id if available, otherwise 'No Supplier'. Use NULLIF to return NULL if stock_qty = 0. 

(d) Find products where supplier_id IS NULL and where IS NOT NULL. Show counts using COUNT(). 

(e) Predict the result set: -- products: (1,'Phone',999,NULL),(2,'Laptop',1500,10),(3,'Tablet',500,NULL) SELECT name, COALESCE(supplier_id::text,'No Supplier') AS supplier, NULLIF(price,500) AS price FROM products ORDER BY price DESC NULLS LAST; 



*/

SELECT current_database();

-- (a)
CREATE TABLE products (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    category VARCHAR(50),
    price NUMERIC(10,2),
    stock_qty INT,
    supplier_id INT
);

INSERT INTO products
    (id, name, category, price, stock_qty, supplier_id)
VALUES
    (1, 'iPhone 15', 'Electronics', 999, 25, 101),
    (2, 'Samsung Galaxy S24', 'Electronics', 899, 15, 102),
    (3, 'MacBook Air', 'Electronics', 1299, 10, 103),
    (4, 'Dell Laptop', 'Electronics', 850, 8, NULL),
    (5, 'iPad', 'Electronics', 599, 20, 101),
    (6, 'Wireless Mouse', 'Electronics', 45, 50, 104),
    (7, 'Mechanical Keyboard', 'Electronics', 120, 30, NULL),
    (8, 'Sony Headphones', 'Electronics', 550, 12, 105),
    (9, 'Gaming Monitor', 'Electronics', 750, 7, 106),
    (10, 'Smart Watch', 'Electronics', 500, 0, NULL),
    (11, 'Office Chair', 'Furniture', 300, 15, 107),
    (12, 'Standing Desk', 'Furniture', 650, 5, NULL),
    (13, 'Bookshelf', 'Furniture', 250, 10, 108),
    (14, 'Coffee Table', 'Furniture', 400, 0, NULL),
    (15, 'Desk Lamp', 'Home', 80, 25, 109);

-- (a)
select name as product_name , price as unit_price
from products 
where category ='Electronics'
and price>500 
order by price desc;

-- (b)
select * from products order by price desc limit 5;




-- (c)
SELECT
    name, COALESCE(CAST(supplier_id AS CHAR), 'No Supplier') AS supplier,
    NULLIF(stock_qty, 0) AS stock_qty
FROM products

-- (d)
select * from products where supplier_id is NULL;

select * from products where supplier_id is not NULL;

SELECT
    COUNT(CASE WHEN supplier_id IS NULL THEN 1 END) AS no_supplier_count,
    COUNT(CASE WHEN supplier_id IS NOT NULL THEN 1 END) AS supplier_count
FROM products;

-- (e)
-- (1,'Phone',999,NULL),(2,'Laptop',1500,10),(3,'Tablet',500,NULL) 

SELECT name, 
COALESCE(supplier_id::text,'No Supplier') AS supplier, 
NULLIF(price,500) AS price 
FROM products 
ORDER BY price DESC NULLS LAST;

-- predicted output
-- name     supplier      price
-- Laptop   10            1500
-- Phone    No Supplier   999
-- Tablet   No Supplier   NULL



/*markdown
# Q2
Using orders (id, customer_id, order_date, total_amount) and customers (id, name, city): 

(a) Show city, number of customers, and total revenue. Only include cities with revenue > 10000. Sort by revenue descending. 

(b) Find the month with the highest total order amount. Group by month using DATE_TRUNC or EXTRACT. 

(c) Average order amount per customer. Only show customers with 3+ orders AND average > 500. 

(d) Count distinct customers who placed an order each month of 2024. 

(e) Predict the result set: -- orders: (1,'Mumbai',500),(2,'Mumbai',300),(3,'Delhi',800),(4,'Delhi',400),(5,'Mumbai',700) SELECT city, COUNT(*) cnt, SUM(total_amount) rev FROM orders GROUP BY city HAVING SUM(total_amount)>1000 ORDER BY rev DESC; 
*/

CREATE TABLE customers (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    city VARCHAR(50)
);

CREATE TABLE orders (
    id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount NUMERIC(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);

INSERT INTO customers (id, name, city)
VALUES
    (1, 'Rahul', 'Mumbai'),
    (2, 'Priya', 'Mumbai'),
    (3, 'Amit', 'Delhi'),
    (4, 'Sneha', 'Delhi'),
    (5, 'Arjun', 'Bangalore'),
    (6, 'Neha', 'Bangalore'),
    (7, 'Karan', 'Mumbai'),
    (8, 'Pooja', 'Pune');

INSERT INTO orders (id, customer_id, order_date, total_amount)
VALUES
    (1, 1, '2024-01-10', 1200),
    (2, 1, '2024-02-15', 800),
    (3, 1, '2024-03-20', 1500),
    (4, 1, '2024-04-05', 700),

    (5, 2, '2024-01-12', 2000),
    (6, 2, '2024-02-20', 1800),
    (7, 2, '2024-03-25', 2200),

    (8, 3, '2024-01-18', 3000),
    (9, 3, '2024-03-10', 2500),
    (10, 3, '2024-05-15', 1800),

    (11, 4, '2024-02-05', 1500),
    (12, 4, '2024-04-12', 2000),

    (13, 5, '2024-01-25', 500),
    (14, 5, '2024-02-10', 700),
    (15, 5, '2024-03-15', 600),


    (16, 6, '2024-04-20', 1200),
    (17, 6, '2024-05-10', 1500),

    (18, 7, '2024-01-30', 2500),
    (19, 7, '2024-03-05', 3000),
    (20, 7, '2024-06-15', 2000),

    (21, 8, '2024-02-15', 400),
    (22, 8, '2024-05-20', 600);

select * from customers;
select * from orders;

-- (a)
select c.city , count(distinct c.id) as number_of_customers,
sum(o.total_amount) as total_revenue
from customers c join orders o on c.id = o.customer_id
group by c.city having sum(o.total_amount)>10000
order by total_revenue desc;

-- (b)
select date_trunc('month',order_date) as month ,
sum(total_amount) as total_revenue
from orders
group by date_trunc('month' ,order_date)
order by total_revenue desc limit 1;

-- (c)
select c.id , c.name , count(o.id) as order_count , avg(o.total_amount) as average_order_amount
from customers c 
join orders o on c.id = o.customer_id
group by c.id , c.name
having count(o.id)>=3 and avg(o.total_amount)>500;

-- (d)
SELECT
    TO_CHAR(
        DATE_TRUNC('month', order_date AT TIME ZONE 'Asia/Kolkata'),
        'YYYY-MM'
    ) AS month,
    COUNT(DISTINCT customer_id) AS distinct_customers
FROM orders
WHERE order_date >= '2024-01-01'
  AND order_date < '2025-01-01'
GROUP BY DATE_TRUNC('month', order_date AT TIME ZONE 'Asia/Kolkata')
ORDER BY DATE_TRUNC('month', order_date AT TIME ZONE 'Asia/Kolkata');

-- (d) predict output
-- (e) Predict the result set: -- orders: 
-- (1,'Mumbai',500),(2,'Mumbai',300),(3,'Delhi',800),(4,'Delhi',400),(5,'Mumbai',700) 
SELECT city, COUNT(*) cnt, SUM(total_amount) rev 
FROM orders 
GROUP BY city 
HAVING SUM(total_amount)>1000 
ORDER BY rev DESC

-- predicted output
Mumbai  3   1500
Delhi   2   1200



/*markdown
# Q3

Using customers, orders, and products tables: 

(a) INNER JOIN: customer name, order date, total amount for all 2024 orders. 

(b) LEFT JOIN: ALL customers and their order count (show 0 if no orders). Explain LEFT vs INNER in a comment. 

(c) Find products that have NEVER appeared in any order. Use LEFT JOIN + IS NULL or NOT EXISTS -- explain your choice. 

(d) Write a FULL OUTER JOIN example and explain which rows appear that would NOT appear in INNER, LEFT, or RIGHT JOINs. 

(e) Predict the result set: -- customers: (1,'Alice'),(2,'Bob'),(3,'Carol') -- orders: (101,1,500),(102,1,300) SELECT c.name, COUNT(o.id) AS order_count FROM customers c LEFT JOIN orders o ON c.id=o.customer_id GROUP BY c.name ORDER BY c.name; 



*/

CREATE TABLE order_items (
    order_id INT,
    product_id INT,
    quantity INT
);
INSERT INTO order_items (order_id, product_id, quantity)
VALUES
    (1, 1, 1),
    (2, 2, 1),
    (3, 3, 1),
    (4, 4, 1),
    (5, 5, 2),
    (6, 6, 1),
    (7, 7, 1),
    (8, 1, 1),
    (9, 3, 1),
    (10, 8, 2),
    (11, 2, 1),
    (12, 9, 1),
    (13, 10, 2);

ALTER TABLE orders
ADD COLUMN product_id INT;

UPDATE orders
SET product_id = CASE id
    WHEN 1 THEN 1
    WHEN 2 THEN 2
    WHEN 3 THEN 3
    WHEN 4 THEN 4
    WHEN 5 THEN 5
    WHEN 6 THEN 6
    WHEN 7 THEN 7
    WHEN 8 THEN 1
    WHEN 9 THEN 3
    WHEN 10 THEN 8
    WHEN 11 THEN 2
    WHEN 12 THEN 9
    WHEN 13 THEN 10
    WHEN 14 THEN 1
    WHEN 15 THEN 5
    WHEN 16 THEN 6
    WHEN 17 THEN 7
    WHEN 18 THEN 2
    WHEN 19 THEN 3
    WHEN 20 THEN 9
    WHEN 21 THEN 8
    WHEN 22 THEN 10
END;

-- (a)

select c.name , o.order_date , o.total_amount from customers c inner join orders o
on c.id = o.customer_id where o.order_date >='2024-01-01' and o.order_date <'2025-01-01' order by o.order_date;
 

-- (b)

select c.id , c.name , count(o.id) as order_count  from customers c left join orders o 
on c.id = o.customer_id group by c.id , c.name order by c.name 

-- left join return all the rows from left table and only matching rows from right table , if there is no match the right table columns contain null
-- inner join return only the matching rows from both the tables

ALTER TABLE orders
DROP CONSTRAINT orders_customer_id_fkey;

INSERT INTO customers (id, name, city)
VALUES (9, 'Raj', 'Mumbai');
INSERT INTO orders
    (id, customer_id, order_date, total_amount, product_id)
VALUES
    (23, 99, '2024-07-10', 1000, 1);

-- (c)

select p.id , p.name from products p left join orders o
on p.id = o.product_id where o.product_id is null order by p.id;

-- (d)
select c.id as customer_id ,c.name , o.id as order_id , o.customer_id as order_customer_id , o.total_amount
from customers c full outer join orders o on c.id = o.customer_id
order by c.id , o.id;

--  explain which rows appear that would NOT appear in INNER, LEFT, or RIGHT JOINs.
-- FULL OUTER JOIN returns all matching and non-matching rows from both tables.

-- 9 | Raj | NULL | NULL | NULL
-- This row will NOT appear in INNER JOIN or RIGHT JOIN
-- because Raj has no matching order.
-- It WILL appear in LEFT JOIN because customers is the left table.

-- NULL | NULL | 23 | 99 | 1000.00
-- This row will NOT appear in INNER JOIN or LEFT JOIN
-- because order 23 has no matching customer.
-- It WILL appear in RIGHT JOIN because orders is the right table.

/*markdown

*/

-- (e) Predict the result set: 
-- customers: (1,'Alice'),(2,'Bob'),(3,'Carol') 
-- orders: (101,1,500),(102,1,300) 
SELECT c.name, COUNT(o.id) AS order_count 
FROM customers c LEFT JOIN orders o ON c.id=o.customer_id 
GROUP BY c.name ORDER BY c.name; 

-- output 
name    order_count
Alice     2
Bob       0 
Carol     0



/*markdown

# Q4
Using the same e-commerce tables: 

(a) Scalar subquery in SELECT: each order alongside the overall average order amount. 

(b) Use EXISTS to find customers who placed an order in the last 30 days. Rewrite using IN. Explain which is more performant on large tables and why. 

(c) Use NOT EXISTS to find customers who have NEVER placed an order. Compare with NOT IN -- explain the NULL trap. 

(d) Use a derived table (subquery in FROM) to calculate per-customer totals, then select customers above the overall average. 

(e) Predict the result set: -- orders: (1,100),(2,200),(3,300),(4,400),(5,500) SELECT id, total_amount,   (SELECT AVG(total_amount) FROM orders) AS avg FROM orders WHERE total_amount > (SELECT AVG(total_amount) FROM orders); 



*/

-- 2026 orders from January to August 26

INSERT INTO orders
    (id, customer_id, order_date, total_amount, product_id)
VALUES
    -- January
    (24, 1, '2026-01-05', 1200, 1),
    (25, 2, '2026-01-18', 1800, 3),
    (26, 3, '2026-01-27', 950, 5),

    -- February
    (27, 4, '2026-02-08', 2200, 9),
    (28, 5, '2026-02-19', 700, 2),
    (29, 6, '2026-02-25', 1500, 8),

    -- March
    (30, 1, '2026-03-04', 2500, 3),
    (31, 7, '2026-03-15', 3200, 9),
    (32, 8, '2026-03-28', 600, 6),

    -- April
    (33, 2, '2026-04-07', 1400, 1),
    (34, 3, '2026-04-21', 2800, 3),
    (35, 5, '2026-04-29', 900, 7),

    -- May
    (36, 4, '2026-05-06', 1700, 8),
    (37, 6, '2026-05-18', 2100, 9),
    (38, 7, '2026-05-30', 1300, 5),

    -- June
    (39, 1, '2026-06-05', 3000, 3),
    (40, 8, '2026-06-14', 800, 6),
    (41, 2, '2026-06-25', 1900, 1),

    -- July
    (42, 3, '2026-07-03', 1600, 2),
    (43, 5, '2026-07-17', 2400, 9),
    (44, 7, '2026-07-28', 1100, 8),

    -- August
    (45, 4, '2026-08-02', 2000, 3),
    (46, 6, '2026-08-10', 1250, 1),
    (47, 8, '2026-08-15', 900, 6),
    (48, 1, '2026-08-20', 3500, 3),
    (49, 2, '2026-08-25', 2200, 9);

-- (a)
select id , total_amount  ,(select avg(total_amount) from orders ) as avg_order_amount
from orders order by id;

-- (b)
-- using exists
select c.id , c.name from customers c where exists (
    select 1 from orders o 
    where o.customer_id =c.id and o.order_date >= CURRENT_DATE - INTERVAL '30 days'
);

-- using IN
select c.id , c.name from customers c where c.id in ( 
    select o.customer_id from orders o where o.order_date >= CURRENT_DATE - INTERVAL '30 days'
)

--  exists vs IN
--exists : it does matching order exist for this customer
--IN : it checks is this customer id in the list returned by subquery

-- exist can be more efficient when we need to check whether a matching row wxists or not and it can stop after finding the first match




-- (c)
-- using not exists
select c.id , c.name from customers c 
where not exists ( 
    select 1 from orders o where o.customer_id = c.id
);

-- using NOT IN
select c.id , c.name from customers c 
where c.id NOT IN ( select o.customer_id from orders o);


-- NULL trap occurs when we use NOT IN 
-- so when the sub query return null then the comparison can become unknown . where only returns rows when the condition is true 
-- so rows with unkown result is execluded
-- NOT EXISTS is generally safer when null values are possible

-- (d)
select customer_id , customer_total
from ( 
    select customer_id , sum(total_amount) as customer_total
    from orders group by customer_id
) as customer_totals
where customer_total > (
    select avg(customer_total) from (
        select sum(total_amount) as customer_total
        from orders group by customer_id
    ) as averages
);

--(e) Predict the result set: 
-- orders: (1,100),(2,200),(3,300),(4,400),(5,500) 
SELECT id, total_amount,   
(SELECT AVG(total_amount) FROM orders) AS avg 
FROM orders 
WHERE total_amount > (SELECT AVG(total_amount) 
FROM orders);

-- output 
id total_amount  avg
4   400          300
5   500          300

/*markdown
# Q5

Using customers (id, name, email, registration_date) and orders (order_date): 

(a) Show name in UPPER CASE, email in LOWER CASE, and the domain part of the email (everything after '@'). 

(b) Format registration_date as 'DD-Month-YYYY'. Use TO_CHAR or DATE_FORMAT. 

(c) Calculate how many days ago each customer registered. Show customers registered in the last 90 days. 

(d) CASE WHEN label on products: 'Premium' (>1000), 'Standard' (200-1000), 'Budget' (<200). Only show products in at least one order. 

(e) Predict the result set: -- customer: id=1, name='john doe', email='john.doe@gmail.com' SELECT UPPER(name) AS name, LOWER(email) AS email,   SPLIT_PART(email,'@',2) AS domain FROM customers WHERE id=1; 
*/

ALTER TABLE customers
ADD COLUMN email VARCHAR(255);



UPDATE customers
SET email = CASE id
    WHEN 1 THEN 'rahul@gmail.com'
    WHEN 2 THEN 'priya@gmail.com'
    WHEN 3 THEN 'amit@yahoo.com'
    WHEN 4 THEN 'sneha@gmail.com'
    WHEN 5 THEN 'arjun@outlook.com'
    WHEN 6 THEN 'neha@gmail.com'
    WHEN 7 THEN 'karan@yahoo.com'
    WHEN 8 THEN 'pooja@gmail.com'
    WHEN 9 THEN 'raj@gmail.com'
END;

ALTER TABLE customers
ADD COLUMN registration_date DATE;
UPDATE customers
SET registration_date = CASE id
    WHEN 1 THEN DATE '2026-08-20'
    WHEN 2 THEN DATE '2026-07-15'
    WHEN 3 THEN DATE '2026-06-10'
    WHEN 4 THEN DATE '2026-05-20'
    WHEN 5 THEN DATE '2026-04-05'
    WHEN 6 THEN DATE '2026-03-18'
    WHEN 7 THEN DATE '2026-08-01'
    WHEN 8 THEN DATE '2026-01-10'
    WHEN 9 THEN DATE '2025-12-15'
END;

-- (a)
select upper(name) as name , lower(email) as email,
split_part(email , '@' , 2) as domain
from customers;

-- (b)
select name , registration_date , to_char(registration_date,'DD-Month-YYYY') as formatted_date
from customers;

-- (c)
select name , registration_date , current_date - registration_date as days_ago
from customers
where registration_date >= current_date-interval '90 days'
order by days_ago;

-- (d)
select distinct p.id , p.name , p.price , 
case when p.price >1000 then 'premium'
     when p.price >=200 then 'standard'
     else 'Budget'
    end as price_category
from products p inner join orders o 
on p.id = o.product_id 
order by p.id;

-- predict output
--(e) Predict the result set: 
-- customer: id=1, name='john doe', email='john.doe@gmail.com' 
SELECT UPPER(name) AS name, LOWER(email) AS email,   
SPLIT_PART(email,'@',2) AS domain 
FROM customers 
WHERE id=1; 

-- output:
name     |  email              | domain
JOHN DOE | john.doe@gmail.com  | gmail.com

/*markdown

# Q6

Un-normalized table: orders_flat(order_id, customer_name, customer_email, customer_city, product1_name, product1_price, product2_name, product2_price, salesperson_name, salesperson_region): 

(a) Identify every normalization violation. Label each as 1NF, 2NF, or 3NF violation. 

(b) Redesign into separate tables satisfying 3NF. Name each table and list columns with PKs and FKs. 

(c) Write CREATE TABLE SQL for your 3NF design. Include PRIMARY KEY, FOREIGN KEY, NOT NULL, and CHECK constraints. 

(d) Write ALTER TABLE to: add phone_number VARCHAR(15) to customers, add UNIQUE on email, add CHECK ensuring price > 0. 

(e) Predict which INSERT statements succeed or fail: CREATE TABLE emp(id INT PRIMARY KEY, name VARCHAR(50) NOT NULL, sal DECIMAL CHECK(sal>0)); INSERT INTO emp VALUES (1,'Alice',50000); -- A INSERT INTO emp VALUES (2,NULL,60000);   -- B INSERT INTO emp VALUES (3,'Bob',-100);   -- C 


*/



CREATE TABLE orders_flat (
    order_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    customer_email VARCHAR(255),
    customer_city VARCHAR(100),
    product1_name VARCHAR(100),
    product1_price NUMERIC(10,2),
    product2_name VARCHAR(100),
    product2_price NUMERIC(10,2),
    salesperson_name VARCHAR(100),
    salesperson_region VARCHAR(100)
);
INSERT INTO orders_flat (
    order_id,
    customer_name,
    customer_email,
    customer_city,
    product1_name,
    product1_price,
    product2_name,
    product2_price,
    salesperson_name,
    salesperson_region
)
VALUES
(
    1,
    'Rahul',
    'rahul@gmail.com',
    'Mumbai',
    'iPhone 15',
    999,
    'Wireless Mouse',
    45,
    'Anita',
    'West'
),
(
    2,
    'Priya',
    'priya@gmail.com',
    'Delhi',
    'MacBook Air',
    1299,
    'iPad',
    599,
    'Ravi',
    'North'
),
(
    3,
    'Amit',
    'amit@gmail.com',
    'Delhi',
    'Samsung Galaxy S24',
    899,
    'Sony Headphones',
    550,
    'Anita',
    'West'
),
(
    4,
    'Sneha',
    'sneha@gmail.com',
    'Bangalore',
    'Office Chair',
    300,
    'Standing Desk',
    650,
    'Karan',
    'South'
),
(
    5,
    'Rahul',
    'rahul@gmail.com',
    'Mumbai',
    'Gaming Monitor',
    750,
    'Mechanical Keyboard',
    120,
    'Anita',
    'West'
);


select * from orders_flat

/*markdown
-- (a)
1NF violation:
product1_name/product2_name and product1_price/product2_price are repeating groups
products should be stored as seperate rows.
product columns are repeated 

2NF violation:
customer attributes depends on customers and product attributes depends on products rather than entire order_product key
this creates partial dependicies

3NF violation:
salesperson_region depends on salesperson_name rather than directly on the order creating a transitive dependency



*/

/*markdown
-- (b)
-- redesign the un normalized table into seperate tables satisfying 3NF

1.customers table :
stores customer specific information
primary key : customer_id

customers
customer_id (Pk)
name 
email 
city

2.products table :
stores the product specific information
PK : product_id

products 
product_id (Pk)
name 
price

3.salesperson table:
stores salesperson specific information
PK :salesperson_id

salespersons
salesperson_id (Pk)
name 
region

4.orders table:
stores information about each order
PK : order_id
FK : customer_id references customers(customer_id)
FK : salesperson_id references salespersons(salesperson_id)

orders 
order_id (Pk)
customer_id (Fk)
salesperson_id (Fk)

5. order_items tables
stores which products belong sto which orders
used because one order can have multiple products 
Composite PK : (order_id , product_id)
FK : order_id references orders(order_id)
FK : product_id references products(product_id)

order_items
order_id (PK , Fk)
product_id (PK , FK)
*/

-- (c)

create table customer_3nf ( customer_id INT primary key, 
name varchar(100) not null , 
email varchar(255) not null, 
city varchar(100) not null);

create table products_3nf ( product_id int primary key ,
name varchar(100) not null ,
price numeric (10 ,2 ) not null check (price >0)
);

create table salesperson_3nf (
    salesperson_id int primary key ,
    name varchar(100) not null,
    region varchar(100) not null
);

create table orders_3nf(
    order_id int primary key ,
    customer_id int not null ,
    salesperson_id int not null,

    Foreign Key (customer_id) REFERENCES customer_3nf(customer_id),
    foreign key ( salesperson_id) REFERENCES salesperson_3nf(salesperson_id)
);

create table order_items_3nf (
    order_id int not null,
    product_id int not null ,
    primary key (order_id , product_id),
    Foreign Key (order_id) REFERENCES orders_3nf(order_id),
    foreign key (product_id) REFERENCES products_3nf(product_id)
);



-- (d)
-- phone number to the customer table
alter table customer_3nf add column phone_number varchar(15);

-- add unique constraint to email
alter table customer_3nf add constraint unique_customer_email unique(email);

-- add check for price > 0
alter table products_3nf add constraint positive_product_price check (price > 0);

-- (e) 
Predict which INSERT statements succeed or fail: 
CREATE TABLE emp(id INT PRIMARY KEY, name VARCHAR(50) NOT NULL, sal DECIMAL CHECK(sal>0)); 
INSERT INTO emp VALUES (1,'Alice',50000);   -- A 
INSERT INTO emp VALUES (2,NULL,60000);      -- B 
INSERT INTO emp VALUES (3,'Bob',-100);      -- C

-- insert statement B and C fails  and A succeeds:
-- A succeeds because the id is unique , name is not null and salary is greater than 0
--  B fails beacuse name should be not null but the insert value is null so it will fail
--  C fails beacuse salary should be greater than 0 but the inserted value is negative value so it fails