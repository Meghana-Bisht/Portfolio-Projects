--PIZZA SALES

SELECT * 
FROM pizza_sales;

-- KPI's Requirement

--Query1- Total Revenue: Sum of total price of all pizza orders
SELECT SUM(total_price) AS Total_Revenue
FROM pizza_sales
;

--Query2 - Average order Value: Average amount spent per order
SELECT  SUM(total_price) / COUNT(DISTINCT(order_id)) AS Avg_Order_Value
FROM pizza_sales
;

--Query3 - Total Pizzas Sold: Sum of quantity pizzas sold
SELECT SUM(quantity) AS Total_pizza_sold
FROM pizza_sales
;

--Query4 - Total Orders: Total numbers of orders placed
SELECT COUNT(DISTINCT(order_id)) AS Total_Orders
FROM pizza_sales
;

--Query5 - Average Pizzas per order: Total no. of pizzas sold by total no. of orders
SELECT CAST(CAST(SUM(quantity) AS DECIMAL(10,2)) / 
CAST(COUNT(DISTINCT(order_id)) AS DECIMAL(10,2)) AS DECIMAL (10,2)) AS Avg_pizzas_per_order
FROM pizza_sales
;

-- Chart Requirement

--Query1 - Daily Trend for Total orders
SELECT DATENAME(DW,order_date) AS order_day, COUNT(DISTINCT order_id) AS Total_orders
FROM pizza_sales
GROUP BY DATENAME(DW,order_date)
;

--Query2 - Hourly Trend for Total orders
SELECT DATEPART(HOUR,order_time) AS order_hours, COUNT(DISTINCT order_id) AS Total_orders
FROM pizza_sales
GROUP BY DATEPART(HOUR,order_time)
ORDER BY DATEPART(HOUR,order_time)
;

--Query3 - Percentage of Sales by Pizza Category
SELECT pizza_category, CAST(SUM(total_price) AS DECIMAL(10,2)) AS Total_Revenue,
CAST(SUM(total_price) * 100 /
(SELECT SUM(total_price) FROM pizza_sales) AS DECIMAL(10,2)) AS Percentage_of_sales
FROM pizza_sales
--WHERE MONTH(order_date) = 1
GROUP BY pizza_category
;

--Query4 - Percentage of Sales by Pizza Size
SELECT pizza_size, CAST(SUM(total_price) AS DECIMAL(10,2)) AS Total_Revenue,
CAST(SUM(total_price) * 100 /
(SELECT SUM(total_price) FROM pizza_sales) AS DECIMAL(10,2)) AS Percentage_of_sales
FROM pizza_sales
GROUP BY pizza_size
ORDER BY Percentage_of_sales DESC
;

--Query5 - Total Pizzas sold by pizza category
SELECT pizza_category, CAST(SUM(quantity) AS DECIMAL(10,2)) AS Total_Pizzas_Sold
FROM pizza_sales
GROUP BY pizza_category
;

--Query6 - Top 5 Best Sellers by total pizzas sold
SELECT TOP 5 pizza_name,SUM(quantity) AS Total_Pizzas_Sold
FROM pizza_sales
GROUP BY pizza_name
ORDER BY SUM(quantity) DESC
;

--Query7 - Bottom 5 worst sellers by total pizzas sold
SELECT TOP 5 pizza_name,SUM(quantity) AS Total_Pizzas_Sold
FROM pizza_sales
WHERE MONTH(order_date) = 1
GROUP BY pizza_name
ORDER BY SUM(quantity)
;
