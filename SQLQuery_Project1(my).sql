
-------------------
-- table checking-- 
--------------------
SELECT * FROM dbo.retail_sales;

select COUNT(*) 
FROM retail_sales
----------------
-- table setup -- 
-----------------

-- removing nulls

DELETE FROM retail_sales
WHERE 
transactions_id IS NULL 
OR sale_date IS NULL 
OR sale_time IS NULL 
OR customer_id IS NULL 
OR gender IS NULL
OR age IS NULL 
OR category IS NULL
OR quantity IS NULL
OR price_per_unit IS NULL
OR cogs IS NULL 
OR total_sale IS NULL


SELECT * 
FROM retail_sales

----------------------------
-- Checking any duplicates
-------------------------
SELECT 
	transactions_id, 
	count(transactions_id) 
FROM retail_sales
GROUP BY transactions_id
HAVING 	count(transactions_id) > 1

--------------------
-- checking gender 
-----------------------
SELECT 
	 DISTINCT gender 
FROM retail_sales

---------------------------------------------
-- checking zero or negative value if exist
-----------------------------------------------
SELECT * 
FROM retail_sales 
WHERE quantiy < 1 
OR price_per_unit < 1 
OR cogs < 1 
OR total_sale < 1

----------------------
--- Data Analysis Part 
----------------------


------------------------------------------LEVEL 1---------------------
-----------------------------------------
--REQIREMENTS: Quick insights and simple aggregations
-----------------------------------------
/* 
Sales Overview
1.	What is the total sales for the period covered in the dataset?
2.	How many transactions were made in total?
3.	How many unique customers purchased from us?
Revenue vs Cost
4.	What is the total cost of goods sold and gross profit (Total Sales – COGS)?
Product Category Insights
5.	Which product category has the highest sales revenue?
6.	Which category is sold the most by quantity?
Customer Demographics
7.	How many male vs female customers purchased products?
8.	What is the average age of our customers?
Time-Based Insights
9.	What is the total sales per day or per month?
10.	Which day of the week has the highest sales?
*/

------------------------------------SOLUTION--------------------------------------
---------------------
--Sales Overview
----------------------

--1.What is the total sales for the period covered in the dataset?

SELECT 
SUM(total_sale) AS Total_sales
FROM retail_sales

--2.How many transactions were made in total?

SELECT
	COUNT(*) AS Total_Transaction
FROM retail_sales

--3.How many unique customers purchased from us?

SELECT 
	COUNT(DISTINCT customer_id) AS Unique_Customers 
FROM retail_sales

-------------------
--Revenue vs Cost
--------------------
--4.What is the total cost of goods sold and gross profit (Total Sales – COGS)?

SELECT 
	ROUND(SUM(cogs),2) AS Total_Cost,
	ROUND(SUM(total_sale) - SUM(cogs),2) AS Gross_Profit
FROM retail_sales


----------------------------
--Product Category Insights
----------------------------
--5.Which product category has the highest sales revenue?

SELECT TOP 1
	category,
	SUM(total_sale) AS Category_Sales
FROM retail_sales
GROUP BY category 
ORDER BY Category_Sales DESC


--6.Which category is sold the most by quantity?

SELECT TOP 1
	category,
	SUM(quantity) AS Total_Unit_Sold
FROM retail_sales
GROUP BY category 
ORDER BY Total_Unit_Sold DESC

------------------------
--Customer Demographics
------------------------
--7.How many male vs female customers purchased products?

SELECT 
	gender,
	COUNT(*) AS Number_Of_Customers
FROM retail_sales
GROUP BY gender
ORDER BY Number_Of_Customers DESC

--8.What is the average age of our customers?

SELECT 
AVG(age) AS AverageCustomerAge
FROM retail_sales


-----------------------
--Time-Based Insights
-----------------------

--9.What is the total sales per month?

SELECT 
	Month(sale_date) AS Month,
	SUM(total_sale) AS MonthlySales
FROM retail_sales
GROUP BY Month(sale_date)
ORDER BY Month(sale_date) ASC



--10.Which day of the week has the highest sales?


SELECT TOP 1
	DATENAME(WEEKDAY,sale_date) AS Weekday,
	SUM(total_sale) AS DailySales
FROM retail_sales
GROUP BY DATENAME(WEEKDAY,sale_date)
ORDER BY DailySales DESC


--------------------------------------LEVEL 2 ----------------------------------------
/*
----------------------------------------------
REQUIREMENT: Trends, segmentation, and basic patterns
----------------------------------------------
Customer Behavior
	1.What is the average spending per customer?
	2.Which customers are the top 10 buyers in terms of total sales?
Category Analysis
	3.Which category generates the highest profit margin? (Profit Margin = (Total Sales – COGS)/Total Sales)
	4.Are certain categories preferred by male vs female customers?
Time & Peak Hours
	5.What is the peak time of day for sales?
	6.Do weekends vs weekdays show significant differences in sales?
Age Segmentation
	7.Which age group spends the most on average?
	8.Are certain products more popular with specific age groups?
Transaction Patterns
	9.Are there repeat customers? If yes, what percentage of total sales comes from repeat buyers?
	10.What is the average quantity per transaction?
*/
------------------------------SOLUTION------------------------------------
-------------------
--Customer Behavior
-------------------

--1.What is the average spending per customer?

SELECT 
	customer_id,
	ROUND(AVG(total_sale),2) AS Average_Spending
FROM retail_sales
GROUP BY customer_id 
ORDER BY Average_Spending DESC 

--2.Which customers are the top 10 buyers in terms of total sales?

SELECT TOP 10
	customer_id AS Buyers,
	SUM(total_sale) AS Total_Sales
FROM retail_sales
GROUP BY customer_id
ORDER BY Total_Sales DESC

-------------------
--Category Analysis
--------------------
--3.Which category generates the highest profit margin? (Profit Margin = (Total Sales – COGS)/Total Sales)

SELECT 
	category,
	ROUND(((SUM(total_sale) - SUM(cogs) )/ SUM(total_sale) )*100,2) AS Profit_Margin
FROM retail_sales
GROUP BY category 
ORDER BY Profit_Margin DESC 

--4.Are certain categories preferred by male vs female customers?

SELECT 
	category,
	gender,
	SUM(total_sale) AS Sales_By_Gender
FROM retail_sales
GROUP BY category,gender
ORDER BY Sales_By_Gender DESC


------------------
--Time & Peak Hours
-------------------
--5.What is the peak time of day for sales?

SELECT 
	DATEPART(HOUR,sale_time) AS hour,
	SUM(Total_sale) AS HourlySales
FROM retail_sales
GROUP BY DATEPART(HOUR,sale_time) 
ORDER BY HourlySales DESC


--6.Do weekends vs weekdays show significant differences in sales?

SELECT
	CASE 
		WHEN DATENAME(WEEKDAY,sale_date) IN ('Friday','Saturday') THEN 'WEEKEND'
		ELSE 'WEEKDAY'
	END AS DayType,
	SUM(total_sale) AS Total_Sales
FROM retail_sales
GROUP BY CASE 
		WHEN DATENAME(WEEKDAY,sale_date) IN ('Friday','Saturday') THEN 'WEEKEND'
		ELSE 'WEEKDAY'
	END
ORDER BY Total_Sales DESC

-----------------
--Age Segmentation
-----------------
--7.Which age group spends the most on average?

SELECT 
	CASE 
		WHEN age BETWEEN 18 AND 25 THEN '18-25'
		WHEN age BETWEEN 26 AND 35 THEN '26-35'
		WHEN age BETWEEN 36 AND 45 THEN '36-45'
		WHEN age BETWEEN 45 AND 60 THEN '45-60'
		ELSE '60+'
	END AS AgeGroup,
	SUM(total_sale) AS Total_Sales
FROM retail_sales
GROUP BY 
CASE 
		WHEN age BETWEEN 18 AND 25 THEN '18-25'
		WHEN age BETWEEN 26 AND 35 THEN '26-35'
		WHEN age BETWEEN 36 AND 45 THEN '36-45'
		WHEN age BETWEEN 45 AND 60 THEN '45-60'
		ELSE '60+'
	END
ORDER BY Total_Sales DESC


--8.Are certain products more popular with specific age groups?

SELECT 
	category,
	CASE 
		WHEN age BETWEEN 18 AND 25 THEN '18-25'
		WHEN age BETWEEN 26 AND 35 THEN '26-35'
		WHEN age BETWEEN 36 AND 45 THEN '36-45'
		WHEN age BETWEEN 45 AND 60 THEN '45-60'
		ELSE '60+'
	END AS AgeGroup,
	SUM(total_sale) AS Total_Sales
FROM retail_sales
GROUP BY 
category,
CASE 
		WHEN age BETWEEN 18 AND 25 THEN '18-25'
		WHEN age BETWEEN 26 AND 35 THEN '26-35'
		WHEN age BETWEEN 36 AND 45 THEN '36-45'
		WHEN age BETWEEN 45 AND 60 THEN '45-60'
		ELSE '60+'
	END
ORDER BY Total_Sales DESC


----------------------
--Transaction Patterns
----------------------

--9.Are there repeat customers? If yes, what percentage of total sales comes from repeat buyers?

WITH RepeatCustomers AS (
	SELECT 
	customer_id,
	COUNT(transactions_id) AS Repetation,
	sum(total_sale ) AS TotalSpend
FROM retail_sales
GROUP BY customer_id
HAVING COUNT(transactions_id) > 1
)

SELECT 
	COUNT(*) AS RepeatCustomerCount,
	SUM(TotalSpend) AS GrandTotal,
	SUM(TotalSpend)  / (SELECT SUM(total_sale) FROM retail_sales) * 100 AS percentage
FROM RepeatCustomers

--10.What is the average quantity per transaction?

SELECT 
	ROUND(AVG(quantity),0) AS AverageTransaction
FROM retail_sales


---------------------------------------------LEVEL 3 ----------------------------------
/*
------------------------------------------------------------------
--Advanced insights, predictive thinking, and business optimization
-----------------------------------------------------------------

Profitability Analysis
	1.Which customers or segments are most profitable? (Revenue vs COGS)
	2.Which product categories or combinations yield the highest profit?
Customer Lifetime Value
	3.Can you estimate lifetime value (LTV) of customers based on their historical purchases?
	4.Which customer segment should we focus marketing on for future growth?
Sales Forecasting
	5.Can you predict next month’s sales per category using historical trends?
	6.Identify seasonal patterns or trends over time.
Product & Inventory Optimization
	7.Which products are underperforming and may need a discount/promotion?
	8.Which products are frequently bought together? (Market Basket Analysis)
Strategic Recommendations
	9.Based on the analysis, which categories, age groups, or times should we target to maximize sales?
	10.If we want to increase profit by 10%, where should we focus: increasing prices, reducing COGS, or selling more to high-value customers?
*/

----------------------------------------SOLUTION---------------------------------------

-------------------------
--Profitability Analysis
-------------------------
--1.Which customers or segments are most profitable? (Revenue vs COGS)

-- Profitable Customer

SELECT TOP 10
	customer_id,
	ROUND(SUM(total_sale),0) AS Reveneue,
	ROUND(SUM(cogs),0) AS Total_Cost,
	ROUND(SUM(total_sale) - SUM(cogs),0) AS Profit
FROM dbo.retail_sales
GROUP BY customer_id
ORDER BY Profit DESC

-- most profitable category segment
SELECT 
	category,
	ROUND(SUM(total_sale),0) AS Reveneue,
	ROUND(SUM(cogs),0) AS Total_Cost,
	ROUND(SUM(total_sale) - SUM(cogs),0) AS Profit
	FROM retail_sales
GROUP BY category
ORDER BY Profit DESC


--- most profitable age segment

SELECT 
	CASE 
		WHEN age BETWEEN 18 AND 25 THEN '18-25'
		WHEN age BETWEEN 26 AND 35 THEN '26-35'
		WHEN age BETWEEN 36 AND 45 THEN '36-45'
		WHEN age BETWEEN 45 AND 60 THEN '45-60'
		ELSE '60+'
	END AS AgeGroup,
	ROUND(SUM(total_sale),0) AS Reveneue,
	ROUND(SUM(cogs),0) AS Total_Cost,
	ROUND(SUM(total_sale) - SUM(cogs),0) AS Profit
FROM retail_sales
GROUP BY 
CASE 
		WHEN age BETWEEN 18 AND 25 THEN '18-25'
		WHEN age BETWEEN 26 AND 35 THEN '26-35'
		WHEN age BETWEEN 36 AND 45 THEN '36-45'
		WHEN age BETWEEN 45 AND 60 THEN '45-60'
		ELSE '60+'
	END
ORDER BY Profit DESC

--2.Which product categories or combinations yield the highest profit?

SELECT 
	category,
	ROUND(SUM(total_sale),0) AS Reveneue,
	ROUND(SUM(cogs),0) AS Total_Cost,
	ROUND(SUM(total_sale) - SUM(cogs),0) AS Profit,
	ROUND((SUM(total_sale) - SUM(cogs))/SUM(total_sale) * 100 ,3) AS ProfitMargin
	FROM retail_sales
GROUP BY category
ORDER BY Profit DESC

-------------------------
--Customer Lifetime Value
--------------------------

--3.Can you estimate lifetime value (LTV) of customers based on their historical purchases?

SELECT customer_id,
       COUNT(*) AS Transactions,
       ROUND(AVG(total_sale),0) AS AvgOrderValue,
       SUM(total_sale) AS TotalRevenue,
       ROUND(SUM(total_sale - cogs),0) AS TotalProfit
FROM retail_sales
GROUP BY customer_id
ORDER BY TotalRevenue DESC;

--4.Which customer segment should we focus marketing on for future growth?
SELECT 
	gender,
	CASE 
		WHEN age BETWEEN 18 AND 25 THEN '18-25'
		WHEN age BETWEEN 26 AND 35 THEN '26-35'
		WHEN age BETWEEN 36 AND 45 THEN '36-45'
		WHEN age BETWEEN 45 AND 60 THEN '45-60'
		ELSE '60+'
	END AS AgeGroup,
	ROUND(SUM(total_sale),0) AS Reveneue,
	ROUND(SUM(cogs),0) AS Total_Cost,
	ROUND(SUM(total_sale) - SUM(cogs),0) AS Profit
FROM retail_sales
GROUP BY gender,
CASE 
		WHEN age BETWEEN 18 AND 25 THEN '18-25'
		WHEN age BETWEEN 26 AND 35 THEN '26-35'
		WHEN age BETWEEN 36 AND 45 THEN '36-45'
		WHEN age BETWEEN 45 AND 60 THEN '45-60'
		ELSE '60+'
	END
ORDER BY Profit DESC

--------------------
--Sales Forecasting
--------------------

--5.Can you predict next month’s sales per category using historical trends?

SELECT 
	YEAR(sale_date) AS Year,
	MONTH(sale_date) AS Month,
	category,
	SUM(total_sale) AS TotalSales
FROM dbo.retail_sales
GROUP BY YEAR(sale_date),MONTH(sale_date), category 
ORDER BY YEAR(sale_date),MONTH(sale_date), category

--6.Identify seasonal patterns or trends over time.

SELECT 
	DATENAME(MONTH, sale_date) AS Month,
	SUM(total_sale) AS TotalSales
FROM dbo.retail_sales
GROUP BY DATENAME(MONTH, sale_date)
ORDER BY TotalSales DESC

--------------------------------
--Product & Inventory Optimization
--------------------------------

--7.Which products are underperforming and may need a discount/promotion?

SELECT 
	category,
	SUM(total_sale) AS Revenue,
	AVG(total_sale) AS AverageRevenue
FROM dbo.retail_sales
GROUP BY category 
HAVING SUM(total_sale) < (SELECT AVG(total_sale) FROM dbo.retail_sales)

--8.Which products are frequently bought together? (Market Basket Analysis)

----------------------------
--Strategic Recommendations
----------------------------

--9.Based on the analysis, which categories, age groups, or times should we target to maximize sales?

--10.If we want to increase profit by 10%, where should we focus: increasing prices, reducing COGS, or selling more to high-value customers?
