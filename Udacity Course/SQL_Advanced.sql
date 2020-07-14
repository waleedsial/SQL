-- each account who has a sales rep 
-- and each sales rep that has an account (all of the columns in these returned rows will be full)

-- but also each account that does not have a sales rep 
-- and each sales rep that does not have an account (some of the columns in these returned rows will be empty)

-- I think we need to use full join here which will return the unmatches rows in both the tables as well. 

SELECT * 
FROM accounts
FULL OUTER JOIN sales_reps
ON accounts.sales_rep_id = sales_reps.id


-- Inequality JOINs

SELECT accounts.name, accounts.primary_poc, sales_reps.name
FROM accounts
LEFT JOIN sales_reps
ON accounts.sales_rep_id = sales_reps.id 
AND accounts.primary_poc < sales_reps.name 

-- SELF Joins 

SELECT o1.id AS o1_id,
       o1.account_id AS o1_account_id,
       o1.occurred_at AS o1_occurred_at,
       o2.id AS o2_id,
       o2.account_id AS o2_account_id,
       o2.occurred_at AS o2_occurred_at
  FROM orders o1
 LEFT JOIN orders o2
   ON o1.account_id = o2.account_id
  AND o2.occurred_at > o1.occurred_at
  AND o2.occurred_at <= o1.occurred_at + INTERVAL '28 days'
ORDER BY o1.account_id, o1.occurred_at

-- Modify the query abobve,  to perform the same interval analysis except for the web_events table.
-- change the interval to 1 day to find those web events that occurred after, but not more than 1 day after, another web event
-- add a column for the channel variable in both instances of the table in your query


SELECT w1.account_id, 
		w1.occurred_at, 
		w1.id, 
		w1.channel,
		w2.account_id, 
		w2.occurred_at,
		w2.id,
		w2.channel
		
FROM web_events w1
LEFT JOIN web_events w2
ON w1.account_id = w2.account_id
AND w1.occurred_at > w2.occurred_at
AND w1.occurred_at <= w2.occurred_at + INTERVAL '1 days'
ORDER by w1.account_id, w1.occurred_at


-- Udacity Answer: 
SELECT we1.id AS we_id,
       we1.account_id AS we1_account_id,
       we1.occurred_at AS we1_occurred_at,
       we1.channel AS we1_channel,
       we2.id AS we2_id,
       we2.account_id AS we2_account_id,
       we2.occurred_at AS we2_occurred_at,
       we2.channel AS we2_channel
  FROM web_events we1 
 LEFT JOIN web_events we2
   ON we1.account_id = we2.account_id
  AND we1.occurred_at > we2.occurred_at
  AND we1.occurred_at <= we2.occurred_at + INTERVAL '1 day'
ORDER BY we1.account_id, we2.occurred_at


-- Optimization 
-- A query for calculting different daily metrics shc as active sales rep, orders, web events. 
-- This query results in 79k records. 

SELECT DATE_TRUNC('day',o.occurred_at) as date, 
		COUNT(DISTINCT a.sales_rep_id) as active_sales_reps,
		COUNT(DISTINCT o.id) as orders,
		COUNT(DISTINCT we.id) as web_visits

FROM accounts a  
JOIN orders o
ON a.id = o.account_id
JOIN web_events we
ON a.id = we.account_id
GROUP BY 1
ORDER BY 1 DESC 


-- Here we are joining on the date field & this is causing a data explosion. 
-- What happens is that we are given every row on a given day in one table to every row in the other table with the same day 
-- As a result number of rows is very high. 
-- Due to this issue, we have to use count distinct instead of regular count to get accurate count of metrics. 


-- We can get the same results in a more efficient way. 
-- Doing aggregations separately which is faster becuase counts are perfomred in far smaller datasets. 



-- First Sub Query 

SELECT DATE_TRUNC('day', o.occurred_at) as date, 
		COUNT(a.sales_rep_id) as active_sales_reps,
		COUNT(o.id) as orders

FROM accounts a 
JOIN orders o 
ON a.id = o.account_id
GROUP BY 1 

-- 2nd Sub qury 

SELECT DATE_TRUNC('day', we.occurred_at) as date, 
		COUNT(we.id) as web_events
FROM  web_events we 
GROUP BY 1 

-- Now we can join these 2 tables


SELECT COALESCE(orders.date, web_events.date) as date, 
		orders.active_sales_reps, 
		orders.orders, 
		web_events.web_visits
	FROM (
			SELECT DATE_TRUNC('day', o.occurred_at) as date, 
				COUNT(a.sales_rep_id) as active_sales_reps,
				COUNT(o.id) as orders

				FROM accounts a 
				JOIN orders o 
				ON a.id = o.account_id
				GROUP BY 1 
			) orders 
			
	FULL JOIN 
	(
		SELECT DATE_TRUNC('day', we.occurred_at) as date, 
		COUNT(we.id) as web_visits
		FROM  web_events we 
		GROUP BY 1 
	) web_events
	
	ON web_events.date = orders.date
	order by 1 desc 
-- we are using full join for just n case when one table may not have any record for that date 
