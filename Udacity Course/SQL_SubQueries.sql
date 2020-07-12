

-- Find the number of events that occur for each day for each channel. 

select channel, avg(num_events) as a_events
from 
(
SELECT DATE_TRUNC('day', occurred_at) as day, channel, count(*) as num_events
FROM web_events
group by 1, 2) sub
group by channel
order by a_events desc

-- Use date_trunc to pull month level information about the fuirst order ever placed






select  avg(standard_qty) as std_avg, avg(gloss_qty) gloss_avg, avg(poster_qty) as post_avg, sum(total_amt_usd)
from orders
	where DATE_TRUNC('month',occurred_at) = (
		SELECT MIN(DATE_TRUNC('month',occurred_at)) 
		FROM web_events
		)
		
		
		
		
		
		
-- Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.

-- First, I wanted to find the total_amt_usd totals associated with each sales rep, 
--and I also wanted the region in which they were located. The query below provided this information.

SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY 1,2
ORDER BY 3 DESC;

-- Next, I pulled the max for each region, and then we can use this to pull those rows in our final result.
SELECT region_name, MAX(total_amt) total_amt
     FROM(SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
             FROM sales_reps s
             JOIN accounts a
             ON a.sales_rep_id = s.id
             JOIN orders o
             ON o.account_id = a.id
             JOIN region r
             ON r.id = s.region_id
             GROUP BY 1, 2) t1
     GROUP BY 1;


-- Essentially, this is a JOIN of these two tables, where the region and amount match.
-- We have the region & the max amount fromt the 2nd table, we will check from the first table where this quantity will occur. 

SELECT t3.rep_name, t3.region_name, t3.total_amt

FROM (
SELECT region_name, MAX(total_amt) total_amt
     FROM(SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
             FROM sales_reps s
             JOIN accounts a
             ON a.sales_rep_id = s.id
             JOIN orders o
             ON o.account_id = a.id
             JOIN region r
             ON r.id = s.region_id
             GROUP BY 1, 2) t1
     GROUP BY 1) t2

JOIN (
	SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
		FROM sales_reps s
			JOIN accounts a
			ON a.sales_rep_id = s.id
			JOIN orders o
			ON o.account_id = a.id
			JOIN region r
			ON r.id = s.region_id
			GROUP BY 1,2
		ORDER BY 3 DESC
) t3

ON t2.region_name = t3.region_name AND t3.total_amt = t2.total_amt;


-- For the region with the largest (sum) of sales total_amt_usd, how many total (count) orders were placed?


			-- this query will calculate the sum of total_amt_usd with respect to regions 
			SELECT reg, max(total) largest_sum
			FROM 
			(
				SELECT region.name as reg, SUM(orders.total_amt_usd) as total
				FROM region
				JOIN sales_reps
				ON region.id = sales_reps.region_id
				JOIN accounts
				ON sales_reps.id = accounts.sales_rep_id
				JOIN orders
				ON accounts.id = orders.account_id
				group by region.name
				order by total desc 
				limit 1
				) sub
			order by largest_sum desc
			
			
			
			-- count the number of orders for each region 
			SELECT reg, num_orders
			FROM 
			(
			SELECT region.name as t1.reg, count(orders.total) as num_orders
			FROM region
				JOIN sales_reps
				ON region.id = sales_reps.region_id
				JOIN accounts
				ON sales_reps.id = accounts.sales_rep_id
				JOIN orders
				ON accounts.id = orders.account_id
				group by region.name ) t1
			JOIN ( 
			SELECT region.name as reg, SUM(orders.total_amt_usd) as total
				FROM region
				JOIN sales_reps
				ON region.id = sales_reps.region_id
				JOIN accounts
				ON sales_reps.id = accounts.sales_rep_id
				JOIN orders
				ON accounts.id = orders.account_id
				group by region.name
				order by total desc ) t2
			on t1.reg = t2.reg
			order by total desc
			limit 1
			
			
-- The udacity cvourse used this query for this question, they used having clause. 
SELECT r.name, COUNT(o.total) total_orders
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name
HAVING SUM(o.total_amt_usd) = (
      SELECT MAX(total_amt)
      FROM (SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
              FROM sales_reps s
              JOIN accounts a
              ON a.sales_rep_id = s.id
              JOIN orders o
              ON o.account_id = a.id
              JOIN region r
              ON r.id = s.region_id
              GROUP BY r.name) sub);


-- How many accounts had more total purchases than the account name which has bought the most standard_qty paper throughout their lifetime as a customer?


-- step 1 : find the account with most standard qty buys 

SELECT t1.act_id
FROM (
	SELECT orders.account_id act_id, sum(standard_qty) as std_qty_sum
	FROM orders
	group by account_id
	order by std_qty_sum desc
	limit 1
) t1

-- Step 2 : find the total purchases for this account id 
SELECT  SUM(total)
FROM orders
WHERE orders.account_id = (
	SELECT t1.act_id
	FROM (
		SELECT orders.account_id act_id, sum(standard_qty) as std_qty_sum
		FROM orders
		group by account_id
		order by std_qty_sum desc
		limit 1
	) t1)
	
	
	
	-- Accounts with total purchaes summed
	-- We need to filter those accounts which have total purchases greater than the account id we obtained earlier. 
	
	
	SELECT COUNT (*)
	FROM (
		SELECT accounts.name, sum(total) as total_orders
		FROM orders
		JOIN accounts 
		ON orders.account_id = accounts.id
		GROUP by accounts.name 
		HAVING sum(total) > (
					SELECT  SUM(total)
				FROM orders
				WHERE orders.account_id = (
					SELECT t1.act_id
					FROM (
						SELECT orders.account_id act_id, sum(standard_qty) as std_qty_sum
						FROM orders
						group by account_id
						order by std_qty_sum desc
						limit 1
					) t1)
		)
		order by total_orders desc
	) final
	
	
-- For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, how many web_events did they have for each channel?
	
	
	-- 1 : find the account id with most spending 
	
	SELECT account_id 
	FROM (
				SELECT account_id, sum(total_amt_usd) total_spending
				FROM orders
				GROUP BY orders.account_id
				order by total_spending desc
				limit 1
	) t1

	-- Now using this ID, we can find the number of events for each channel. 
	
	
	SELECT accounts.name, web_events.channel, count(*)
	FROM accounts 
	JOIN web_events
	ON accounts.id = web_events.account_id
		WHERE accounts.id = (
					SELECT account_id 
						FROM 
						(
							SELECT account_id, sum(total_amt_usd) total_spending
							FROM orders
							GROUP BY orders.account_id
							order by total_spending desc
							limit 1
						) t1
	)
	GROUP BY accounts.name, web_events.channel
	order by count(*) desc
	
	
	-- What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?

	

-- step 1 : find the accounts with top 10 spending 
SELECT account_id 
FROM (
	SELECT account_id, sum(total_amt_usd) total_spending
	FROM orders
	GROUP BY orders.account_id
	order by total_spending desc
	limit 10
	) t1

-- 
-- Calculate lifetime avg of customers 
	
	SELECT account_id, avg(total_amt_usd) total_spending
	FROM orders
	WHERE account_id in 
	(
					SELECT account_id 
				FROM (
					SELECT account_id, sum(total_amt_usd) total_spending
					FROM orders
					GROUP BY orders.account_id
					order by total_spending desc
					limit 10
					) t1
	)
	GROUP BY orders.account_id
	order by total_spending desc
	-- I interpreted the question wrong 
	-- THe question asks for the avg of these spendings alltogetrrt. 
	


-- What is the lifetime average amount spent in terms of total_amt_usd,
--  including only the companies that spent more per order, on average, than the average of all orders.


--Step 1 find the average of all orders

SELECT AVG (total_amt_usd)
FROM orders 


-- Find average for each company 

SELECT orders.account_id, AVG (total_amt_usd)
FROM orders 
group by orders.account_id
having AVG (total_amt_usd) > (SELECT AVG (total_amt_usd)
FROM orders 
)

-- course answer 
SELECT AVG(avg_amt)
FROM (SELECT o.account_id, AVG(o.total_amt_usd) avg_amt
    FROM orders o
    GROUP BY 1
    HAVING AVG(o.total_amt_usd) > (SELECT AVG(o.total_amt_usd) avg_all
                                   FROM orders o)) temp_table;
								   


--



								
-- CTE Section 

-- table1 will simply give the sum of each sales rep for each region. 
WITH table1 AS (
select region_id, sales_reps.name as sr_name ,  sum(orders.total_amt_usd) as sr_sum
FROM region 
JOIN sales_reps
ON  region.id = sales_reps.region_id
JOIN accounts 
ON sales_reps.id = accounts.sales_rep_id 
JOIN orders
ON accounts.id = orders.account_id
group by region_id, sales_reps.name
order by 3 desc 
),
-- table 2 will give the maximum in each region 
table2 AS (
SELECT t1.region_id, MAX(sr_sum) max_sum
FROM 
(
	select region_id, sales_reps.name ,  sum(orders.total_amt_usd) as sr_sum
	FROM region 
	JOIN sales_reps
	ON  region.id = sales_reps.region_id
	JOIN accounts 
	ON sales_reps.id = accounts.sales_rep_id 
	JOIN orders
	ON accounts.id = orders.account_id
	group by region_id, sales_reps.name
) t1
GROUP BY t1.region_id
)
-- using these 2 tables, we can simply join them on region id & put a condition on the sales rep sum where it will be equalto maximum. 
SELECT table1.sr_name, table1.region_id, sr_sum
FROM table1
JOIN table2
ON table1.region_id = table2.region_id AND table1.sr_sum = table2.max_sum


-- COURSE Solution 
WITH t1 AS (
  SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
   FROM sales_reps s
   JOIN accounts a
   ON a.sales_rep_id = s.id
   JOIN orders o
   ON o.account_id = a.id
   JOIN region r
   ON r.id = s.region_id
   GROUP BY 1,2
   ORDER BY 3 DESC), 
t2 AS (
   SELECT region_name, MAX(total_amt) total_amt
   FROM t1
   GROUP BY 1)
SELECT t1.rep_name, t1.region_name, t1.total_amt
FROM t1
JOIN t2
ON t1.region_name = t2.region_name AND t1.total_amt = t2.total_amt;

-- this is very nice, in the course , we used the results of the first CTE in the 2nd CTE, very clean 


-- Question 2 
-- For the region with the largest sales total_amt_usd, how many total orders were placed?

-- table 1 should have sum of total_amt_usd  for each region 
-- since we are ordering by desc & limiting the results to 1
-- this table will essentially give the region with the maximum sales
WITH table1 AS (

SELECT region.name as region_name, SUM(total_amt_usd)
FROM region
JOIN sales_reps
ON region.id = sales_reps.region_id
JOIN accounts 
ON accounts.sales_rep_id = sales_reps.id 
JOIN orders
ON orders.account_id = accounts.id
GROUP BY region.name
order by 2 desc 
limit 1
), 
-- for each region how many orders were made 
table2 AS (
SELECT region.name as region_name, SUM(total) as total_orders 
FROM region
JOIN sales_reps
ON region.id = sales_reps.region_id
JOIN accounts 
ON accounts.sales_rep_id = sales_reps.id 
JOIN orders
ON orders.account_id = accounts.id
GROUP BY region.name
 )
 -- we are joining the result of table1 with the table2 
 -- since the table1 has only 1 result therefore
 -- we will get the region with maximum total same amount, followed by the orders it had 
 SELECT * 
 FROM table1
 JOIN table2
 ON table1.region_name = table2.region_name


-- Solution by the udacity teacher is a bit different 
-- Since he used the max & than used having command. 
WITH t1 AS (
   SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
   FROM sales_reps s
   JOIN accounts a
   ON a.sales_rep_id = s.id
   JOIN orders o
   ON o.account_id = a.id
   JOIN region r
   ON r.id = s.region_id
   GROUP BY r.name), 
t2 AS (
   SELECT MAX(total_amt)
   FROM t1)
SELECT r.name, COUNT(o.total) total_orders
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name
HAVING SUM(o.total_amt_usd) = (SELECT * FROM t2);


-- How many accounts had more total purchases than the account name which has bought the most standard_qty paper throughout their lifetime as a customer?


-- table 2 will compute the standard_qty number for each account 
-- We can use the same table to compute corresponding total for each account 
-- order the result by standard qty 
--
WITH table2 as (
SELECT accounts.name as act_name, sum(standard_qty) as std_qty, sum(total) as total
FROM orders
JOIN accounts
ON orders.account_id = accounts.id
GROUP BY accounts.name
order by 2 desc 
limit 1
), 
-- here we select the total for the account which had the highest std qty. 
table3 as (
SELECT total
FROM table2 ), 

-- here we select the accounts which have sum of order greater than the obtained previously 
table4 as (
SELECT accounts.name
FROM orders
JOIN accounts
ON orders.account_id = accounts.id
GROUP BY accounts.name
HAVING SUM(orders.total) > (SELECT * FROM table3))
-- here we simply count them. 
select count(*)
FROM table4;

-- For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, how many web_events did they have for each channel?


WITH table1 as (
SELECT accounts.name as act_name, sum(orders.total_amt_usd) as total_spending 
FROM orders
JOIN accounts
ON orders.account_id = accounts.id
GROUP BY accounts.name
order by 2 desc
limit 1 
), 
-- this will give me the name of the customer with most spending 
table2 as (
SELECT act_name
FROM table1 
)
-- find web events for each customer 

SELECT accounts.name, channel , count(*)
FROM web_events
JOIN accounts 
on web_events.account_id = accounts.id
group by accounts.name, channel
having accounts.name = (select * from table2)


-- Udacity solution 
WITH t1 AS (
   SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
   FROM orders o
   JOIN accounts a
   ON a.id = o.account_id
   GROUP BY a.id, a.name
   ORDER BY 3 DESC
   LIMIT 1)
SELECT a.name, w.channel, COUNT(*)
FROM accounts a
JOIN web_events w
ON a.id = w.account_id AND a.id =  (SELECT id FROM t1)
GROUP BY 1, 2
ORDER BY 3 DESC;



-- Question 5 
-- What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?

-- Find top 10 spending accounts 
WITH t1 AS (
	SELECT accounts.name as act_name, sum(total_amt_usd) as tot
	FROM orders 
	JOIN accounts
	ON orders.account_id = accounts.id
	GROUP BY accounts.name
	ORDER BY 2 desc 
	LIMIT 10 
	)
	
SELECT  avg(tot)
FROM t1
-- This question was confusion to me from understanding english point of view. 

-- Question 6 

-- What is the lifetime average amount spent in terms of total_amt_usd,
-- including only the companies that spent more per order, on average, than the average of all orders.

-- step 1 : find the average amount per order 
WITH t1 AS (
   SELECT AVG(o.total_amt_usd) avg_all
   FROM orders o
   JOIN accounts a
   ON a.id = o.account_id),
t2 AS (
   SELECT o.account_id, AVG(o.total_amt_usd) avg_amt
   FROM orders o
   GROUP BY 1
   HAVING AVG(o.total_amt_usd) > (SELECT * FROM t1))
SELECT AVG(avg_amt)
FROM t2;








