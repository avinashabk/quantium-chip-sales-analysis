-- Creating database for task 2 of quantium project i.e. store trial control analysis
CREATE DATABASE Quantium_2_Project
GO

USE Quantium_2_Project
GO

-- Creating Monthly Store Metrics

SELECT 
STORE_NBR,
YEAR(DATE) AS Date_year,
MONTH(DATE) AS Date_month,
SUM(TOT_SALES) AS total_sales,
COUNT(DISTINCT LYLTY_CARD_NBR) AS total_customers,
COUNT(DISTINCT TXN_ID) * 1.0 / COUNT(DISTINCT LYLTY_CARD_NBR) AS transaction_per_customer
INTO store_monthly_metrics
FROM QVI_data
GROUP BY STORE_NBR,
YEAR(DATE),
MONTH(DATE);

-- Checking the store monthly metrics table
SELECT *
FROM store_monthly_metrics
ORDER BY STORE_NBR

-- Identifying Trial Stores

SELECT *
FROM store_monthly_metrics
WHERE STORE_NBR IN (77,86,88)
ORDER BY STORE_NBR, Date_year, Date_month;

-- Comparing Trial vs Control Stores for eg.with 233
SELECT 
STORE_NBR,
SUM(total_sales) AS sales
FROM store_monthly_metrics
WHERE STORE_NBR IN (77,233)
GROUP BY STORE_NBR;

/* We need to identify the control stores which meet the 
3 conditions*/ 
-- 1st - Stores with data for all 12 months
SELECT STORE_NBR
INTO valid_stores
FROM store_monthly_metrics
GROUP BY STORE_NBR
HAVING COUNT(*) = 12;

-- To Check
SELECT * 
FROM valid_stores
ORDER BY STORE_NBR ASC;

-- 2nd - Keep only pre trial months
SELECT *
INTO pretrial_metrics
FROM store_monthly_metrics
WHERE (Date_year = 2018 OR (Date_year = 2019 AND Date_month = 1));

-- To Check
SELECT *
FROM pretrial_metrics

-- 3rd -  Compare Trial stores to all potential control stores
-- 77 vs rest

SELECT
C.STORE_NBR AS control_store,
AVG(ABS(T.total_sales - C.total_sales)) AS sales_diff,
AVG(ABS(T.total_customers - C.total_customers)) AS customer_diff,
AVG(ABS(T.transaction_per_customer - C.transaction_per_customer)) AS transaction_diff
FROM pretrial_metrics AS T
JOIN pretrial_metrics AS C
ON T.Date_month = C.Date_month AND T.Date_year = C.Date_year
WHERE T.STORE_NBR = 77
AND C.STORE_NBR NOT IN (77,86,88)
GROUP BY C.STORE_NBR
ORDER BY sales_diff, customer_diff, transaction_diff; -- gave 233,255...


-- 86 vs rest

SELECT
C.STORE_NBR AS control_store,
AVG(ABS(T.total_sales - C.total_sales)) AS sales_diff,
AVG(ABS(T.total_customers - C.total_customers)) AS customer_diff,
AVG(ABS(T.transaction_per_customer - C.transaction_per_customer)) AS transaction_diff
FROM pretrial_metrics AS T
JOIN pretrial_metrics AS C
ON T.Date_month = C.Date_month AND T.Date_year = C.Date_year
WHERE T.STORE_NBR = 86
AND C.STORE_NBR NOT IN (77,86,88)
GROUP BY C.STORE_NBR
ORDER BY sales_diff, customer_diff, transaction_diff; -- gave 109,155...

-- 88 vs rest 

SELECT
C.STORE_NBR AS control_store,
AVG(ABS(T.total_sales - C.total_sales)) AS sales_diff,
AVG(ABS(T.total_customers - C.total_customers)) AS customer_diff,
AVG(ABS(T.transaction_per_customer - C.transaction_per_customer)) AS transaction_diff
FROM pretrial_metrics AS T
JOIN pretrial_metrics AS C
ON T.Date_month = C.Date_month AND T.Date_year = C.Date_year
WHERE T.STORE_NBR = 88
AND C.STORE_NBR NOT IN (77,86,88)
GROUP BY C.STORE_NBR
ORDER BY sales_diff, customer_diff, transaction_diff; -- gave 237,203


