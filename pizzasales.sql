create database pizzahut;

CREATE TABLE orders (
    order_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL,
    PRIMARY KEY (order_id)
);

CREATE TABLE order_details (
    order_details_id INT NOT NULL,
    order_id INT NOT NULL,
    pizza_id TEXT NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (order_details_id)
);

-- Retrieve Total number of orders placed
SELECT 
    COUNT(order_id) AS Total_orders
FROM
    orders;

-- Total Revenue generated from pizza sales
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS Total_Revenue
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;
    
-- Highest Priced Pizza
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- Most common pizza size ordered
SELECT 
    pizzas.size, SUM(order_details.quantity) AS common_size
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY common_size DESC
LIMIT 1;

-- TOP 5 most ordered pizza types
SELECT 
    pizza_types.name, SUM(order_details.quantity) AS total_qty
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY total_qty DESC
LIMIT 5;

-- quantity of each pizza category ordered
SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;

-- distribution of orders by hour of the day
SELECT 
    count(orders.order_id) as orders,
    HOUR(orders.order_time) AS hours
FROM
    orders
GROUP BY hours
ORDER BY orders DESC;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    AVG(quantity)
FROM
    (SELECT 
        orders.order_date AS Dates,
            SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY Dates
    ORDER BY quantity) AS order_quantity; 
    
-- top 3 most ordered pizza types based on revenue.
SELECT  
    pizza_types.name AS name,
    SUM(pizzas.price * order_details.quantity) AS price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY name
ORDER BY price DESC
LIMIT 3;

-- percentage contribution of each pizza type to total revenue
SELECT 
    pizza_types.category AS type,
    ROUND(SUM(order_details.quantity * pizzas.price) / (SELECT 
                    SUM(order_details.quantity * pizzas.price)
                FROM
                    order_details
                        JOIN
                    pizzas ON order_details.pizza_id = pizzas.pizza_id),
            2) * 100 AS percentage_contribution
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY type
ORDER BY percentage_contribution DESC;

-- cumulative revenue generated over time
SELECT date , 
SUM(revenue) over(order by date ) as cum_revenue FROM
(SELECT orders.order_date as date , SUM(order_details.quantity*pizzas.price) as revenue
FROM orders JOIn order_details ON orders.order_id = order_details.order_id 
JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id
GROUP BY date) as sales;