-- Basic Queries:

-- 1. Retrieve the total number of orders placed.
SELECT COUNT(order_id) AS total_orders 
FROM orders;
-- This query counts the total number of order IDs in the orders table, representing the total number of orders placed.



-- 2. Calculate the total revenue generated from pizza sales.
-- This sums up the product of quantity and price for each order detail to get the total sales.
SELECT ROUND(SUM(order_details.quantity * pizzas.price), 2) AS total_sales 
FROM order_details
JOIN pizzas 
	ON pizzas.pizza_id = order_details.pizza_id;
-- Joining order_details and pizzas tables on pizza_id to access the price of each pizza.
-- Multiplying the quantity of each pizza by its price to get the total revenue for each order detail.
-- Summing these values to get the total revenue.
-- Rounding the result to 2 decimal places for readability.



-- 3. Identify the highest-priced pizza.
-- This selects the pizza type name and price, ordering by price in descending order to get the highest price.
SELECT pizza_types.name, pizzas.price
FROM pizza_types  
JOIN pizzas 
	ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;
-- Joining pizza_types and pizzas tables on pizza_type_id to access the name of each pizza type.



-- 4. Identify the most common pizza size ordered.
-- This counts the number of order details for each pizza size and orders by the count in descending order to find the most common size.
SELECT pizzas.size, COUNT(order_details.order_details_id) AS order_count
FROM pizzas
JOIN order_details 
	ON pizzas.pizza_id = order_details.pizza_id 
GROUP BY pizzas.size
ORDER BY order_count DESC;
-- Joining pizzas and order_details tables on pizza_id to access the size of each pizza ordered.
-- Grouping the results by pizza size.
-- Counting the number of order details for each pizza size.
-- Ordering the results by the count in descending order to find the most frequently ordered pizza size.



-- 5. List the top 5 most ordered pizza types along with their quantities.
-- This query sums the quantity for each pizza type across all orders, then selects the top 5 based on total quantity ordered.
SELECT pizza_types.name, SUM(order_details.quantity) AS quantity
FROM pizza_types
JOIN pizzas 
	ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details 
	ON pizzas.pizza_id = order_details.pizza_id 
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;
-- Joining pizza_types, pizzas, and order_details tables to access the name and quantity of each pizza type ordered.
-- Grouping the results by pizza type name.



-- Intermediate Queries:

-- 1. Join the necessary tables to find the total quantity of each pizza category ordered.
-- This query aggregates order quantities by pizza category, showing popularity of each category.
SELECT pizza_types.category, SUM(order_details.quantity) AS quantity
FROM pizza_types
JOIN pizzas 
	ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details 
	ON pizzas.pizza_id = order_details.pizza_id 
GROUP BY pizza_types.category
ORDER BY quantity DESC;
-- Joining pizza_types, pizzas, and order_details tables to access the category and quantity of each pizza ordered.
-- Grouping the results by pizza category.



-- 2. Determine the distribution of orders by hour of the day.
-- This counts the number of orders for each hour, extracted from the order time.
SELECT EXTRACT(HOUR FROM time) AS order_hour, COUNT(order_id) AS order_count
FROM orders
GROUP BY order_hour
ORDER BY order_hour;
-- Extracting the hour from the order time using the EXTRACT function.
-- Grouping the results by the extracted hour.



-- 3. Join relevant tables to find the category-wise distribution of pizzas.
-- This counts the number of pizza types in each category.
SELECT category, COUNT(name) AS pizza_count
FROM pizza_types
GROUP BY category;
-- Grouping the results by pizza category.
-- Counting the number of distinct pizza names in each category to see the distribution of pizza types across categories.



-- 4. Group the orders by date and calculate the average number of pizzas ordered per day.
-- This query uses a subquery to sum daily total quantity of pizzas ordered and then calculates the average quantity per day.
SELECT ROUND(AVG(quantity), 0) AS avg_pizza_ordered_per_day
FROM (
  SELECT o.date, SUM(order_details.quantity) AS quantity
  FROM orders o
  JOIN order_details 
	ON o.order_id = order_details.order_id 
  GROUP BY o.date
) AS order_quantity;
-- Subquery: Joining orders and order_details tables to access the date and quantity of each order.
-- Grouping the results by order date.
-- Summing the quantities of each order for each day to get the daily total.
-- Outer query: Calculating the average of the daily totals.



-- 5. Determine the top 3 most ordered pizza types based on revenue.
-- This query calculates total revenue for each pizza type and selects the top 3.
SELECT pizza_types.name, SUM(order_details.quantity * pizzas.price) AS revenue
FROM pizza_types
JOIN pizzas 
	ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details 
	ON pizzas.pizza_id = order_details.pizza_id 
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;
-- Joining pizza_types, pizzas, and order_details tables to access the name and revenue of each pizza type ordered.
-- Grouping the results by pizza type name.
-- Calculating the revenue by multiplying the quantity of each pizza type by its price and summing these values.



-- Advanced Queries:

-- 1. Calculate the percentage contribution of each pizza type to total revenue.
-- This calculates the revenue percentage of each pizza category compared to the total revenue.
SELECT pizza_types.category,
    ROUND(
        (SUM(order_details.quantity * pizzas.price) / 
        (SELECT SUM(od.quantity * p.price) FROM order_details od 
         JOIN pizzas p 
			ON p.pizza_id = od.pizza_id ) * 100, 
    2) AS revenue_percentage
FROM pizza_types
JOIN pizzas 
	ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details 
	ON pizzas.pizza_id = order_details.pizza_id 
GROUP BY pizza_types.category
ORDER BY revenue_percentage DESC;
-- Joining pizza_types, pizzas, and order_details tables to access the category and revenue of each pizza ordered.
-- Subquery: Calculating the total revenue from all orders by multiplying the quantity of each pizza by its price and summing these values.
-- Main query: Calculating the revenue for each pizza category.
-- Dividing the category revenue by the total revenue and multiplying by 100 to get the percentage contribution.
-- Grouping the results by pizza category.



-- 2. Analyze the cumulative revenue generated over time.
-- This query uses a window function to calculate running total of revenue over dates.
SELECT date, SUM(revenue) OVER(ORDER BY date) AS cumulative_revenue
FROM (
    SELECT orders.date, SUM(order_details.quantity * pizzas.price) AS revenue
    FROM order_details 
    JOIN pizzas 
		ON order_details.pizza_id = pizzas.pizza_id
    JOIN orders 
		ON orders.order_id = order_details.order_id
    GROUP BY orders.date
) AS sales;
-- Subquery: Joining orders, pizzas, and order_details tables to access the date and revenue of each order.
-- Grouping the results by order date.
-- Calculating the daily revenue by multiplying the quantity of each pizza by its price and summing these values.
-- Main query: Calculating the cumulative revenue over time using the SUM function with the OVER clause.
-- Ordering the results by date to get the running total of cumulative revenue.

-- 3. Determine the top 3 most ordered pizza types based on revenue for each pizza category.
-- This query uses CTEs and window functions to rank pizzas within their categories by revenue.
WITH CTE AS (
    SELECT pizza_types.category, pizza_types.name,
           SUM(order_details.quantity * pizzas.price) AS revenue
    FROM pizza_types 
    JOIN pizzas 
		ON pizza_types.pizza_type_id = pizzas.pizza_type_id
    JOIN order_details 
		ON order_details.pizza_id = pizzas.pizza_id
    GROUP BY pizza_types.category, pizza_types.name
),
CTE2 AS (
    SELECT category, name, revenue,
           RANK() OVER(PARTITION BY category ORDER BY revenue DESC) AS rn
    FROM CTE
)
SELECT category, name, revenue 
FROM CTE2
WHERE rn <= 3;
-- CTE: Joining pizza_types, pizzas, and order_details tables to access the category, name, and revenue of each pizza ordered.
-- Grouping the results by pizza category and pizza type name.
-- Calculating the revenue for each pizza type by multiplying the quantity by the price and summing these values.
-- CTE2: Ranking the pizza types within each category by revenue in descending order using the RANK function with the PARTITION BY clause.
-- Main query: Selecting the category, name, and revenue of the top 3 pizza types in each category based on the rank.
-- Filtering the results to include only the top 3 entries for each category where the rank is less than or equal to 3.
