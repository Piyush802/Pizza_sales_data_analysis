CREATE DATABASE pizzahut;
USE pizzahut;

SELECT * FROM order_details;
SELECT * FROM orders;
SELECT * FROM pizza_types;
SELECT * FROM pizzas;

                                 ------ BASIC-------

--Retrieve the total number of orders placed.
SELECT COUNT(o.order_id) AS total_orders_placed
FROM orders o;

--Calculate the total revenue generated from pizza sales.
SELECT ROUND(SUM(od.quantity * p.price),2) AS total_revenue
FROM order_details od INNER JOIN pizzas p
ON od.pizza_id = p.pizza_id;

--Identify the highest-priced pizza.
SELECT TOP 1* 
FROM pizza_types pt INNER JOIN pizzas p
ON pt.pizza_type_id = p.pizza_type_id
ORDER BY p.price DESC;

--Identify the most common pizza size ordered.
SELECT TOP 1 COUNT(od.order_details_id) AS order_count, p.size
FROM order_details od INNER JOIN pizzas p
ON od.pizza_id = p.pizza_id
GROUP BY p.size;

--List the top 5 most ordered pizza types along with their quantities.
SELECT TOP 5 pt.name, SUM(od.quantity) AS quantity
FROM pizza_types pt INNER JOIN pizzas p
ON pt.pizza_type_id = p.pizza_type_id
INNER JOIN order_details od
ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY quantity DESC;

                                     -----INTERMEDIATE-------

--Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT pt.category, SUM(od.quantity) AS total_quantity 
FROM order_details od INNER JOIN pizzas p
ON od.pizza_id = p.pizza_id
INNER JOIN pizza_types pt
ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.category
ORDER BY total_quantity DESC;

--Determine the distribution of orders by hour of the day.
SELECT DATEPART(hour,order_time) AS hour, COUNT(order_id) AS order_count
FROM orders
GROUP BY DATEPART(hour,order_time)
ORDER BY hour;

--Join relevant tables to find the category-wise distribution of pizzas.
SELECT category, COUNT(name)
FROM pizza_types
GROUP BY category;

--Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT AVG(quantity) AS avg_pizzas_ordered_per_day FROM
(SELECT o.order_date, SUM(od.quantity) AS quantity
FROM order_details od INNER JOIN orders o
ON od.order_id = o.order_id
GROUP BY o.order_date) AS order_quantity;

--Determine the top 3 most ordered pizza types based on revenue.
SELECT TOP 3 pt.name, SUM(od.quantity * p.price) AS revenue
FROM order_details od JOIN pizzas p
ON od.pizza_id = p.pizza_id
JOIN pizza_types pt
ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY revenue desc;

                                        ------ ADVANCE -----

--Calculate the percentage contribution of each pizza type to total revenue.
SELECT pt.category,
(SUM(od.quantity * p.price) / (SELECT ROUND(SUM(od.quantity*p.price),0) AS total_sales
FROM order_details od JOIN pizzas p
ON p.pizza_id = od.pizza_id)) * 100 AS revenue

FROM pizza_types pt JOIN pizzas p
ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od
ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY revenue DESC;

--Analyze the cumulative revenue generated over time.
SELECT order_date, SUM(revenue) OVER (ORDER BY order_date) AS cum_revenue
FROM
(SELECT o.order_date, SUM(od.quantity * p.price) AS revenue
FROM order_details od JOIN pizzas p
ON od.pizza_id = p.pizza_id
JOIN orders o
ON od.order_id = o.order_id
GROUP BY o.order_date) AS sales;

--Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT name, revenue
FROM
(SELECT category, name, revenue, RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS RN
FROM
(SELECT pt.category, pt.name, SUM(od.quantity * p.price) AS revenue
FROM order_details od JOIN pizzas p
ON od.pizza_id = p.pizza_id
JOIN orders o
ON od.order_id = o.order_id
JOIN pizza_types pt
ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.category, pt.name) AS a) AS B
WHERE rn <= 3;