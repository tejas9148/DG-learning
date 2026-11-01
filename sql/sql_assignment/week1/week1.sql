/*markdown
1. Write an SQL query to report the managers with at least five direct reports.
*/

select e1.name from Employee e1 join Employee e2 on e1.id=e2.managerId group by e2.managerId , e1.name
having count(*)>=5;

-- select name from Employee where id in (select managerId from Employee group by managerId having count(*)>=5)

/*markdown
2.report the Nth highest salary from an Employee table, returning NULL if it doesn't exist
*/

-- SELECT MAX(salary) AS NthHighestSalary
-- FROM (
--     SELECT 
--         salary, 
--         DENSE_RANK() OVER(ORDER BY salary DESC) AS rnk 
--     FROM Employee
-- ) AS ranking
-- WHERE rnk = 1;

CREATE FUNCTION getNthHighestSalary(N INT) RETURNS INT
BEGIN
  SET N = N - 1;
  RETURN (
      SELECT DISTINCT salary 
      FROM Employee 
      ORDER BY salary DESC 
      LIMIT 1 OFFSET N
  );
END



/*markdown
3.find the person with the most friends and their friend count, given a table recording accepted friend requests directionally
*/

select id ,count(num) as num from (
    select requester_id as id , accepter_id as num from RequestAccepted
    union all 
    select accepter_id as id, requester_id as num from RequestAccepted  
) t group by id order by num  desc limit 1

/*markdown
4.swap the seat id of every two consecutive students in a Seat table (leave the last seat unswapped if the count is odd)
*/

select case when id%2=1 and id =(select max(id)from Seat) then id
       when id%2=1 then id+1
       else id-1
       end as id
       ,student from Seat order by id;

/*markdown
5.report customer ids who bought every product in a Product table
*/

select customer_id from Customer group by customer_id 
having count(distinct product_key)= (select count(*)from Product)


/*markdown
6. for each user, report their join date and number of orders placed as a buyer in 2019, including users with zero such orders
*/

select u.user_id AS buyer_id , u.join_date , count(o.order_id) as orders_in_2019
from Users u left join Orders o on u.user_id = o.buyer_id and
 o.order_date between '2019-01-01' and '2019-12-31'
group by  u.user_id, u.join_date order by buyer_id


/*markdown
7. report, for every date within 90 days of a given "today," the number of users who logged in for the first time on that date
*/

select first_login as login_date , count(*) as user_count
from (
    select user_id ,min(activity_date) as first_login
    from Traffic where activity='login' group by user_id
) as first_logins
where first_login >= date '2019-06-30'-interval '90 days'
and first_login <= date '2019-06-30'
group by first_login;

/*markdown
8.find the price of every product as of a given date, given a table of price-change events (assume a default starting price of 10 before any change)
*/

select product_id , new_price as price from Products 
where (product_id , change_date) in (
   select product_id , max(change_date) from Products where change_date <='2019-08-16'
   group by product_id
)
union 
select distinct product_id , 10 as price from products 
where product_id not in (
    select product_id from Products where change_date <='2019-08-16'

)
order by product_id;

/*markdown
9.for each month and country, report the count and total amount of approved transactions and of chargebacks (ignore rows with all zeros)
*/

select month ,country ,sum(approved_count) approved_count,
SUM(approved_amount) AS approved_amount,
    SUM(chargeback_count) AS chargeback_count,
    SUM(chargeback_amount) AS chargeback_amount
    from (
        select date_trunc('month',trans_date) as month,
        country,
        1 as approved_count,
        amount as approved_amount,
        0 AS chargeback_count,
        0 AS chargeback_amount
    FROM Transactions
    WHERE state = 'approved'

    union ALL

SELECT
        DATE_TRUNC('month', c.trans_date) AS month,
        t.country,
        0 AS approved_count,
        0 AS approved_amount,
        1 AS chargeback_count,
        t.amount AS chargeback_amount
    FROM Chargebacks c
    JOIN Transactions t
        ON c.trans_id = t.id
) x
GROUP BY month, country;

/*markdown
10.compute each football team's tournament points after a set of matches (3 for a win, 1 for a draw, 0 for a loss), ordered by points descending then team_id ascending on ties.
*/

SELECT 
    t.team_id,
    t.team_name,
    COALESCE(SUM(points), 0) AS num_points
FROM Teams t
LEFT JOIN (
    SELECT
        host_team AS team_id,
        CASE
            WHEN host_goals > guest_goals THEN 3
            WHEN host_goals = guest_goals THEN 1
            ELSE 0
        END AS points
    FROM Matches

    UNION ALL

    SELECT
        guest_team AS team_id,
        CASE
            WHEN guest_goals > host_goals THEN 3
            WHEN guest_goals = host_goals THEN 1
            ELSE 0
        END AS points
    FROM Matches
) m
ON t.team_id = m.team_id
GROUP BY t.team_id, t.team_name
ORDER BY num_points DESC, t.team_id;