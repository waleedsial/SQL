-- Quiz Question 1 
--  create a running total of standard_amt_usd (in the orders table) over order time with no date truncation.
-- Your final table should have two columns: 
-- one with the amount being added for each new row, 
-- and a second with the running total.

SELECT standard_amt_usd, 
		SUM(standard_amt_usd) OVER (ORDER BY occurred_at ) as running_total
FROM orders

-- Quiz Question 2 
-- Creating a Partitioned Running Total Using Window Functions
-- create a running total of standard_amt_usd (in the orders table) over order time,
-- but this time, 
--date truncate occurred_at by year
-- and partition by that same year-truncated occurred_at variable. 
--Your final table should have three columns:
-- One with the amount being added for each row, 
--one for the truncated date, 
-- and a final column with the running total within each year.

SELECT standard_amt_usd,
		DATE_TRUNC('year', occurred_at) as year,
		SUM(standard_amt_usd) OVER (PARTITION BY DATE_TRUNC('year', occurred_at)) as running_total
FROM orders

-- Udacity Solution 
SELECT standard_amt_usd,
       DATE_TRUNC('year', occurred_at) as year,
       SUM(standard_amt_usd) OVER (PARTITION BY DATE_TRUNC('year', occurred_at) ORDER BY occurred_at) AS running_total
FROM orders

-- Quiz Row Number & Rank 
-- Select the id, account_id, and total variable from the orders table,
--  then create a column called total_rank 
-- that ranks this total amount of paper ordered (from highest to lowest) for each account using a partition.
--  Your final table should have these four columns.

SELECT id, account_id, total,
       RANK() OVER (PARTITION BY account_id ORDER BY total desc) AS total_rank
FROM orders


SELECT id,
       account_id,
       standard_qty,
       DATE_TRUNC('month', occurred_at) AS month,
       DENSE_RANK() OVER (PARTITION BY account_id ) AS dense_rank,
       SUM(standard_qty) OVER (PARTITION BY account_id ) AS sum_std_qty,
       COUNT(standard_qty) OVER (PARTITION BY account_id ) AS count_std_qty,
       AVG(standard_qty) OVER (PARTITION BY account_id ) AS avg_std_qty,
       MIN(standard_qty) OVER (PARTITION BY account_id ) AS min_std_qty,
       MAX(standard_qty) OVER (PARTITION BY account_id ) AS max_std_qty
FROM orders


-- Aliases 


--  create and use an alias to shorten the following query (which is different than the one in Derek's previous video)
--  that has multiple window functions. Name the alias account_year_window, which is more descriptive than main_window in the example above.

SELECT id,
       account_id,
       DATE_TRUNC('year',occurred_at) AS year,
       DENSE_RANK() OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS dense_rank,
       total_amt_usd,
       SUM(total_amt_usd) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS sum_total_amt_usd,
       COUNT(total_amt_usd) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS count_total_amt_usd,
       AVG(total_amt_usd) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS avg_total_amt_usd,
       MIN(total_amt_usd) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS min_total_amt_usd,
       MAX(total_amt_usd) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS max_total_amt_usd
FROM orders


-- Below is the shortedned version created using Aliases. 

SELECT id,
       account_id,
       DATE_TRUNC('year',occurred_at) AS year,
       DENSE_RANK() OVER account_year_window AS dense_rank,
       total_amt_usd,
       SUM(total_amt_usd) OVER account_year_window AS sum_total_amt_usd,
       COUNT(total_amt_usd) OVER account_year_window AS count_total_amt_usd,
       AVG(total_amt_usd) OVER account_year_window AS avg_total_amt_usd,
       MIN(total_amt_usd) OVER account_year_window AS min_total_amt_usd,
       MAX(total_amt_usd) OVER account_year_window AS max_total_amt_usd
FROM orders
WINDOW account_year_window AS (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) 


-- LAG & Lead Quiz 
 
 --  Imagine you're an analyst at Parch & Posey and you want to
--  determine how the current order's total revenue ("total" meaning from sales of all types of paper) 
 -- compares to the next order's total revenue.
 
 -- Modify Derek's query from the previous video in the SQL Explorer below to perform this analysis.
--  You'll need to use occurred_at and total_amt_usd in the orders table along with LEAD to do so.
--  In your query results, there should be four columns: occurred_at, total_amt_usd, lead, and lead_difference.

-- Original Query 
SELECT account_id,
       standard_sum,
       LAG(standard_sum) OVER (ORDER BY standard_sum) AS lag,
       LEAD(standard_sum) OVER (ORDER BY standard_sum) AS lead,
       standard_sum - LAG(standard_sum) OVER (ORDER BY standard_sum) AS lag_difference,
       LEAD(standard_sum) OVER (ORDER BY standard_sum) - standard_sum AS lead_difference
FROM (
SELECT account_id,
       SUM(standard_qty) AS standard_sum
  FROM orders 
 GROUP BY 1
 ) sub
 
 -- Changes Required 
 -- Need to find current order total revenue, the nested query above is findfing standard_sum 
 -- We can modify it to find total for each order. 
 
 -- Query for total of each order 
 SELECT occurred_at, account_id,
       SUM(total_amt_usd) AS total_sum
  FROM orders 
 GROUP BY 1, 2
 
 -- Now using this query, I need to find how much for each order differs. 
 
 -- Problem is how to use occurred_at & why to use occurred at
 -- I think the reason is that we want to order our results from past to present so that we can see how much we are increasing decreasing in total over time. 
 
 
 SELECT occurred_at,
		account_id,
		total_sum,
		LEAD(total_sum) OVER (ORDER BY occurred_at ) as lead, 
		LEAD(total_sum) OVER (ORDER BY occurred_at ) - total_sum as lead_difference
		FROM (
			SELECT occurred_at, account_id,
			SUM(total_amt_usd) AS total_sum
			FROM orders 
			GROUP BY 1, 2
		) sub 
		
-- Udacity Query 
 
SELECT occurred_at,
       total_amt_usd,
       LEAD(total_amt_usd) OVER (ORDER BY occurred_at) AS lead,
       LEAD(total_amt_usd) OVER (ORDER BY occurred_at) - total_amt_usd AS lead_difference
FROM (
SELECT occurred_at,
       SUM(total_amt_usd) AS total_amt_usd
  FROM orders 
 GROUP BY 1
) sub

-- My Mistake, I should have read & understood properly that this is a time based queestion & there is no need to add account_id in the query. 
-- Inner query just gives result for each date entry 
-- Outer query use it to compute the results over time. 




-- NTILE Quiz 

-- Imagine you're an analyst at Parch & Posey and you want to determine the largest orders 
-- (in terms of quantity) a specific customer has made to encourage them to order more similarly sized large orders.

-- We only want to use NTILE for that customer's account_id 


-- Query 1 
-- Use the NTILE functionality to divide the accounts into 4 levels 
-- in terms of the amount of standard_qty for their orders. 
-- Your resulting table should have the 
--account_id, the occurred_at time for each order, the total amount of standard_qty paper purchased, and one of four levels in a standard_quartile column.


SELECT account_id,
		occurred_at, 
		standard_qty, 
		NTILE(4) OVER (PARTITION by account_id ORDER BY standard_qty) as standard_quartile
FROM orders


-- MISTAKE
-- I made a mistake that I did not use partition by , even the question stated this "You only want to consider the NTILE for that customer's account_id."
-- When I dont use the partition by account_id, it considers the whole as a window. 
-- In that case it simply assigns the first occuring values in the first quartile. 


-- Query 2 

-- Use the NTILE functionality to divide the accounts into two levels in terms of the amount of gloss_qty for their orders.
-- Your resulting table should have the 
--account_id, the occurred_at time for each order, the total amount of gloss_qty paper purchased, and one of two levels in a gloss_half column.


SELECT account_id,
		occurred_at, 
		gloss_qty, 
		NTILE(2) OVER (PARTITION by account_id ORDER BY gloss_qty) as gloss_half
FROM orders

-- What is this query doing ? 
-- The order by column is determining overall divisions & than in the window determined by the partition by we are assigning values to each one in the window. 

-- for example, glossqty max value is 14281, min value is 0 & avg is 146 
-- Now if we are to dermine the quartiles with respect to whole dataset than it will be simply 14281/2 
-- However, I think when we use partitions by we are detrmining based on values in that specific window. 

-- for example account id 1151 has 2 values 0 & 50, its half will be 25 so based on this it will assign values. 


-- Query 3 
-- Use the NTILE functionality to divide the orders for each account into 100 levels in terms of the amount of total_amt_usd for their orders. 
---Your resulting table should have the account_id, 
--the occurred_at time for each order, 
--the total amount of total_amt_usd paper purchased, 
--and one of 100 levels in a total_percentile column




SELECT account_id,
		occurred_at, 
		total_amt_usd, 
		NTILE(100) OVER (PARTITION by account_id ORDER BY total_amt_usd) as percentile
FROM orders
order by account_id