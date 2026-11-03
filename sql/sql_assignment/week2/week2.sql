/*markdown
1.You are working on a data warehouse for a retail company. The company wants to be able to quickly report on sales by product category, region, and time period. The current database schema is normalized, but this is resulting in slow performance for these reports. How would you denormalize the schema to improve performance? 

*/

/*markdown
To improve reporting performance, I would denormalize the normalized database into a star schema. I would create a central Fact_Sales table containing sales measures such as quantity, sales amount, discount and profit, along with foreign keys to dimension tables.

The dimension tables would include Dim_Product, Dim_Store and Dim_Date. Frequently used attributes such as product category, subcategory and brand can be stored directly in Dim_Product, while city, state and region can be stored in Dim_Store. The date dimension can contain day, month, quarter and year.

This introduces some controlled data redundancy but reduces the number of joins required for analytical queries. For example, a report showing sales by product category, region and month can join the fact table directly with the three dimensions and perform aggregations efficiently.

For very large datasets and frequently executed reports, I could also create pre-aggregated summary tables or materialized views, such as monthly sales by category and region.

However, I would not denormalize the entire database blindly. Excessive denormalization can cause data duplication, increased storage, data inconsistency and maintenance problems. Therefore, denormalization should be applied selectively based on reporting requirements and query patterns
*/

/*markdown
2.Your company has a data warehouse that contains a table of customer orders. You want to create a view that shows the total order value for each customer. How would you create this view? 
*/

/*markdown
We can create a view using the CREATE VIEW statement along with the SUM() aggregate function and GROUP BY clause. The GROUP BY customer_id ensures that all orders belonging to the same customer are grouped together, while SUM(order_value) calculates the total value of those orders.

CREATE VIEW customer_order_totals AS
SELECT
    customer_id,
    SUM(order_value) AS total_order_value
FROM orders
GROUP BY customer_id;

We can then retrieve the results using:

SELECT *
FROM customer_order_totals;

If the orders table contains:

customer_id | order_value
------------+------------
1           | 500
1           | 700
2           | 1000
1           | 300
2           | 500

The view will return:

customer_id | total_order_value
------------+------------------
1           | 1500
2           | 1500

A view is useful because it provides a reusable and simplified interface for reporting without requiring the aggregation query to be written repeatedly. We should not use COUNT() because it counts orders rather than adding their values, and we should not forget the GROUP BY customer_id clause because the requirement is to calculate a separate total for each customer.
*/

/*markdown
3.Your company has a data warehouse that contains a table of employee data. You want to create a procedure that calculates the employee salary history for each employee. How would you create this procedure? 
*/

/*markdown
We can create a stored procedure that processes the employee salary records and stores the salary history in a separate table. The LAG() window function can be used to retrieve the previous salary for each employee, while PARTITION BY employee_id ensures that the calculation is performed separately for every employee.

CREATE OR REPLACE PROCEDURE calculate_salary_history()
LANGUAGE plpgsql
AS $$
BEGIN

    INSERT INTO salary_history
        (
            employee_id,
            effective_date,
            salary,
            previous_salary,
            salary_change
        )
    SELECT
        employee_id,
        effective_date,
        salary,
        LAG(salary) OVER (
            PARTITION BY employee_id
            ORDER BY effective_date
        ) AS previous_salary,
        salary - LAG(salary) OVER (
            PARTITION BY employee_id
            ORDER BY effective_date
        ) AS salary_change
    FROM employee_salary;

END;
$$;

The procedure can be executed using:

CALL calculate_salary_history();

The resulting history can show each employee's current salary, previous salary and salary change over time. PARTITION BY employee_id keeps employees' histories separate, while ORDER BY effective_date ensures that the salary changes are calculated chronologically.

We should avoid mixing records from different employees, overwriting the original salary data, or repeatedly inserting the same records without handling duplicates. In a production data warehouse, the procedure should also be designed for incremental loading or use appropriate keys/upsert logic.
*/

/*markdown
4.Your company has a data warehouse that contains a table of customer data. You want to track changes to the customer data over time. How would you implement a Slowly Changing Dimension (SCD) type 2 for this table? 

 
*/

/*markdown
To implement a Slowly Changing Dimension (SCD) Type 2 for customer data, we should preserve the historical versions of customer records instead of overwriting the existing data. A customer dimension table can contain a surrogate key, customer ID, customer attributes, start date, end date and a current-record flag.

CREATE TABLE dim_customer (
    customer_key SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    customer_name VARCHAR(100),
    city VARCHAR(100),
    state VARCHAR(100),
    start_date DATE NOT NULL,
    end_date DATE,
    is_current BOOLEAN NOT NULL
);

When a new customer is encountered, we insert a new record:

INSERT INTO dim_customer
(
    customer_id,
    customer_name,
    city,
    state,
    start_date,
    end_date,
    is_current
)
VALUES
(
    101,
    'Rahul',
    'Bengaluru',
    'Karnataka',
    CURRENT_DATE,
    NULL,
    TRUE
);

If an existing customer's information changes, we first close the old record:

UPDATE dim_customer
SET
    end_date = CURRENT_DATE - INTERVAL '1 day',
    is_current = FALSE
WHERE customer_id = 101
  AND is_current = TRUE;

Then we insert the new version:

INSERT INTO dim_customer
(
    customer_id,
    customer_name,
    city,
    state,
    start_date,
    end_date,
    is_current
)
VALUES
(
    101,
    'Rahul',
    'Mumbai',
    'Maharashtra',
    CURRENT_DATE,
    NULL,
    TRUE
);

The result will contain both the old and new versions:

customer_key | customer_id | city       | is_current
-------------+-------------+------------+-----------
1             | 101         | Bengaluru  | FALSE
2             | 101         | Mumbai     | TRUE

Thus, SCD Type 2 maintains a complete history of changes while allowing the current customer information to be easily identified using is_current = TRUE.
*/

/*markdown
5.Scenario: You are working on a data warehouse for a social media company. The company wants to be able to track the number of active users on a daily basis. The current database schema is normalized, but this is resulting in slow performance for this report. 

Question: How would you denormalize the schema to improve performance, while still maintaining data integrity?
*/

/*markdown
To improve the performance of Daily Active User (DAU) reports, I would create a denormalized daily activity summary table. Instead of repeatedly joining and scanning large normalized activity tables, the ETL/ELT process would calculate the number of unique active users for each day and store the result.

For example:

CREATE TABLE daily_active_users (
    activity_date DATE PRIMARY KEY,
    active_user_count BIGINT NOT NULL
        CHECK (active_user_count >= 0)
);

The table can be populated from the activity data using:

INSERT INTO daily_active_users
    (activity_date, active_user_count)
SELECT
    DATE(activity_timestamp) AS activity_date,
    COUNT(DISTINCT user_id) AS active_user_count
FROM user_activity
GROUP BY DATE(activity_timestamp);

COUNT(DISTINCT user_id) is important because a user may perform multiple activities during a day but should only be counted once as a Daily Active User.

For ongoing processing, an incremental ETL/ELT process can calculate the DAU for new dates and use an UPSERT to update existing dates when late-arriving activity is received.

The normalized source tables should remain the source of truth, while daily_active_users acts as a derived reporting table. A primary key on activity_date, NOT NULL constraints, validation rules and controlled ETL processing help maintain data integrity.

This approach improves performance because reports can query a small pre-aggregated table instead of repeatedly scanning millions or billions of raw activity records.
*/