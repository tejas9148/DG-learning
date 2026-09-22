select current_database();

-- create customer dimension table
CREATE TABLE dim_customer (
    customer_key SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150),
    city VARCHAR(100),
    effective_from DATE NOT NULL,
    effective_to DATE,
    is_current BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE UNIQUE INDEX uq_dim_customer_current
ON dim_customer (customer_id)
WHERE is_current = TRUE;

-- create product dimension table
CREATE TABLE dim_product (
    product_key SERIAL PRIMARY KEY,
    product_id INT NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(100) NOT NULL,
    price NUMERIC(10,2) NOT NULL
);

-- create date dimension table
CREATE TABLE dim_date (
    date_key INT PRIMARY KEY,
    full_date DATE NOT NULL,
    day INT NOT NULL,
    month INT NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    quarter INT NOT NULL,
    year INT NOT NULL
);

-- fact orders :
CREATE TABLE fact_orders (
    order_id INT PRIMARY KEY,

    customer_key INT NOT NULL,
    product_key INT NOT NULL,
    date_key INT NOT NULL,

    quantity INT NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL,
    total_amount NUMERIC(12,2) NOT NULL,

    FOREIGN KEY (customer_key)
        REFERENCES dim_customer(customer_key),

    FOREIGN KEY (product_key)
        REFERENCES dim_product(product_key),

    FOREIGN KEY (date_key)
        REFERENCES dim_date(date_key)
);

/*markdown
insert the sample data
*/

-- customer data
INSERT INTO dim_customer
    (customer_id, name, email, city, effective_from, effective_to, is_current)
VALUES
    (101, 'Aarav',  'aarav@example.com',  'Mumbai',    '2026-01-01', NULL, TRUE),
    (102, 'Priya',  'priya@example.com',  'Delhi',     '2026-01-01', NULL, TRUE),
    (103, 'Rahul',  'rahul@example.com',  'Pune',      '2026-01-01', NULL, TRUE),
    (104, 'Sneha',  'sneha@example.com',  'Chennai',   '2026-01-01', NULL, TRUE),
    (105, 'Vikram', 'vikram@example.com', 'Hyderabad', '2026-01-01', NULL, TRUE);

-- product data
INSERT INTO dim_product
    (product_id, product_name, category, price)
VALUES
    (201, 'Laptop',   'Electronics', 60000.00),
    (202, 'Mouse',    'Electronics', 1200.00),
    (203, 'Keyboard', 'Electronics', 2500.00),
    (204, 'T-Shirt',  'Clothing',     900.00),
    (205, 'Shoes',    'Clothing',    3000.00),
    (206, 'Backpack', 'Accessories', 1800.00);

-- date data
INSERT INTO dim_date
    (date_key, full_date, day, month, month_name, quarter, year)
VALUES
    -- January
    (20260105, '2026-01-05', 5,  1, 'January',  1, 2026),
    (20260110, '2026-01-10', 10, 1, 'January',  1, 2026),
    (20260115, '2026-01-15', 15, 1, 'January',  1, 2026),
    (20260120, '2026-01-20', 20, 1, 'January',  1, 2026),
    (20260125, '2026-01-25', 25, 1, 'January',  1, 2026),

    -- February
    (20260205, '2026-02-05', 5,  2, 'February', 1, 2026),
    (20260210, '2026-02-10', 10, 2, 'February', 1, 2026),
    (20260215, '2026-02-15', 15, 2, 'February', 1, 2026),
    (20260220, '2026-02-20', 20, 2, 'February', 1, 2026),
    (20260225, '2026-02-25', 25, 2, 'February', 1, 2026),

    -- March
    (20260305, '2026-03-05', 5,  3, 'March', 1, 2026),
    (20260310, '2026-03-10', 10, 3, 'March', 1, 2026),
    (20260315, '2026-03-15', 15, 3, 'March', 1, 2026),
    (20260320, '2026-03-20', 20, 3, 'March', 1, 2026),
    (20260325, '2026-03-25', 25, 3, 'March', 1, 2026);

-- fact order data
INSERT INTO fact_orders
    (order_id, customer_key, product_key, date_key,
     quantity, unit_price, total_amount)
VALUES

    -- =========================
    -- JANUARY
    -- =========================

    (1,  1, 1, 20260105, 1, 60000.00, 60000.00),
    (2,  2, 2, 20260110, 2,  1200.00,  2400.00),
    (3,  3, 4, 20260115, 3,   900.00,  2700.00),
    (4,  4, 5, 20260120, 1,  3000.00,  3000.00),
    (5,  5, 6, 20260125, 2,  1800.00,  3600.00),
    (6,  1, 3, 20260125, 1,  2500.00,  2500.00),
    (7,  2, 1, 20260125, 1, 60000.00, 60000.00),

    -- =========================
    -- FEBRUARY
    -- =========================

    (8,  3, 1, 20260205, 1, 60000.00, 60000.00),
    (9,  4, 2, 20260210, 3,  1200.00,  3600.00),
    (10, 5, 3, 20260215, 2,  2500.00,  5000.00),
    (11, 1, 4, 20260220, 4,   900.00,  3600.00),
    (12, 2, 5, 20260225, 2,  3000.00,  6000.00),
    (13, 3, 6, 20260225, 3,  1800.00,  5400.00),
    (14, 4, 1, 20260225, 1, 60000.00, 60000.00),

    -- =========================
    -- MARCH
    -- =========================

    (15, 5, 1, 20260305, 1, 60000.00, 60000.00),
    (16, 1, 2, 20260310, 2,  1200.00,  2400.00),
    (17, 2, 3, 20260315, 1,  2500.00,  2500.00),
    (18, 3, 4, 20260320, 5,   900.00,  4500.00),
    (19, 4, 5, 20260325, 2,  3000.00,  6000.00),
    (20, 5, 6, 20260325, 4,  1800.00,  7200.00),
    (21, 1, 1, 20260325, 1, 60000.00, 60000.00);

CREATE TABLE dim_category (
    category_key INT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    parent_category_key INT REFERENCES dim_category(category_key)
);

INSERT INTO dim_category
    (category_key, category_name, parent_category_key)
VALUES
    (1, 'Electronics', NULL),
    (2, 'Computers', 1),
    (3, 'Laptops', 2),
    (4, 'Desktops', 2),
    (5, 'Phones', 1),
    (6, 'Accessories', 1);

select * from dim_customer

