/*markdown
# 1.
Query 1 -- Window Functions: RANK(), LAG(), SUM() OVER() with a ROWS BETWEEN frame clause.
*/

select f.order_id , d.full_date , f.total_amount,
rank() over ( order by f.total_amount desc) as revenue_rnk,
lag(f.total_amount) over (order by d.full_date , f.order_id) as previous_order_revenue,
sum(f.total_amount) over (order by d.full_date , f.order_id rows between unbounded preceding and current row) as running_revenue

from fact_orders f join dim_date d on f.date_key = d.date_key
order by d.full_date , f.order_id;

/*markdown
# 2
Query 2 -- CTE Chain: monthly_revenue CTE, mom_growth CTE using LAG, final SELECT with Growth/Decline/Flat label. Add ROLLUP on (category, month). 
*/

-- monthly revenue and month over month growth
with monthly_revenue as (
    select d.year , d.month , d.month_name , sum(total_amount) as revenue 
    from fact_orders f inner join dim_date d on f.date_key = d.date_key
    group by d.year , d.month , d.month_name
),

mom_growth as (
    select year , month , month_name , revenue ,lag(revenue) over ( order by year , month) as previous_month_revenue
    from monthly_revenue
)

select year , month , month_name , revenue , previous_month_revenue,
case when previous_month_revenue is null then NULL
     else round(
        (
        (revenue-previous_month_revenue)/previous_month_revenue
     )*100,2
     )
     end as growth_percentage,
case when previous_month_revenue is null then 'Flat'
    when revenue> previous_month_revenue then 'Growth'
    when revenue < previous_month_revenue then 'Decline'
    else 'Flat'
end as performance

from mom_growth
order by year , month;



-- category and month revenue using roll up
select p.category , d.month , sum(f.total_amount) as revenue
from fact_orders f inner join dim_product p on f.product_key=p.product_key
inner join dim_date as d on f.date_key =d.date_key
group by rollup (p.category , d.month) order by p.category , d.month;

/*markdown
# 3
Query 3 -- Recursive CTE: generate a number series. Show how a recursive CTE would traverse a product category hierarchy. 
*/

with recursive number_series as (
    select 1 as number 
    union all 
    select number+1 from number_series where number<10
)
select number from number_series order by number;

-- category hierarchy
with recursive category_tree as (
    select category_key , category_name , parent_category_key, 0 as level
    from dim_category
    where parent_category_key is NULL

    union ALL

    select c.category_key  , c.category_name , c.parent_category_key,ct.level+1
    from dim_category c inner join category_tree ct on c.parent_category_key=ct.category_key
)
select category_key , category_name , parent_category_key , level
from category_tree order by level , category_key;

/*markdown
# 4
Query 4 -- SCD Update: simulate city change, expire old record, insert new version, show all versions. 
*/

-- scd type 2 :
-- expire old record , insert new version , preserve old version for historical analysis.
begin ;

update dim_customer set effective_to = Date '2026-08-31',
is_current =false
where customer_id ='101' and is_current =true;

INSERT INTO dim_customer (
    customer_id,
    name,
    email,
    city,
    effective_from,
    effective_to,
    is_current
)
VALUES (
    '101',
    'Aarav',
    'aarav@example.com',
    'Bangalore',
    DATE '2026-09-01',
    DATE '9999-12-31',
    TRUE
);

COMMIT;

SELECT
    customer_key,
    customer_id,
    name,
    email,
    city,
    effective_from,
    effective_to,
    is_current

FROM dim_customer

WHERE customer_id = 101

ORDER BY effective_from;

/*markdown
# 5
Query 5 -- Optimization: EXPLAIN ANALYZE before and after adding composite index. Capture both outputs. 
*/

--optimization using explain analyze
explain analyze select customer_key , date_key , product_key , quantity , total_amount
from fact_orders
where customer_key=101
and date_key between 20260101 and 20260331;




CREATE INDEX idx_fact_orders_customer_date
ON fact_orders (customer_key, date_key);

EXPLAIN ANALYZE
SELECT
    customer_key,
    date_key,
    product_key,
    quantity,
    total_amount
FROM fact_orders
WHERE customer_key = 101
  AND date_key BETWEEN 20260101 AND 20260331;