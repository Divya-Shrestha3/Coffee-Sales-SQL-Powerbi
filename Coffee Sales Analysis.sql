-- creating a new database coffee_shop_sales
create database coffee_shop_sales;
use coffee_shop_sales;
--------------------------------------------------------------
-- viewing the data type of columns
describe coffee_shop_sales;
---------------------------------------------------------------
-- viewing the table coffee_shop_sales
select * from coffee_shop_sales;
---------------------------------------------------------------
-- converting transaction_date into dd/mm/yy
UPDATE coffee_shop_sales 
SET transaction_date = STR_TO_DATE(transaction_date, '%m-%d-%Y');
------------------------------------------------------------------
-- changing data type of transaction_date from text to date
ALTER TABLE coffee_shop_sales
MODIFY COLUMN transaction_date DATE;

-- The 2 above query threw an error as the date in the table does not match the MYSQL standard date format 'YYYY-MM-DD'. 
-- So, I used following steps to solve the problem.

-- Step 1: Adding a temporary column
ALTER TABLE coffee_shop_sales
ADD COLUMN temp_transaction_date DATE;

-- Step 2: Update the temporary column with converted date values
UPDATE coffee_shop_sales
SET temp_transaction_date = STR_TO_DATE(transaction_date, '%m/%d/%Y');

-- Step 4: Drop the original column
ALTER TABLE coffee_shop_sales
DROP COLUMN transaction_date;

-- Step 5: Rename the temporary column to the original column name
ALTER TABLE coffee_shop_sales
CHANGE COLUMN temp_transaction_date transaction_date DATE;

select * from coffee_shop_sales;
describe coffee_shop_sales;
---------------------------------------------------------------------------
-- converting transaction_time into HH:MM:SS
UPDATE coffee_shop_sales 
SET transaction_time = STR_TO_DATE(transaction_time, '%H:%i:%s');
--------------------------------------------------------------------
-- changing data type of transaction_time from text to time
ALTER TABLE coffee_shop_sales
MODIFY COLUMN transaction_time TIME;
----------------------------------------------------------------------
-- Changing column name
ALTER TABLE coffee_shop_sales
CHANGE COLUMN ï»¿transaction_id transaction_id INT;
----------------------------------------------------------------------
-- Finding total sales for any month
select * from coffee_shop_sales;
SELECT SUM((transaction_qty)*(unit_price)) as Total_Sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5;
-----------------------------------------
-- Finding monthly sales increase in percentage
SELECT 
MONTH(transaction_date) As month,
ROUND(SUM(unit_price*transaction_qty)) AS Total_Sales,
(SUM(unit_price*transaction_qty) - LAG(SUM(unit_price*transaction_qty),1)
OVER (ORDER BY MONTH(transaction_date)))/LAG(SUM(unit_price*transaction_qty),1)
OVER(ORDER BY MONTH(transaction_date))*100 AS Monthly_Increase_In_Per
FROM coffee_shop_Sales
WHERE MONTH(transaction_date) IN (4,5)
GROUP BY MONTH(transaction_date)
ORDER BY MONTH(transaction_date);
----------------------------------------------------------------------
-- Finding total number of orders in particular month
select * from coffee_shop_sales;
SELECT COUNT(transaction_id) as Total_Orders
FROM coffee_shop_sales
WHERE MONTH(transaction_date)=3;
------------------------------------------------------
-- Finding monthly count increase in percentage
SELECT 
MONTH(transaction_date) As month,
ROUND(COUNT(transaction_id)) AS Total_Orders,
(COUNT(transaction_id) - LAG(COUNT(transaction_id),1)
OVER (ORDER BY MONTH(transaction_date)))/LAG(COUNT(transaction_id),1)
OVER(ORDER BY MONTH(transaction_date))*100 as MonthlyIncreaseinOrders
FROM coffee_shop_Sales
WHERE MONTH(transaction_date) IN (4,5)
GROUP BY MONTH(transaction_date)
ORDER BY MONTH(transaction_date);
----------------------------------------------------------------------
-- Finding total quantity sold in particular month
select * from coffee_shop_sales;
SELECT SUM(transaction_qty) as Total_Qty_Sold
FROM coffee_shop_sales
WHERE MONTH(transaction_date)=5;
--------------------------------------------------------
-- Finding total sales, total quantity sold and total orders in a particulat date
SELECT 
MONTH(transaction_date) As month,
ROUND(SUM(transaction_qty)) AS Total_Orders,
(SUM(transaction_qty) - LAG(SUM(transaction_qty),1)
OVER (ORDER BY MONTH(transaction_date)))/LAG(SUM(transaction_qty),1)
OVER(ORDER BY MONTH(transaction_date))*100 as MonthlyIncreaseinQuantity
FROM coffee_shop_Sales
WHERE MONTH(transaction_date) IN (4,5)
GROUP BY MONTH(transaction_date)
ORDER BY MONTH(transaction_date);
----------------------------------------------------------------------------
-- Total Sales, Total Quantity Sold and Total orders for particular date
SELECT 
CONCAT(ROUND(SUM(unit_price*transaction_qty)/1000,1),'k') As Total_Sales,
CONCAT(ROUND(SUM(transaction_qty)/1000,1),'k') As Total_Qty_Sold,
CONCAT(ROUND(COUNT(transaction_id)/1000,1),'k') as Total_Orders
FROM coffee_shop_Sales
WHERE transaction_date='2023-05-18'
;
---------------------------------------------------------------------------
-- Sales analysis by weekdays and weekends
-- Weekends - Sat-Sun
-- Weekdays - Mon-Fri

SELECT
CASE 
WHEN DAYOFWEEK(transaction_date) IN (1,7) THEN 'Weekends'
ELSE
'Weekdays'
END AS Day_Type,
CONCAT(ROUND(SUM(unit_price*transaction_qty)/1000,1),'k') AS TotalSales
FROM coffee_Shop_sales
WHERE MONTH(transaction_date)=5
GROUP BY
CASE 
WHEN DAYOFWEEK(transaction_date) IN (1,7) THEN 'Weekends'
ELSE
'Weekdays'
END
;
--------------------------------------------------------------------
-- Total Sales by store location in particular month
SELECT
store_location,
CONCAT(ROUND(SUM(unit_price*transaction_qty)/1000,2),'k') as TotalSales
FROM coffee_shop_sales
WHERE MONTH(transaction_date)=5
GROUP BY store_location
ORDER BY SUM(unit_price*transaction_qty) desc ;
--------------------------------------------------------------------------
-- Average sales in a particular month
SELECT 
	AVG(total_Sales) as AverageSales
FROM
(
	SELECT SUM(unit_price*transaction_qty) as Total_Sales
    FROM
    coffee_Shop_Sales
    WHERE 
    MONTH(transaction_date)=5
    GROUP BY transaction_date
    ) as InnerQuery
    ;
-------------------------------------------------------------------
-- Daily sales for particular month
SELECT
DAY(transaction_date) as Day_Of_Month,
CONCAT(ROUND(SUM(unit_price*transaction_qty)/1000,1),'k') as TotalSales
FROM coffee_shop_sales
WHERE MONTH(transaction_date)=5
GROUP BY DAY(transaction_date)
ORDER BY DAY(transaction_date);
--------------------------------------------------------------------------
-- Finding if total sales is below average or above average
SELECT
CASE
WHEN total_Sales>avg_sales THEN 'Above Average'
WHEN total_Sales<avg_sales THEN 'Below Average'
ELSE 'Average'
END as Sales_Status,
total_sales
FROM
(
SELECT
DAY(transaction_date) as Day_of_Month,
SUM(unit_price*transaction_qty) as Total_Sales,
AVG(SUM(unit_price*transaction_qty)) OVER () AS AVG_SALES
FROM
COFFEE_SHOP_SALES
WHERE MONTH(transaction_date)=5
group by
DAY(transaction_date)
) as Sales_data
ORDER BY
day_of_month;
---------------------------------------------------------------
-- Sales by product category for particular month
SELECT product_category,SUM(unit_price*transaction_qty) as TotalSales
FROM coffee_shop_sales
WHERE MONTH(transaction_date)=5
GROUP BY
product_category;
---------------------------------------------------------------
-- Top 10 products for particulat product category in particular month
SELECT product_type,SUM(unit_price*transaction_qty) as TotalSales
FROM coffee_shop_sales
WHERE MONTH(transaction_date)=5 AND product_category='Coffee'
GROUP BY product_type 
ORDER BY product_type desc
limit 10;
----------------------------------------------------------------------
-- Total sales, Total quantity and Total order for particular hour, day and month
SELECT CONCAT(ROUND(SUM(unit_price*transaction_qty)/1000,1),'k') as TotalSales,
SUM(transaction_qty) as Total_qty_sold,
COUNT(*) as TotalOrders
FROM coffee_shop_sales
WHERE MONTH(transaction_date)=5
AND
DAYOFWEEK(transaction_date)=2
AND
HOUR(transaction_time)=8
;
-----------------------------------------------------------------------
-- Total sales by hour in a particular month
SELECT HOUR(transaction_time) as hourofday,
SUM(unit_price*transaction_qty) as TotalSales
FROM coffee_shop_sales
WHERE MONTH(transaction_date)=5
GROUP BY HOUR(transaction_time)
ORDER BY HOUR(transaction_time);
-------------------------------------------------------------------
-- Total Sales by days in a particular month
SELECT
CASE
WHEN DAYOFWEEK(transaction_date)=2 THEN 'Monday'
WHEN DAYOFWEEK(transaction_date)=3 THEN 'Tuesday'
WHEN DAYOFWEEK(transaction_date)=4 THEN 'Wednesday'
WHEN DAYOFWEEK(transaction_date)=5 THEN 'Thursday'
WHEN DAYOFWEEK(transaction_date)=6 THEN 'Friday'
WHEN DAYOFWEEK(transaction_date)=7 THEN 'Saturday'
ELSE 'Sunday'
END AS Day_of_week,
ROUND(SUM(unit_price*transaction_qty)) as Total_Sales
FROM
coffee_shop_sales
WHERE MONTH(transaction_date) =5
GROUP BY
CASE
WHEN DAYOFWEEK(transaction_date)=2 THEN 'Monday'
WHEN DAYOFWEEK(transaction_date)=3 THEN 'Tuesday'
WHEN DAYOFWEEK(transaction_date)=4 THEN 'Wednesday'
WHEN DAYOFWEEK(transaction_date)=5 THEN 'Thursday'
WHEN DAYOFWEEK(transaction_date)=6 THEN 'Friday'
WHEN DAYOFWEEK(transaction_date)=7 THEN 'Saturday'
ELSE 'Sunday'
END 
;
