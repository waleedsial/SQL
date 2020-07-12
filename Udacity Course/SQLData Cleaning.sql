
-- QUIZ LEFt & Right 

-- Question 1 
--In the accounts table, there is a column holding the website for each company.
-- The last three digits specify what type of web address they are using. 
--A list of extensions (and pricing) is provided here.
-- Pull these extensions and provide how many of each website type exist in the accounts table.
select  Count(Distinct(RIGHT (website, 3)))
as extension 
from accounts
limit 10;
-- this only rturns the unique type of the domains 

-- the following query returns the number of each domain. 

select count(*), (RIGHT (website, 3)) as extension 
from accounts
GROUP BY extension

-- Question 2
--There is much debate about how much the name (or even the first letter of a company name) matters.
-- Use the accounts table to pull the first letter of each company name to see the distribution of company names that begin with each letter (or number).

SELECT LEFT(accounts.name, 1) as first_letter, count(*) as occurance_of_each 
FROM accounts 
GROUP BY first_letter
order by occurance_of_each desc

-- Question 3 

-- Use the accounts table and a CASE statement 
--to create two groups: one group of company names that start with a number
-- and a second group of those company names that start with a letter.
--  What proportion of company names start with a letter?

WITH table1 as (
	SELECT LEFT(accounts.name, 1) as first_letter, count(*) as occurance_of_each 
	FROM accounts 
	GROUP BY first_letter
	order by occurance_of_each desc)

SELECT 
	CASE WHEN table1.first_letter > 0 AND WHEN table1.first_letter < 9 THEN 1
	ELSE 0 END AS Starts_Numeric 
FROM table1 
-- My implementation was wrong, I need to figure out a way about isnumeric function in pSQL

SELECT SUM(num) nums, SUM(letter) letters
FROM (SELECT name, CASE WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9') 
                       THEN 1 ELSE 0 END AS num, 
         CASE WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9') 
                       THEN 0 ELSE 1 END AS letter
      FROM accounts) t1;

---




-- Question 4 

-- Consider vowels as a, e, i, o, and u. What proportion of company names start with a vowel, and what percent start with anything else?
SELECT Count(*),
 CASE WHEN LEFT(UPPER(name), 1) IN ('A', 'E', 'I', 'O','U')
                       THEN 1 ELSE 0 END AS start_vowel 
 FROM accounts
 GROUP BY start_vowel
 
 -- The sum solution given by Udacity seems more cleaner than mine. 
 
 SELECT SUM (start_vowel) as vowels, SUM (not_start_vowel) as not_vowels 
 FROM (
 
 SELECT name, 
 CASE WHEN LEFT(UPPER(name), 1) IN ('A', 'E', 'I', 'O','U')
                       THEN 1 ELSE 0 END AS start_vowel,
					   
 CASE WHEN LEFT(UPPER(name), 1) NOT IN ('A', 'E', 'I', 'O','U')
				   THEN 1 ELSE 0 END AS not_start_vowel 				   
 FROM accounts
 ) sub 


-- QUiz POSITION & STRPOS 
-- Use the accounts table to create first and last name columns that hold the first and last names for the primary_poc.

-- We need to find the space
-- Once space position is found we need to use the left & right base don that 

SELECT primary_poc, POSITION (' ' IN primary_poc),

LEFT(primary_poc, POSITION (' ' IN primary_poc)-1) as first_name,
RIGHT(primary_poc, LENGTH(primary_poc)- POSITION (' ' IN primary_poc)) as last_name
FROM accounts 

-- Udacity Solution 
SELECT LEFT(primary_poc, STRPOS(primary_poc, ' ') -1 ) first_name, 
RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name
FROM accounts;

-- Question 2 
-- Now see if you can do the same thing for every rep name in the sales_reps table. Again provide first and last name columns.

SELECT name, POSITION (' ' IN name),
LEFT(name, POSITION (' ' IN name)-1) as first_name,
RIGHT(name, LENGTH(name)- POSITION (' ' IN name)) as last_name
FROM sales_reps 

-- Lets do the same question using STRPOS 
SELECT
LEFT(name, STRPOS(name,' ')-1) as first_name,
RIGHT(name, LENGTH(name)- STRPOS (name,' ')) as last_name
FROM sales_reps 


-- Quiz CONCAT 
-- Each company in the accounts table wants to create an email address for each primary_poc.
--  The email address should be the first name of the primary_poc . last name primary_poc @ company name .com.
-- ist extract first & last names
-- get the name column 
-- 
SELECT 
CONCAT (
	LEFT(primary_poc, STRPOS(primary_poc,' ')-1) ,
	'.'
	RIGHT(primary_poc, LENGTH(primary_poc)- STRPOS (primary_poc,' ')),
	'@',name,
	'.com'
	)
FROM accounts

-- Udacity Solution 
-- They used CTES which looks better
-- Handled for space as well. 
WITH t1 AS (
 SELECT LEFT(primary_poc,     STRPOS(primary_poc, ' ') -1 ) first_name,  RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name, name
 FROM accounts)
SELECT first_name, last_name, CONCAT(first_name, '.', last_name, '@', name, '.com')
FROM t1;

-- Question 2 

-- You may have noticed that in the previous solution some of the company names include spaces,
-- which will certainly not work in an email address.
-- See if you can create an email address that will work by removing all of the spaces in the account name,
-- but otherwise your solution should be just as in question 1. Some helpful documentation is here.
-- https://www.postgresql.org/docs/8.1/functions-string.html

WITH t1 AS (
 SELECT LEFT(primary_poc,     STRPOS(primary_poc, ' ') -1 ) first_name,  RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name, name
 FROM accounts)
SELECT first_name, last_name, CONCAT(first_name, '.', last_name, '@', REPLACE(name, ' ', ''), '.com')
FROM t1;


-- Question 3 

-- We would also like to create an initial password,
-- which they will change after their first log in.
-- The first password will be the first letter of the primary_poc's first name (lowercase), 
--then the last letter of their first name (lowercase), 
--the first letter of their last name (lowercase),
-- the last letter of their last name (lowercase),
-- the number of letters in their first name,
-- the number of letters in their last name,
-- and then the name of the company they are working with,
-- all capitalized with no spaces.

-- First name, last name, company name 
WITH t1 AS (
 SELECT LEFT(primary_poc,STRPOS(primary_poc, ' ') -1 ) first_name,
 RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name,
 name
 FROM accounts),
 
  t2 as (
 SELECT 

 LEFT (first_name,1) as ist_istname, 
 RIGHT (first_name,1) as last_istname,
 LENGTH (first_name) as len_1stname, 
 LENGTH (last_name) as len_LAstname,
 UPPER(name) as upper_name 
  from t1
)
select CONCAT(ist_istname,last_istname,len_1stname,len_LAstname,upper_name  )
FROM t2

-- So I was not able to concatenate by extracting within the contenate 

-- Udacity Solution 
WITH t1 AS (
 SELECT LEFT(primary_poc,
 STRPOS(primary_poc, ' ') -1 ) first_name,
 RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name,
 name
 FROM accounts)
 
SELECT 
first_name, 
last_name, 
CONCAT(first_name, '.', last_name, '@', name, '.com'),
LEFT(LOWER(first_name), 1) || RIGHT(LOWER(first_name), 1) || LEFT(LOWER(last_name), 1) || RIGHT(LOWER(last_name), 1) 
|| LENGTH(first_name) || LENGTH(last_name) || REPLACE(UPPER(name), ' ', '')
FROM t1;


-- CAST Section 

-- Date is in this format = 01/31/2014 08:00:00 AM +0000
-- IN SQL correct format is yyyy-mm-day


-- Ist we need to extract year, month, day separately 
-- Than we need to concatenate them 
substring(string [from <str_pos>] [for <ext_char>])

SELECT 
(SUBSTRING(date,7,4) ||'-'|| SUBSTRING(date,1,2) || '-' || SUBSTRING(date,4,2))::date as date_formatted
FROM sf_crime_data

-- Udacity Solution 
SELECT date orig_date, (SUBSTR(date, 7, 4) || '-' || LEFT(date, 2) || '-' || SUBSTR(date, 4, 2))::DATE new_date
FROM sf_crime_data;



-- COALESCE

SELECT  COALESCE(a.id, a.id) filled_id,a.name, a.website, a.lat, a.long, a.primary_poc, a.sales_rep_id,o.*
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;


SELECT  COALESCE(o.id, a.id) filled_id,a.name, a.website, a.lat, a.long, a.primary_poc, a.sales_rep_id,o.*
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;








SELECT COALESCE(a.id, a.id) filled_id, 
a.name, a.website, a.lat, a.long, a.primary_poc, a.sales_rep_id, 
COALESCE(o.account_id, a.id)
 account_id, o.occurred_at, o.standard_qty, o.gloss_qty, o.poster_qty, o.total, o.standard_amt_usd, o.gloss_amt_usd, o.poster_amt_usd, o.total_amt_usd
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;


SELECT COALESCE(a.id, a.id) filled_id, a.name, a.website, a.lat, a.long, a.primary_poc, a.sales_rep_id,
COALESCE(o.account_id, a.id) account_id, o.occurred_at, 
COALESCE(o.standard_qty, 0) standard_qty, COALESCE(o.gloss_qty,0) gloss_qty, COALESCE(o.poster_qty,0) poster_qty, COALESCE(o.total,0) total, COALESCE(o.standard_amt_usd,0) standard_amt_usd, COALESCE(o.gloss_amt_usd,0) gloss_amt_usd, COALESCE(o.poster_amt_usd,0) poster_amt_usd, COALESCE(o.total_amt_usd,0) total_amt_usd
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;