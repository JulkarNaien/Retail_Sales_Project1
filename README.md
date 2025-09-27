# Retail_Sales_Project1
# Retail Sales Analysis Project

## Overview
This project is a comprehensive analysis of retail sales data. The goal is to understand sales patterns, customer behavior, product profitability, and to provide actionable insights to increase revenue and profit. 

The dataset includes the following columns:

- `transactions_id` – Unique identifier for each transaction
- `sale_date` – Date of sale
- `sale_time` – Time of sale
- `customer_id` – Unique customer identifier
- `gender` – Customer gender
- `age` – Customer age
- `category` – Product category
- `quantity` – Number of items sold
- `price_per_unit` – Price per unit of product
- `cogs` – Cost of goods sold
- `total_sale` – Total sale amount

---

## Table Setup and Data Cleaning

**Check table content and record count:**
```sql
SELECT * FROM dbo.retail_sales;
SELECT COUNT(*) FROM retail_sales;
Remove null values:

DELETE FROM retail_sales
WHERE transactions_id IS NULL 
   OR sale_date IS NULL 
   OR sale_time IS NULL 
   OR customer_id IS NULL
   OR gender IS NULL
   OR age IS NULL 
   OR category IS NULL
   OR quantity IS NULL
   OR price_per_unit IS NULL
   OR cogs IS NULL 
   OR total_sale IS NULL;
Check duplicates:


SELECT transactions_id, COUNT(transactions_id) 
FROM retail_sales
GROUP BY transactions_id
HAVING COUNT(transactions_id) > 1;
Check gender values and zero/negative entries:


SELECT DISTINCT gender FROM retail_sales;

SELECT * 
FROM retail_sales 
WHERE quantity < 1 
   OR price_per_unit < 1 
   OR cogs < 1 
   OR total_sale < 1;
Level 1 Analysis – Basic Insights
Sales Overview


-- Total sales
SELECT SUM(total_sale) AS Total_sales FROM retail_sales;

-- Total transactions
SELECT COUNT(*) AS Total_Transaction FROM retail_sales;

-- Unique customers
SELECT COUNT(DISTINCT customer_id) AS Unique_Customers FROM retail_sales;
Revenue vs Cost


SELECT ROUND(SUM(cogs),2) AS Total_Cost,
       ROUND(SUM(total_sale) - SUM(cogs),2) AS Gross_Profit
FROM retail_sales;
Product Category Insights


-- Highest sales revenue
SELECT TOP 1 category, SUM(total_sale) AS Category_Sales
FROM retail_sales
GROUP BY category
ORDER BY Category_Sales DESC;

-- Most units sold
SELECT TOP 1 category, SUM(quantity) AS Total_Unit_Sold
FROM retail_sales
GROUP BY category
ORDER BY Total_Unit_Sold DESC;
Customer Demographics


-- Customers by gender
SELECT gender, COUNT(*) AS Number_Of_Customers
FROM retail_sales
GROUP BY gender
ORDER BY Number_Of_Customers DESC;

-- Average age
SELECT AVG(age) AS AverageCustomerAge FROM retail_sales;
Time-Based Insights


-- Total sales per month
SELECT MONTH(sale_date) AS Month, SUM(total_sale) AS MonthlySales
FROM retail_sales
GROUP BY MONTH(sale_date)
ORDER BY Month(sale_date) ASC;

-- Day of the week with highest sales
SELECT TOP 1 DATENAME(WEEKDAY, sale_date) AS Weekday,
       SUM(total_sale) AS DailySales
FROM retail_sales
GROUP BY DATENAME(WEEKDAY, sale_date)
ORDER BY DailySales DESC;
Level 2 Analysis – Trends and Segmentation
Customer Behavior

sql
Copy code
-- Average spending per customer
SELECT customer_id, ROUND(AVG(total_sale),2) AS Average_Spending
FROM retail_sales
GROUP BY customer_id
ORDER BY Average_Spending DESC;

-- Top 10 buyers
SELECT TOP 10 customer_id AS Buyers, SUM(total_sale) AS Total_Sales
FROM retail_sales
GROUP BY customer_id
ORDER BY Total_Sales DESC;
Category Analysis


-- Highest profit margin category
SELECT category,
       ROUND(((SUM(total_sale) - SUM(cogs))/SUM(total_sale))*100,2) AS Profit_Margin
FROM retail_sales
GROUP BY category
ORDER BY Profit_Margin DESC;

-- Sales by gender per category
SELECT category, gender, SUM(total_sale) AS Sales_By_Gender
FROM retail_sales
GROUP BY category, gender
ORDER BY Sales_By_Gender DESC;
Time & Peak Hours


-- Peak sales hour
SELECT DATEPART(HOUR, sale_time) AS hour, SUM(total_sale) AS HourlySales
FROM retail_sales
GROUP BY DATEPART(HOUR, sale_time)
ORDER BY HourlySales DESC;

-- Weekend vs weekday sales
SELECT CASE WHEN DATENAME(WEEKDAY,sale_date) IN ('Friday','Saturday') THEN 'WEEKEND'
            ELSE 'WEEKDAY' END AS DayType,
       SUM(total_sale) AS Total_Sales
FROM retail_sales
GROUP BY CASE WHEN DATENAME(WEEKDAY,sale_date) IN ('Friday','Saturday') THEN 'WEEKEND'
              ELSE 'WEEKDAY' END
ORDER BY Total_Sales DESC;
Age Segmentation


-- Age group with highest sales
SELECT CASE WHEN age BETWEEN 18 AND 25 THEN '18-25'
            WHEN age BETWEEN 26 AND 35 THEN '26-35'
            WHEN age BETWEEN 36 AND 45 THEN '36-45'
            WHEN age BETWEEN 45 AND 60 THEN '45-60'
            ELSE '60+' END AS AgeGroup,
       SUM(total_sale) AS Total_Sales
FROM retail_sales
GROUP BY CASE WHEN age BETWEEN 18 AND 25 THEN '18-25'
              WHEN age BETWEEN 26 AND 35 THEN '26-35'
              WHEN age BETWEEN 36 AND 45 THEN '36-45'
              WHEN age BETWEEN 45 AND 60 THEN '45-60'
              ELSE '60+' END
ORDER BY Total_Sales DESC;
Transaction Patterns


-- Repeat customers
WITH RepeatCustomers AS (
  SELECT customer_id, COUNT(transactions_id) AS Repetation, SUM(total_sale) AS TotalSpend
  FROM retail_sales
  GROUP BY customer_id
  HAVING COUNT(transactions_id) > 1
)
SELECT COUNT(*) AS RepeatCustomerCount,
       SUM(TotalSpend) AS GrandTotal,
       SUM(TotalSpend) / (SELECT SUM(total_sale) FROM retail_sales) * 100 AS Percentage
FROM RepeatCustomers;

-- Average quantity per transaction
SELECT ROUND(AVG(quantity),0) AS AverageTransaction FROM retail_sales;
Level 3 Analysis – Advanced Insights
Profitability Analysis


-- Top profitable customers
SELECT TOP 10 customer_id, ROUND(SUM(total_sale),0) AS Revenue,
       ROUND(SUM(cogs),0) AS Total_Cost,
       ROUND(SUM(total_sale) - SUM(cogs),0) AS Profit
FROM retail_sales
GROUP BY customer_id
ORDER BY Profit DESC;

-- Most profitable categories
SELECT category, ROUND(SUM(total_sale),0) AS Revenue,
       ROUND(SUM(cogs),0) AS Total_Cost,
       ROUND(SUM(total_sale) - SUM(cogs),0) AS Profit,
       ROUND((SUM(total_sale) - SUM(cogs))/SUM(total_sale)*100,3) AS ProfitMargin
FROM retail_sales
GROUP BY category
ORDER BY Profit DESC;
Customer Lifetime Value


SELECT customer_id, COUNT(*) AS Transactions,
       ROUND(AVG(total_sale),0) AS AvgOrderValue,
       SUM(total_sale) AS TotalRevenue,
       ROUND(SUM(total_sale - cogs),0) AS TotalProfit
FROM retail_sales
GROUP BY customer_id
ORDER BY TotalRevenue DESC;
Sales Forecasting & Seasonal Trends


-- Next month sales by category
SELECT YEAR(sale_date) AS Year, MONTH(sale_date) AS Month,
       category, SUM(total_sale) AS TotalSales
FROM retail_sales
GROUP BY YEAR(sale_date), MONTH(sale_date), category
ORDER BY Year, Month, category;

-- Seasonal trends
SELECT DATENAME(MONTH, sale_date) AS Month, SUM(total_sale) AS TotalSales
FROM retail_sales
GROUP BY DATENAME(MONTH, sale_date)
ORDER BY TotalSales DESC;
Product & Inventory Optimization


-- Underperforming products
SELECT category, SUM(total_sale) AS Revenue, AVG(total_sale) AS AverageRevenue
FROM retail_sales
GROUP BY category 
HAVING SUM(total_sale) < (SELECT AVG(total_sale) FROM retail_sales);

-- Frequently bought together (Market Basket Analysis)
-- [Additional analysis can be implemented with pairwise grouping]

Strategic Recommendations
Focus on top customers and high-margin categories to maximize profit.
Offer bundled promotions for frequently bought-together products.
Launch loyalty programs to retain repeat buyers.
Optimize inventory and COGS for low-performing products.
Align marketing campaigns with peak sales periods and high-value customer segments.
Conclusion
This project provides a full view of sales, customer behavior, and product performance. The insights derived here can be directly applied to increase revenue, optimize inventory, improve customer retention, and plan targeted marketing campaigns.

Tools Used
SQL Server for data cleaning and analysis












