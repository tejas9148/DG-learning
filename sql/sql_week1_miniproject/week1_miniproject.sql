SELECT current_database();


/*markdown
Set up the sample e-commerce database using the provided seed.sql (or create your own: 5 customers, 20 orders, 10 products). 

Write 10 SELECT queries: aliases, WHERE filters, ORDER BY, LIMIT, and NULL handling (COALESCE, NULLIF, IS NULL). 

Write 8 JOIN queries: INNER, LEFT (with 0-count), FULL OUTER example. 

Write 8 aggregate queries: revenue by city, monthly totals, customer averages with HAVING. 

Write 6 subquery queries: scalar subquery, correlated, EXISTS, NOT EXISTS, and derived table. 

Write 3 DDL statements: CREATE TABLE for a new table, ALTER TABLE to add column and constraint, explain 3NF redesign. 

For each category, include at least 1 question with output prediction as a comment. 
*/

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    city VARCHAR(50)
);

INSERT INTO customers (customer_id, customer_name, email, phone, city)
VALUES
(1, 'Rahul Sharma', 'rahul@gmail.com', '9876543210', 'Bangalore'),
(2, 'Tejas Kumar', 'tejas@gmail.com', NULL, 'Mumbai'),
(3, 'Ananya Rao', 'ananya@gmail.com', '9988776655', 'Bangalore'),
(4, 'Arjun Mehta', 'arjun@gmail.com', NULL, 'Delhi'),
(5, 'Priya Singh', 'priya@gmail.com', '9123456780', 'Chennai');


CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE
);

INSERT INTO categories (category_id, category_name)
VALUES
(1, 'Electronics'),
(2, 'Clothing'),
(3, 'Books'),
(4, 'Home');

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category_id INT NOT NULL,
    price NUMERIC(10,2),
    stock INT NOT NULL,
    FOREIGN KEY (category_id) REFERENCES categories(category_id),
    CHECK (price >= 0),
    CHECK (stock >= 0)
);

INSERT INTO products (product_id, product_name, category_id, price, stock)
VALUES
(101, 'Laptop', 1, 55000.00, 10),
(102, 'Wireless Mouse', 1, 1200.00, 50),
(103, 'Keyboard', 1, 1800.00, 35),
(104, 'Headphones', 1, 2500.00, 25),
(105, 'T-Shirt', 2, 800.00, 60),
(106, 'Jeans', 2, 1800.00, 40),
(107, 'SQL Book', 3, 650.00, 30),
(108, 'Python Book', 3, 750.00, 20),
(109, 'Table Lamp', 4, 1500.00, 15),
(110, 'Coffee Mug', 4, 400.00, 100);


CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

INSERT INTO orders (order_id, customer_id, order_date, status)
VALUES
(1001, 1, '2026-01-05', 'Completed'),
(1002, 2, '2026-01-08', 'Completed'),
(1003, 3, '2026-01-12', 'Completed'),
(1004, 1, '2026-01-18', 'Completed'),
(1005, 4, '2026-01-22', 'Cancelled'),

(1006, 2, '2026-02-03', 'Completed'),
(1007, 3, '2026-02-07', 'Completed'),
(1008, 1, '2026-02-11', 'Completed'),
(1009, 4, '2026-02-15', 'Completed'),
(1010, 2, '2026-02-20', 'Pending'),

(1011, 3, '2026-03-02', 'Completed'),
(1012, 1, '2026-03-06', 'Completed'),
(1013, 4, '2026-03-10', 'Completed'),
(1014, 2, '2026-03-15', 'Completed'),
(1015, 3, '2026-03-20', 'Cancelled'),

(1016, 1, '2026-04-01', 'Completed'),
(1017, 4, '2026-04-05', 'Completed'),
(1018, 2, '2026-04-10', 'Completed'),
(1019, 3, '2026-04-15', 'Completed'),
(1020, 1, '2026-04-20', 'Pending');


CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    CHECK (quantity > 0),
    CHECK (unit_price >= 0)
);

INSERT INTO order_items
(order_item_id, order_id, product_id, quantity, unit_price)
VALUES
(1, 1001, 101, 1, 55000),
(2, 1001, 102, 2, 1200),

(3, 1002, 105, 2, 800),
(4, 1002, 106, 1, 1800),

(5, 1003, 107, 2, 650),
(6, 1003, 108, 1, 750),

(7, 1004, 103, 1, 1800),
(8, 1004, 104, 1, 2500),

(9, 1005, 109, 1, 1500),

(10, 1006, 101, 1, 55000),
(11, 1006, 104, 2, 2500),

(12, 1007, 105, 3, 800),
(13, 1007, 110, 2, 400),

(14, 1008, 102, 1, 1200),
(15, 1008, 103, 2, 1800),

(16, 1009, 109, 2, 1500),
(17, 1009, 110, 3, 400),

(18, 1010, 106, 2, 1800),

(19, 1011, 107, 1, 650),
(20, 1011, 108, 2, 750),

(21, 1012, 101, 1, 55000),

(22, 1013, 104, 1, 2500),
(23, 1013, 109, 1, 1500),

(24, 1014, 105, 2, 800),
(25, 1014, 106, 1, 1800),

(26, 1015, 110, 2, 400),

(27, 1016, 102, 2, 1200),
(28, 1016, 103, 1, 1800),

(29, 1017, 109, 1, 1500),
(30, 1017, 110, 2, 400),

(31, 1018, 101, 1, 55000),
(32, 1018, 104, 1, 2500),

(33, 1019, 107, 2, 650),
(34, 1019, 108, 1, 750),

(35, 1020, 105, 1, 800);

-- Write 10 SELECT queries: aliases, WHERE filters, ORDER BY, LIMIT, and NULL handling (COALESCE, NULLIF, IS NULL). 

-- 1.display customer names and cities
select customer_name as customer ,
city as customer_city
from customers;

-- 2.display customers who live in bangalore
select customer_name , email , city 
from customers where city ='Bangalore';

-- 3.display products priced above 1000 that have atleast 20 units in stock
select product_name , price , stock 
from products where price >1000 and stock >= 20;

-- 4. display all products from highest to lowest price
select product_name  , price from products 
order by price desc;

-- 5.display products ordered by category and then price from highest to loewst
select product_name , category_id , price from products 
order by category_id asc , price desc;

-- 6. display 5 most expensive products
select product_name , price from products 
order by price desc limit 5;

-- 7. find customers whose phone number is missing
select customer_name , phone
from customers where phone is null;

-- 8.display all customer phone numbers and replace null values with 'not avalibale'
select customer_name , coalesce(phone , 'Not avaliable') as phone_number
from customers;

-- 9.convert zero stock values to null and display result using as alias.
select product_name ,price,stock, price/nullif(stock , 0) as price_per_stock_unit
from products;

-- 10. display the three most expensive products that have at least 20 units in stock
select product_name as product,
price as product_price,
stock
from products where stock>=20 
order by product_price desc limit 3;

-- Write 8 JOIN queries: INNER, LEFT (with 0-count), FULL OUTER example. 

-- Q11 . Display customers who have placed orders along with their order IDs.
select c.customer_name , o.order_id , o.order_date
from customers c inner join orders o on c.customer_id =o.customer_id;

-- Q12. display each order with product purchased and its quantity
select o.order_id , p.product_name , oi.quantity , oi.unit_price
from orders o inner join order_items oi on o.order_id =oi.order_id 
inner join products p on oi.product_id = p.product_id;

-- Q13.  Display customer name, order ID, product name, and quantity purchased.
select c.customer_id , o.order_id , p.product_name , oi.quantity
from customers c 
inner join orders o on c.customer_id =o.customer_id inner join order_items oi on o.order_id =oi.order_id
inner join products p on oi.product_id =p.product_id;

-- Q14. Display all customers and their orders, including customers
select c.customer_name , o.order_id ,o.order_date 
from customers c left join orders o on c.customer_id =o.customer_id;

-- Q15.Find customers who have placed zero orders.
select c.customer_id , c.customer_name , count(o.order_id) as order_count
from customers c left join orders o on c.customer_id = o.customer_id
group by c.customer_id , c.customer_name having count(o.order_id)=0;

-- Q16. display every customer and the number of orders they have placed
select c.customer_name , count(o.order_id) as order_count
from customers c left join orders o on c.customer_id = o.customer_id
group by c.customer_id , c.customer_name order by order_count desc;

-- Q17.Display all products and their order items if they have been ordered.
select p.product_name , oi.order_id , oi.quantity
from order_items oi right join products p on oi.product_id=p.product_id;

-- Q18.Display all customers and all orders, including unmatched records
select c.customer_id , c.customer_name , o.order_id , o.customer_id as order_customer_id
from customers c full outer join orders o on c.customer_id =o.customer_id;

/*markdown
Write 8 aggregate queries: revenue by city, monthly totals, customer averages with HAVING.
*/

-- Q 19.find the total number of orders
select count(*) total_orders from orders;

-- Q20.calculate the total revenue generated by each customer city 
select c.city ,sum (oi.quantity*oi.unit_price) as total_revenue
from customers c inner join orders o on c.customer_id=o.customer_id inner join order_items oi on o.order_id = oi.order_id
group by c.city
order by total_revenue desc;

-- Q21. calculate total_revenue generated in each month
select date_trunc('month',o.order_date) as month,
sum(oi.quantity*oi.unit_price) monthly_revenue
from orders o inner join order_items oi on o.order_id = oi.order_id
group by date_trunc('month',o.order_date)
order by month;

-- Q22.Calculate the average order value for each customer.
select c.customer_name , avg(order_totals.order_value) as average_order_value
from customers c inner join(
    select o.order_id , o.customer_id , sum(oi.quantity * oi.unit_price) as order_value
    from orders o inner join order_items oi on o.order_id=oi.order_id group by o.order_id ,o.customer_id
) as order_totals
on c.customer_id = order_totals.customer_id group by c.customer_id , c.customer_name
order by average_order_value desc;

-- Q23. find customers who have placed more than 4 orders 
select c.customer_name , count(o.order_id ) as order_count
from customers c inner join orders o on c.customer_id = o.customer_id group by c.customer_id , c.customer_name 
having count(o.order_id)>4
order by order_count desc;

-- Q24.Calculate the average product price for each category.
select c.category_name , avg(p.price) as average_price
from categories c inner join products p on c.category_id = p.category_id group by c.category_id , c.category_name 
order by average_price desc;

-- Q25. calculate the avegrage product price for each category
select max(price) maximum_price , min(price) minium_price from products;

-- Q26. Find customers whose average order value is greater than 10000.
select c.customer_name , avg(order_totals.order_value) as average_order_value
from customers c inner join(
    select o.order_id , o.customer_id , sum(oi.quantity * oi.unit_price) as order_value
    from orders o inner join order_items oi on o.order_id=oi.order_id group by o.order_id ,o.customer_id
) as order_totals
on c.customer_id = order_totals.customer_id group by c.customer_id , c.customer_name  having avg(order_totals.order_value)>10000
order by average_order_value desc;

/*markdown
Write 6 subquery queries: scalar subquery, correlated, EXISTS, NOT EXISTS, and derived table. 
*/

-- Q27. Find products whose price is higher than the average product price.
select product_name , price from products
where price > (
    select avg(price) from products
) order by price desc;

-- Q28. Find the product or products with the highest price.
select product_name  , price from products
where price = (
    select max(price) from products
);

-- Q29. Find products whose price is greater than the average price of their own categoru
select p.product_name , p.category_id ,p.price
from products p
where p.price > (
    select avg(p2.price) from products p2 where p2.category_id = p.category_id
);

-- Q30 . Find customers who have placed at least one order.
select c.customer_id , c.customer_name from customers c 
where exists (
    select 1 from orders o where c.customer_id=o.customer_id
);

-- Q31. find customers who have never placed an order
select c.customer_id , c.customer_name from customers c 
where not exists (
    select 1 from orders o where o.customer_id = c.customer_id
);

-- Q32.Find customers whose total spending is greater than 20000.
select c.customer_name , customer_totals.total_spending
from customers c  
inner join (
    select o.customer_id , sum(oi.quantity*oi.unit_price) as total_spending
    from orders o 
    inner join order_items oi on o.order_id=oi.order_id group by o.customer_id
) as customer_totals on c.customer_id=customer_totals.customer_id 
where customer_totals.total_spending >20000
order by customer_totals.total_spending desc;

/*markdown
Write 3 DDL statements: CREATE TABLE for a new table, ALTER TABLE to add column and constraint, explain 3NF redesign. 
*/

-- Q33. Create a payments table to store payment information for orders.
create table if not exists payments (
    payment_id int primary key , order_id int not null UNIQUE,
    payment_method varchar(30) not null ,payment_status VARCHAR(20) NOT NULL, amount decimal(10,2) not null ,
    payment_date date not null,
     CONSTRAINT fk_payment_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id),

    CONSTRAINT chk_payment_amount
        CHECK (amount > 0),

    CONSTRAINT chk_payment_status
        CHECK (payment_status IN ('Pending', 'Completed', 'Failed'))
);


-- Q34. Add a transaction reference column to the payments table.
alter table payments
add column transcation_references varchar(100);



-- Q35. Add a UNIQUE constraint to transaction_reference.
alter table payments 
add constraint uq_transcation_references
unique(transcation_references);

/*markdown
For each category, include at least 1 question with output prediction as a comment. 
*/

-- Display the 5 most expensive products.
-- Predicted output: The query should return exactly 5 products,ordered from the highest price to the lowest price.

SELECT product_name, price
FROM products
ORDER BY price DESC
LIMIT 5;

--Display the 5 most expensive products.
-- Predicted output: The query  returns exactly 5 products,
-- ordered from the highest price to the lowest price.

SELECT product_name, price
FROM products
ORDER BY price DESC
LIMIT 5;

--  Find the total number of orders.
-- Predicted output: The query  returns one row with total_orders = 20.

SELECT COUNT(*) AS total_orders
FROM orders;

-- Find the product or products with the highest price.
-- Predicted output: This query  returns the product(s) whose price equals the maximum price in the products table.

SELECT product_name, price
FROM products
WHERE price = (
    SELECT MAX(price)
    FROM products
);

--  Create a payments table to store payment information for orders.
-- Predicted output: The payments table will be created successfully
-- with a primary key, foreign key, UNIQUE constraint, and CHECK constraints.

CREATE TABLE IF NOT EXISTS payments (
    payment_id INT PRIMARY KEY,
    order_id INT NOT NULL UNIQUE,
    payment_method VARCHAR(30) NOT NULL,
    payment_status VARCHAR(20) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_date DATE NOT NULL,

    CONSTRAINT fk_payment_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id),

    CONSTRAINT chk_payment_amount
        CHECK (amount > 0),

    CONSTRAINT chk_payment_status
        CHECK (payment_status IN ('Pending', 'Completed', 'Failed'))
);