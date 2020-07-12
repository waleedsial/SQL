## 
Extracting hour , finding the best hour for posting stories. 

SELECT 
   strftime('%H', timestamp)  hour, 
   ROUND(avg(score),2) hourly_score, 
   count(*) Number_of_stories
FROM hacker_news
where timestamp not NULL
GROUP BY hour
order by 1 desc;  


with play_count as
(SELECT song_id,
   COUNT(*) AS 'times_played'
FROM plays
GROUP BY song_id
)
select songs.title, songs.artist, play_count.times_played
from play_count
join songs 
on play_count.song_id = songs.id;

select primary_poc, occurred_at, channel, accounts.name
from accounts 
join web_events 
on accounts.id = web_events.account_id
where accounts.name = 'Walmart'



select sales_reps.name as name, region.name as region, accounts.name as account_name
from sales_reps
join region 
on sales_reps.region_id = region.id
join accounts 
on sales_reps.id = accounts.sales_rep_id


-- Question 1 
select sales_reps.name as name, region as region, accounts.name as accounts_name
from sales_reps
join region on sales_reps.region_id = region.id AND region.name = 'Midwest'
join accounts on sales_reps.id = accounts.sales_rep_id
order by accounts.name



-- Question 2
select sales_reps.name as name, region as region, accounts.name as accounts_name
from sales_reps
join region on sales_reps.region_id = region.id AND region.name = 'Midwest' 
join accounts on sales_reps.id = accounts.sales_rep_id 
where sales_reps.name like 'S%'
order by accounts.name


-- Question 2 using condition in on 
select sales_reps.name as name, region as region, accounts.name as accounts_name
from sales_reps
join region on sales_reps.region_id = region.id AND region.name = 'Midwest' 
AND sales_reps.name like 'S%'
join accounts on sales_reps.id = accounts.sales_rep_id 
order by accounts.name

-- Question 3
select sales_reps.name as name, region as region, accounts.name as accounts_name
from sales_reps
join region on sales_reps.region_id = region.id AND region.name = 'Midwest' 
AND sales_reps.name like '% K%'
join accounts on sales_reps.id = accounts.sales_rep_id 
order by accounts.name

-- Question 4
select orders.id as orderid, accounts.name as account, region.name as region, (orders.total_amt_usd/orders.total+ 0.01) as unitprice 
from sales_reps
join accounts on sales_reps.id = accounts.sales_rep_id
join orders on accounts.id = orders.account_id
join region on sales_reps.region_id = region.id
where orders.standard_qty > 100

-- Question 5
select region.name as region, accounts.name as account,  (orders.total_amt_usd/orders.total+ 0.01) as unitprice 
from sales_reps
join accounts on sales_reps.id = accounts.sales_rep_id
join orders on accounts.id = orders.account_id
join region on sales_reps.region_id = region.id
where orders.standard_qty > 100 AND orders.poster_qty > 50
order by unitprice 

-- Question 6
select region.name as region, accounts.name as account,  (orders.total_amt_usd/orders.total+ 0.01) as unitprice 
from sales_reps
join accounts on sales_reps.id = accounts.sales_rep_id
join orders on accounts.id = orders.account_id
join region on sales_reps.region_id = region.id
where orders.standard_qty > 100 AND orders.poster_qty > 50
order by unitprice desc

-- Question 7
select distinct(accounts.name),  web_events.channel
from accounts 
join web_events 
on accounts.id = web_events.account_id
AND accounts.id = 1001

-- Question 8 
SELECT o.occurred_at, a.name, o.total, o.total_amt_usd
FROM accounts a
JOIN orders o
ON o.account_id = a.id
WHERE o.occurred_at BETWEEN '01-01-2015' AND '01-01-2016'
ORDER BY o.occurred_at DESC;


-- Question 5 Min, Max, Average ind the mean (AVERAGE) amount spent per order on each paper type, as well as the mean amount of each paper type purchased per order. Your final answer should have 6 values - one for each paper type for the average number of sales, as well as the average amount.
select
AVG(standard_qty) as std_avg, 
AVG(standard_amt_usd) std_avg_amt, 
AVG(gloss_qty) gloss_avg, 
AVG(gloss_amt_usd) gloss_avg_amt, 
AVG(poster_qty) post_avg, 
AVG(poster_amt_usd) post_avg_amt
from orders


-- calculate the MEDIAN. Though this is more advanced than what we have covered so far try finding - what is the MEDIAN total_usd spent on all orders?

-- hardcdoed 
SELECT *
FROM (SELECT total_amt_usd
      FROM orders
      ORDER BY total_amt_usd
      LIMIT 3457) AS Table1
ORDER BY total_amt_usd DESC
LIMIT 2;


-- Which account (by name) placed the earliest order? Your solution should have the account name and the date of the order.

select accounts.name as name, orders.occurred_at as orderdate
from accounts
join orders on accounts.id = orders.account_id
order by orderdate

--or using group by for more cleaner 
select accounts.name as name, min(orders.occurred_at) as orderdate
from accounts
join orders on accounts.id = orders.account_id
group by name
order by orderdate

-- Find the total sales in usd for each account. You should include two columns - the total sales for each company's orders in usd and the company name.


select accounts.name as name, sum(orders.total)
from accounts
join orders on accounts.id = orders.account_id
group by accounts.name


-- Via what channel did the most recent (latest) web_event occur, which account was associated with this web_event? Your query should return only three values - the date, channel, and account name.


select max(occurred_at) as latest_date, channel, accounts.name
from accounts 
join web_events 
on accounts.id = web_events.account_id
group by channel, accounts.name

-- Find the total number of times each type of channel from the web_events was used. Your final table should have two columns - the channel and the number of times the channel was used.

select channel, count(*)
from web_events
group by channel

-- Who was the primary contact associated with the earliest web_event?
select primary_poc, occurred_at
from accounts
join web_events
on accounts.id = web_events.account_id
order by web_events.occurred_at desc
limit 1

-- What was the smallest order placed by each account in terms of total usd. Provide only two columns - the account name and the total usd. Order from smallest dollar amounts to largest.

select accounts.name as name, min(orders.total) as total
from accounts 
join orders 
on accounts.id = orders.account_id
group by name
order by total


-- Find the number of sales reps in each region. Your final table should have two columns - the region and the number of sales_reps. Order from fewest reps to most reps


select region.name as name, count(sales_reps.id)
from region 
join sales_reps 
on region.id = sales_reps.region_id 
group by region.name

-- For each account, determine the average amount of each type of paper they purchased across their orders. 
-- Your result should have four columns - 
-- one for the account name and one for the average quantity purchased for each of the paper types for each account.

select accounts.name as name, avg(standard_qty) as avg_std, avg(gloss_qty) as avg_gloss, avg(poster_qty) as avg_poster
from accounts join orders
on accounts.id = orders.account_id
group by accounts.name

--  For each account, determine the average amount spent per order on each paper type.
--  Your result should have four columns - one for the account name and one for the average amount spent on each paper type.

select accounts.name as name, avg(standard_amt_usd) as avg_std_amt, avg(gloss_amt_usd) as avg_gloss_amt, avg(poster_amt_usd) as avg_poster_amt
from accounts join orders
on accounts.id = orders.account_id
group by accounts.name

-- Determine the number of times a particular channel was used in the web_events table for each sales rep. 
-- Your final table should have three columns - 
-- the name of the sales rep, the channel, and the number of occurrences. Order your table with the highest number of occurrences first.


select sales_reps.name as name, web_events.channel as channel, count(*)
from sales_reps
join accounts on sales_reps.id = accounts.sales_rep_id
join web_events on accounts.id = web_events.account_id
group by sales_reps.name, channel
order by count(*) desc


-- Determine the number of times a particular channel was used in the web_events table for each region. 
-- Your final table should have three columns - the region name, the channel, and the number of occurrences. Order your table with the highest number of occurrences first.


select region.name,channel, count(*)
from region 
join sales_reps
on region.id = sales_reps.region_id
join accounts on sales_reps.id = accounts.sales_rep_id
join web_events on accounts.id = web_events.account_id
group by region.name, channel
order by count(*) desc


-- Use DISTINCT to test if there are any accounts associated with more than one region.

select accounts.name act,  region.name rg
from accounts
join sales_reps on accounts.sales_rep_id = sales_reps.id 
join region on sales_reps.region_id = region.id
group by accounts.name, rg

-- Have any sales reps worked on more than one account?

select distinct sales_reps.name, accounts.name
from accounts
join sales_reps on accounts.sales_rep_id = sales_reps.id 
group accounts.name


-- Having Section 

--How many of the sales reps have more than 5 accounts that they manage?

select sales_reps.name as name, count(distinct(accounts.id)) as acts
from accounts 
join sales_reps on accounts.sales_rep_id = sales_reps.id
group by sales_reps.name

-- OR
from accounts 
join sales_reps on accounts.sales_rep_id = sales_reps.id
group by sales_reps.id
having count(*) > 20

-- How many accounts have more than 20 orders?


select accounts.name, count(*)
from accounts 
join orders 
on accounts.id = orders.account_id
group by accounts.name
having count(*) > 20

-- Which account has the most orders?

select accounts.name, count(*)
from accounts 
join orders 
on accounts.id = orders.account_id
group by accounts.name
order by count(*) desc
limit 1

-- 


-- Which accounts spent more than 30,000 usd total across all orders?

select accounts.name, sum(total) as tt
from accounts 
join orders 
on accounts.id = orders.account_id
group by accounts.name
having sum(total) > 30000

 -- Which accounts spent less than 1,000 usd total across all orders?
select accounts.name, sum(total) as tt
from accounts 
join orders 
on accounts.id = orders.account_id
group by accounts.name
having sum(total) < 1000

-- Which account has spent the most with us?
select accounts.name, sum(total_amt_usd) as tt
from accounts 
join orders 
on accounts.id = orders.account_id
group by accounts.name
order by sum(total_amt_usd) desc
limit 1



-- Which accounts used facebook as a channel to contact customers more than 6 times?
SELECT a.id, a.name, w.channel, COUNT(*) use_of_channel
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
GROUP BY a.id, a.name, w.channel
HAVING COUNT(*) > 6 AND w.channel = 'facebook'
ORDER BY use_of_channel;

--Which channel was most frequently used by most accounts?

SELECT a.id, a.name, w.channel, COUNT(*) use_of_channel
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
GROUP BY a.id, a.name, w.channel
ORDER BY use_of_channel DESC
LIMIT 10;


-- Dates Section 
--Find the sales in terms of total dollars for all orders in each year, ordered from greatest to least. Do you notice any trends in the yearly sales totals?

select DATE_PART('year', occurred_at) as yr, SUM(total_amt_usd) as yearly_total
from orders
group by 1
order by 2 desc

-- Which month did Parch & Posey have the greatest sales in terms of total dollars? Are all months evenly represented by the dataset?
select DATE_PART('month', occurred_at) as mn, SUM(total_amt_usd) as mn_total
from orders
group by 1
order by 2 desc


-- Which year did Parch & Posey have the greatest sales in terms of total number of orders? Are all years evenly represented by the dataset?
select DATE_PART('year', occurred_at) as yr, count(*) as yearly_total
from orders
group by 1
order by 2 desc


--Which month did Parch & Posey have the greatest sales in terms of total number of orders? Are all months evenly represented by the dataset?
select DATE_PART('month', occurred_at) as mn, count(*) as mn_total
from orders
WHERE occurred_at BETWEEN '2014-01-01' AND '2017-01-01'
group by 1
order by 2 desc 

-- 

--In which month of which year did Walmart spend the most on gloss paper in terms of dollars?

select DATE_PART('year', occurred_at) as yr,DATE_PART('month', occurred_at) as mn, SUM(gloss_amt_usd) as gloss_total
from orders
join accounts on orders.account_id = accounts.id
where accounts.name='walmart'
group by 1,2
order by 2 desc -- this is wromng 

-- this is correct
SELECT DATE_TRUNC('month', o.occurred_at) ord_date, SUM(o.gloss_amt_usd) tot_spent
FROM orders o 
JOIN accounts a
ON a.id = o.account_id
WHERE a.name = 'Walmart'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;


-- 


-- Case Statements Section 

-- Write a query to display for each order, the account ID, total amount of the order, and the level of the order - ‘Large’ or ’Small’ - depending on if the order is $3000 or more, or smaller than $3000.





 select 
 accounts.id as id,
 orders.total_amt_usd as total,
 --CASE when orders.total_amt_usd > 3000 
	THEN 'Large'  
	ELSE 'Small'
	END AS Level
from orders
from orders
join accounts on orders.account_id = accounts.id;


--Write a query to display the number of orders in each of three categories, based on the total number of items in each order.
-- The three categories are: 'At Least 2000', 'Between 1000 and 2000' and 'Less than 1000'.

select 
CASE
	WHEN orders.total < 1000 THEN 'Less than 1000'
	WHEN orders.total >= 1000  AND orders.total < 2000 THEN 'Between 1000 and 2000'
	WHEN orders.total >= 2000 THEN 'At Least 2000'
	END as categories,  count(*) as category_count
from orders
group by 1


-- We would like to understand 3 different levels of customers based on the amount associated with their purchases.
-- The top level includes anyone with a Lifetime Value (total sales of all orders) greater than 200,000 usd.
-- The second level is between 200,000 and 100,000 usd. The lowest level is anyone under 100,000 usd. 
--Provide a table that includes the level associated with each account. 
--You should provide the account name, the total sales of all orders for the customer, and the level. Order with the top spending customers listed firs



select accounts.name, sum(total_amt_usd) as Total_Sales, 
CASE WHEN SUM(orders.total_amt_usd) > 200000  THEN 'Top'
	WHEN SUM(orders.total_amt_usd) > 100000 THEN 'Middle'
	ELSE 'Lowest' END AS Level
from orders
join accounts on orders.account_id = accounts.id
group by accounts.name
order by 2 desc


-- We would now like to perform a similar calculation to the first,
--  but we want to obtain the total amount spent by customers only in 2016 and 2017. 
-- Keep the same levels as in the previous question. Order with the top spending customers listed first.

SELECT a.name, SUM(total_amt_usd) total_spent, 
     CASE WHEN SUM(total_amt_usd) > 200000 THEN 'top'
     WHEN  SUM(total_amt_usd) > 100000 THEN 'middle'
     ELSE 'low' END AS customer_level
FROM orders o
JOIN accounts a
ON o.account_id = a.id
WHERE occurred_at > '2015-12-31' 
GROUP BY 1
ORDER BY 2 DESC;


-- We would like to identify top performing sales reps,
--  which are sales reps associated with more than 200 orders.
--  Create a table with the sales rep name, 
-- the total number of orders, and a column with top or not depending on if they have more than 200 orders. 
-- Place the top sales people first in your final table.


SELECT s.name, COUNT(*) num_ords,
     CASE WHEN COUNT(*) > 200 THEN 'top'
     ELSE 'not' END AS sales_rep_level
FROM orders o
JOIN accounts a
ON o.account_id = a.id 
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.name
ORDER BY 2 DESC;


 -- The previous didn't account for the middle, nor the dollar amount associated with the sales. Management decides they want to see these characteristics represented as well. We would like to identify top performing sales reps, which are sales reps associated with more than 200 orders or more than 750000 in total sales. The middle group has any rep with more than 150 orders or 500000 in sales. Create a table with the sales rep name, the total number of orders, total sales across all orders, and a column with top, middle, or low depending on this criteria. Place the top sales people based on dollar amount of sales first in your final table.
SELECT s.name, COUNT(*), SUM(o.total_amt_usd) total_spent, 
     CASE WHEN COUNT(*) > 200 OR SUM(o.total_amt_usd) > 750000 THEN 'top'
     WHEN COUNT(*) > 150 OR SUM(o.total_amt_usd) > 500000 THEN 'middle'
     ELSE 'low' END AS sales_rep_level
FROM orders o
JOIN accounts a
ON o.account_id = a.id 
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.name
ORDER BY 3 DESC;


