create database pizzahut; -- creating the database 'pizzahut'

-- checking imported tables
select * from pizzahut.pizzas;
select * from pizzahut.orders;
select * from pizzahut.pizza_types;
select * from pizzahut.order_details;

-- changing datatypes of date and time columns
alter table pizzahut.orders
change column order_date orders_date date ,
change column time orders_time time;

use pizzahut;

-- 1.Retrieve the total no. of orders placed.
SELECT 
    COUNT(order_id) total_orders_placed
FROM
    orders;

-- 2.Calculate the total revenue generated from pizza sales. 
SELECT 
    ROUND(SUM(od.quantity * p.price), 2) total_sales
FROM
    order_details od
        JOIN
    pizzas p ON p.pizza_id = od.pizza_id;
    
    -- 3.Identify the highest-priced pizza.
SELECT 
    pt.name, p.price
FROM
    pizzas p
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;
   
-- 4.Identify the most common pizza size ordered.
SELECT 
    size, SUM(od.quantity) size_count
FROM
    order_details od
        JOIN
    pizzas p ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY size_count DESC
LIMIT 1;
   
-- 5.List the top 5 most ordered pizza types along with their quantities.   
SELECT 
    pt.name, SUM(od.quantity) quant
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY name
ORDER BY quant DESC
LIMIT 5;
 
 -- 6. Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pt.category, SUM(od.quantity) total_quant
FROM
    order_details od
        JOIN
    pizzas p ON p.pizza_id = od.pizza_id
        JOIN
    pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.category;
 
 -- 7.Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(orders_time) hrs, COUNT(order_id) t_orders
FROM
    orders
GROUP BY hrs
ORDER BY t_orders DESC;
 
 -- 8.Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(pizza_type_id) cnt
FROM
    pizza_types
GROUP BY category
ORDER BY cnt DESC;
 
 -- 9.Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    AVG(tqty) average_qty_order
FROM
    (SELECT 
        o.orders_date, SUM(od.quantity) tqty
    FROM
        orders o
    JOIN order_details od ON od.order_id = o.order_id
    GROUP BY o.orders_date) AS qty;
    
    -- 10. Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pt.name, ROUND(SUM(od.quantity * p.price), 2) revenue
FROM
    order_details od
        JOIN
    pizzas p ON p.pizza_id = od.pizza_id
        JOIN
    pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3;
    
    -- 11. Calculate the percentage contribution of each pizza type to total revenue.
	SELECT 
    pt.name,
    ROUND(SUM(od.quantity * p.price) / (SELECT 
                    ROUND(SUM(od.quantity * p.price), 2) total_sales
                FROM
                    order_details od
                        JOIN
                    pizzas p ON p.pizza_id = od.pizza_id) * 100,
            2) revenue
FROM
    order_details od
        JOIN
    pizzas p ON p.pizza_id = od.pizza_id
        JOIN
    pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name;
     
     -- 12. Analyze the cumulative revenue generated over time.
select distinct date(o.orders_date) order_date,
round(sum(od.quantity*p.price) over(order by o.orders_date),2) as cumualative_reven
from orders o
join order_details od on od.order_id=o.order_id
join pizzas p on p.pizza_id=od.pizza_id ;

-- 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.
  SELECT rank_
		    ,max(case when category="Chicken" then name end) as "Chicken"
		    ,max(case when category="Classic" then name end) as "Classic"
        ,max(case when category="Supreme" then name end) as "Supereme"
        ,max(case when category="Veggie" then name end) as "Veggie"
  FROM(
        SELECT frev.category,frev.name,frev.rank_
         FROM
             (SELECT pt.name,pt.category, round(sum(od.quantity * p.price),2) revenue
             ,rank() over(partition by pt.category order by sum(od.quantity * p.price) desc) rank_
                FROM order_details od 
          JOIN
              pizzas p ON p.pizza_id=od.pizza_id
          JOIN
              pizza_types pt ON pt.pizza_type_id=p.pizza_type_id
           GROUP BY pt.category,pt.name) frev
     WHERE frev.rank_ <4) as t
     GROUP BY rank_
     ORDER BY rank_
     ;