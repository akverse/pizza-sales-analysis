use pizzahut;

-- retreive the total number of orders placed
SELECT 
    COUNT(*)
FROM
    orders;
    
-- What is the total revenue from pizza sales
SELECT 
    ROUND(SUM(O.quantity * P.price), 2) AS TotalRevenue
FROM
    order_details AS O
        INNER JOIN
    pizzas AS P ON O.pizza_id = P.pizza_id;


-- find Highest prized pizza
SELECT 
    PT.name, P.price
FROM
    pizzas AS P
        INNER JOIN
    pizza_types AS PT ON PT.pizza_type_id = P.pizza_type_id
ORDER BY P.price DESC
LIMIT 1;
 
-- identify the most common pizza size ordered-- 
SELECT 
    P.size, COUNT(O.order_details_id)
FROM
    order_details AS O
        INNER JOIN
    pizzas AS P ON O.pizza_id = P.pizza_id
GROUP BY (P.size)
ORDER BY COUNT(O.order_details_id) DESC
LIMIT 1;

-- Find the top 5 most ordered pizzatypes with their quantities
SELECT 
    PT.name, SUM(O.quantity)
FROM
    order_details AS O
        INNER JOIN
    pizzas AS P ON O.pizza_id = P.pizza_id
        INNER JOIN
    pizza_types AS PT ON PT.pizza_type_id = P.pizza_type_id
GROUP BY PT.name 
ORDER BY SUM(O.quantity) desc limit 5;

-- Find total quantity of each pizza category ordered
SELECT 
    PT.category, SUM(O.quantity)
FROM
    order_details AS O
        INNER JOIN
    pizzas AS P ON O.pizza_id = P.pizza_id
        INNER JOIN
    pizza_types AS PT ON PT.pizza_type_id = P.pizza_type_id
GROUP BY PT.category
ORDER BY SUM(O.quantity) DESC;

-- Find distribution of orders by hour
SELECT 
    HOUR(order_time), COUNT(order_id)
FROM
    orders
GROUP BY Hour(order_time)
order by HOUR(order_time) asc;

-- Find category wise distribution of pizzas
SELECT 
    category, COUNT(category)
FROM
    pizza_types
GROUP BY category;

-- Group the orders by date & calculate the average number of pizzas ordered per day
Select avg(orderquantity) from
(SELECT 
    OS.order_date, ROUND(sum(O.quantity)) as orderquantity
FROM
    order_details AS O
        INNER JOIN
    orders AS OS ON OS.order_id = O.order_id
GROUP BY OS.order_date) as order_quant;


-- Determine the top 3 most ordered pizza types based on revenue
SELECT 
    PT.name, SUM(P.price * O.quantity) AS revenue
FROM
    order_details AS O
        INNER JOIN
    pizzas AS P ON O.pizza_id = P.pizza_id
        INNER JOIN
    pizza_types AS PT ON PT.pizza_type_id = P.pizza_type_id
GROUP BY P.pizza_type_id , PT.name
ORDER BY SUM(P.price * O.quantity) DESC limit 3;

-- Calculate the percentage contribution of each pizza type to total revenue
SELECT 
    PT.category, (sum(P.price * O.quantity)/(SELECT 
    Round(SUM(P.price * O.quantity), 2)
FROM
    order_details AS O
        INNER JOIN
    pizzas AS P ON O.pizza_id = P.pizza_id))*100 as revenue 
FROM
    order_details AS O
        INNER JOIN
    pizzas AS P ON O.pizza_id = P.pizza_id
        INNER JOIN
    pizza_types AS PT ON PT.pizza_type_id = P.pizza_type_id
GROUP BY PT.category;

--  Calculate the cumulative revenue generated over time 
 with mycte as
 (SELECT 
    OS.order_date, ROUND(Sum(O.quantity*pizzas.price)) as revenue
FROM
    order_details AS O
        INNER JOIN
    orders AS OS ON OS.order_id = O.order_id
    inner join  pizzas on O.pizza_id = pizzas.pizza_id
GROUP BY OS.order_date)
Select order_date, revenue,
sum(revenue) over (order by order_date) as cumulative
from mycte;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category
with mycet as 
(SELECT 
    PT.category, PT.name, SUM(P.price * O.quantity) as revenue,
    rank() over (partition by PT.category order by SUM(P.price * O.quantity) desc) as "r_no"
FROM
    order_details AS O
        INNER JOIN
    pizzas AS P ON O.pizza_id = P.pizza_id
        INNER JOIN
    pizza_types AS PT ON PT.pizza_type_id = P.pizza_type_id
GROUP BY PT.category , PT.name)
Select category, name, revenue 
from mycet where r_no <=3;

