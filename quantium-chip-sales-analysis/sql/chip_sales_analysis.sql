-- Create a DataBase
CREATE DATABASE Quantium_Project;
GO

USE Quantium_Project;
GO

-- Testing the data imported
SELECT TOP 10 *
FROM transactions

SELECT TOP 10 * 
FROM customers

SELECT COUNT (*) AS 'rows_tra'
FROM transactions

SELECT COUNT(*) AS 'rows_cust'
FROM customers

-- Checking for Null Values & Negative values
SELECT *
FROM transactions
WHERE PROD_NAME IS NULL
OR PROD_QTY IS NULL
OR TOT_SALES IS NULL

SELECT *
FROM transactions
WHERE PROD_QTY <= 0
OR TOT_SALES <= 0;

-- To check for Outliers
SELECT *
FROM transactions
ORDER BY PROD_QTY DESC;

-- Removing the Outliers
DELETE 
FROM transactions
WHERE PROD_QTY >= 200;


/* Converting the date column from serial number to a proper date
and adding it to the table 
and also removing the original date column afterwards */
--To check the conversion
SELECT 
CAST(DATEADD(day,DATE,'1899-12-30') AS DATE) AS TRANSACTION_DATE
FROM transactions
-- To add the transaction date column
ALTER TABLE transactions
ADD TRANSACTION_DATE DATE;
-- to update the column with proper date type
UPDATE transactions
SET TRANSACTION_DATE = 
CAST(DATEADD(day,DATE,'1899-12-30') AS DATE);
-- to check whether the new column is added properly
SELECT TOP 20
DATE,
TRANSACTION_DATE
FROM transactions;
-- To drop the DATE column
ALTER TABLE transactions
DROP COLUMN DATE;






-- Extract the pack size and brand name from the PROD_NAME Column

 /* Extracting pack size from the PROD_NAME.
In PROD_NAME Columns in transactions table some products have their 
Pack size mentioned at the middle instead of only at the end */


ALTER TABLE transactions
ADD PACK_SIZE VARCHAR(50);

UPDATE transactions
SET PACK_SIZE =
SUBSTRING(PROD_NAME,PATINDEX('%[0-9][0-9][0-9][gG]%', PROD_NAME),
    3)
WHERE PATINDEX('%[0-9][0-9][0-9][gG]%', PROD_NAME) > 0;


SELECT TOP 70
PROD_NAME,
PACK_SIZE
FROM transactions;

-- Extracting the brand name from the PROD_NAME
ALTER TABLE transactions
ADD BRAND VARCHAR(50);

UPDATE transactions
SET BRAND = LEFT(PROD_NAME, CHARINDEX(' ', PROD_NAME) - 1);

SELECT TOP 70
PROD_NAME,
BRAND
FROM transactions;

-- Checking unique brands
SELECT DISTINCT BRAND
FROM transactions
ORDER BY BRAND

/* Removing the Salsa Products as they do not contain chips */
-- Checking Salsa products
SELECT *
FROM transactions
WHERE PROD_NAME LIKE '%Salsa%'
-- Removign Salsa Products
DELETE FROM transactions
WHERE PROD_NAME LIKE '%Salsa%';

/* Standardizing Brand names for consistency as the names are repeated with different names */

UPDATE transactions
SET BRAND = 'Doritos'
WHERE BRAND = 'Dorito';

UPDATE transactions
SET BRAND = 'Infuzions'
WHERE BRAND = 'Infzns';

UPDATE transactions
SET BRAND = 'Smiths'
WHERE BRAND = 'Smith';

UPDATE transactions
SET BRAND = 'Sunbites'
WHERE BRAND = 'Snbts';

UPDATE transactions
SET BRAND = 'Woolworths'
WHERE BRAND = 'WW';

UPDATE transactions
SET BRAND = 'Red Rock Deli'
WHERE BRAND = 'Red';

UPDATE transactions
SET BRAND = 'RRD'
WHERE BRAND = 'Red Rock Deli'

-- check unique brands once again
SELECT DISTINCT BRAND
FROM transactions
ORDER BY BRAND;


-- Merging customer data into a new table

SELECT
t.*,
c.LIFESTAGE,
c.PREMIUM_CUSTOMER
INTO chip_sales
FROM transactions AS t
JOIN customers AS c
ON t.LYLTY_CARD_NBR = c.LYLTY_CARD_NBR;

-- Verifying the new table

SELECT TOP 20 *
FROM chip_sales;


/* Analysing the data and Answering the questions */

-- Which customer segment spends the most on chips?

SELECT
LIFESTAGE,
PREMIUM_CUSTOMER,
SUM(TOT_SALES) AS total_sales
FROM chip_sales
GROUP BY 
LIFESTAGE,
PREMIUM_CUSTOMER
ORDER BY total_sales DESC;

-- What are the Average Quantity of chips ordered by customers?

SELECT
LIFESTAGE,
PREMIUM_CUSTOMER,
AVG(PROD_QTY) AS avg_quantity
FROM chip_sales
GROUP BY
LIFESTAGE,
PREMIUM_CUSTOMER
ORDER BY avg_quantity DESC;

-- What is the Average price per chip pack?

SELECT 
LIFESTAGE,
PREMIUM_CUSTOMER,
SUM(TOT_SALES)/SUM(PROD_QTY) AS avg_price_per_pack
FROM chip_sales
GROUP BY 
LIFESTAGE,
PREMIUM_CUSTOMER
ORDER BY avg_price_per_pack DESC;

-- What is the preferred pack size?

SELECT
PACK_SIZE,
SUM(PROD_QTY) AS total_pack_sold
FROM chip_sales
GROUP BY PACK_SIZE
ORDER BY total_pack_sold DESC;

-- Which brand is most popular?

SELECT 
BRAND,
SUM(PROD_QTY) AS total_brand_sold
FROM chip_sales
GROUP BY BRAND
ORDER BY total_brand_sold DESC;

-- What is the average spend per transaction by customer segment?

SELECT 
LIFESTAGE,
PREMIUM_CUSTOMER,
SUM(TOT_SALES)/ COUNT(DISTINCT TXN_ID) AS avg_spend_per_transaction
FROM chip_sales
GROUP BY
LIFESTAGE,
PREMIUM_CUSTOMER
ORDER BY avg_spend_per_transaction DESC;




