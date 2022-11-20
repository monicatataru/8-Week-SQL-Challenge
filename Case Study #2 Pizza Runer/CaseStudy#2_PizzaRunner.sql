/* 

8 Week SQL Challenge: Case Study #2 Pizza Runer

Check below link for more information about this case study:
https://8weeksqlchallenge.com

*/

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  "runner_id" INTEGER,
  "registration_date" DATE
);
INSERT INTO runners
  ("runner_id", "registration_date")
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" DATETIME
);

INSERT INTO customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

INSERT INTO runner_orders
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" TEXT
);
INSERT INTO pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" TEXT
);
INSERT INTO pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" TEXT
);
INSERT INTO pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');


-------------------------------------------
/* Data Cleaning */
-------------------------------------------

-- create a new table for customer_orders and replace the 'null'/NULL values with empty strings
DROP TABLE IF EXISTS customer_orders_t
SELECT * INTO customer_orders_t FROM customer_orders

UPDATE customer_orders_t
  SET exclusions = CASE WHEN exclusions='null' THEN ''
                        ELSE exclusions END,
    extras = CASE WHEN extras IS NULL THEN ''
                 WHEN extras ='null' THEN ''
                 ELSE extras END 

ALTER TABLE customer_orders_t ALTER COLUMN extras VARCHAR(MAX)
ALTER TABLE customer_orders_t ALTER COLUMN exclusions VARCHAR(MAX)

-- create a new table for runner_orders
-- data cleaning
DROP TABLE IF EXISTS runner_orders_t
SELECT * INTO runner_orders_t FROM runner_orders

UPDATE runner_orders_t
SET pickup_time = CASE WHEN pickup_time = 'null' THEN ''
                       ELSE pickup_time END, 
    distance = CASE WHEN distance LIKE '%km' THEN trim('km' FROM distance)
                    WHEN distance='null' THEN '' 
                    ELSE distance END,
    duration = CASE WHEN duration LIKE '%minutes' THEN trim('minutes' FROM duration)
                    WHEN duration LIKE '%mins' THEN trim('mins' FROM duration)
                    WHEN duration LIKE '%minute' THEN trim('minute' FROM duration)
                    WHEN duration='null' THEN ''
                    ELSE duration END,
    cancellation = CASE WHEN cancellation IS NULL THEN ''
                        WHEN cancellation ='null' THEN ''
                        ELSE cancellation END  

-- update the datatype
ALTER TABLE runner_orders_t ALTER COLUMN pickup_time DATETIME
ALTER TABLE runner_orders_t ALTER COLUMN distance FLOAT
ALTER TABLE runner_orders_t ALTER COLUMN duration INT

-- create new tables for....
-- and change the datatype from text to varchar where needed
DROP TABLE IF EXISTS pizza_names_t
SELECT pizza_id, CAST(pizza_name AS NVARCHAR) AS pizza_name INTO pizza_names_t FROM pizza_names

DROP TABLE IF EXISTS pizza_recipes_t
SELECT pizza_id, CAST(toppings AS VARCHAR(MAX)) AS toppings INTO pizza_recipes_t FROM pizza_recipes

DROP TABLE IF EXISTS pizza_toppings_t
SELECT topping_id, CAST(topping_name AS VARCHAR(MAX)) AS topping_name INTO pizza_toppings_t FROM pizza_toppings


-------------------------------------------
/* A. Pizza Metrics */
-------------------------------------------

/* 1. How many pizzas were ordered? */
SELECT COUNT(*) AS ordered_pizza_count
FROM customer_orders_t

/* 2. How many unique customer orders were made? */
SELECT COUNT(DISTINCT order_id) AS distinct_orders_count
FROM customer_orders_t

/* 3. How many successful orders were delivered by each runner? */
SELECT runner_id, COUNT(order_id) AS delivered_orders_count
FROM runner_orders_t
WHERE cancellation=''
GROUP BY runner_id

/* 4. How many of each type of pizza was delivered? */
SELECT pizza_id, count(*) AS pizzas_delivered
FROM customer_orders_t
WHERE order_id IN (
  SELECT order_id 
  FROM runner_orders_t
  WHERE cancellation=''
)
GROUP BY pizza_id

/* 5. How many Vegetarian and Meatlovers were ordered by each customer? */
SELECT customer_id, 
      COUNT(CASE WHEN pizza_name='Meatlovers' THEN 1 ELSE NULL END) as meatlovers_ordered,
      COUNT(CASE WHEN pizza_name='Vegetarian' THEN 1 ELSE NULL END) as vegetarian_ordered
FROM customer_orders_t
JOIN pizza_names_t
ON customer_orders_t.pizza_id = pizza_names_t.pizza_id
GROUP BY customer_id

/* 6. What was the maximum number of pizzas delivered in a single order? */

SELECT MAX(pizzas_delivered) AS max_pizzas_per_order
FROM (
  SELECT order_id, COUNT(*) AS pizzas_delivered
  FROM customer_orders_t
    WHERE order_id IN (
      SELECT order_id
      FROM runner_orders_t
      WHERE cancellation = ''
    )
    GROUP BY order_id
)a

/* 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes? */

SELECT customer_id,
COUNT(CASE WHEN exclusions!='' OR extras!='' THEN 1 ELSE NULL END) AS pizzas_changed,
COUNT(CASE WHEN exclusions='' AND extras='' THEN 1 ELSE NULL END) as pizzas_not_changed
FROM customer_orders_t
WHERE order_id IN (
  SELECT order_id
  FROM runner_orders_t
  WHERE cancellation=''
)
GROUP BY customer_id

/* 8. How many pizzas were delivered that had both exclusions and extras? */

SELECT COUNT(CASE WHEN exclusions!='' AND extras!='' THEN 1 ELSE NULL END) AS pizzas_changed
FROM customer_orders_t
WHERE order_id IN (
  SELECT order_id
  FROM runner_orders_t
  WHERE cancellation=''
)

/* 9. What was the total volume of pizzas ordered for each hour of the day? */

SELECT DATEPART(HOUR, order_time) AS ordered_at_hour, COUNT(*) AS no_pizzas
FROM customer_orders_t
GROUP BY DATEPART(HOUR, order_time)
ORDER BY 1

/* 10. What was the volume of orders for each day of the week? */

SELECT DATEPART(WEEKDAY, order_time) AS day_of_the_week, COUNT(*) AS no_pizzas_ordered
FROM customer_orders_t
GROUP BY DATEPART(WEEKDAY, order_time)
ORDER BY 1

-------------------------------------------
/* B. Runner and Customer Experience */
-------------------------------------------

/* 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01) */

SELECT DATEPART(week, registration_date) AS week, COUNT(*) no_registered_runners
FROM runners
GROUP BY DATEPART(week, registration_date)

/* 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order? */

SELECT runner_id, AVG(minutes_dif) as avg_time 
FROM (
  SELECT DISTINCT runner_orders_t.order_id, runner_id, pickup_time, order_time,
    DATEDIFF(minute, order_time, pickup_time) AS minutes_dif
  FROM runner_orders_t  
  JOIN customer_orders_t
  ON runner_orders_t.order_id=customer_orders_t.order_id
  WHERE cancellation = '') a
GROUP BY runner_id

/* 3. Is there any relationship between the number of pizzas and how long the order takes to prepare? */
-- it seems that the more pizzas are ordered, the longer it takes to prepare them

WITH cte AS 
  (
  SELECT runner_orders_t.order_id,
      COUNT(*) as pizzas_ordered,
      DATEDIFF(minute, order_time, pickup_time) AS minutes_dif
  FROM runner_orders_t  
  JOIN customer_orders_t
    ON runner_orders_t.order_id=customer_orders_t.order_id
  WHERE cancellation = ''
  GROUP BY runner_orders_t.order_id, order_time, pickup_time
  )
SELECT pizzas_ordered, AVG(minutes_dif) AS avg_time
FROM cte
GROUP BY pizzas_ordered

/* 4. What was the average distance travelled for each customer? */

WITH cte AS (
  SELECT DISTINCT runner_orders_t.order_id, customer_id, distance
  FROM runner_orders_t  
    JOIN customer_orders_t
      ON runner_orders_t.order_id=customer_orders_t.order_id
    WHERE cancellation = ''
)
SELECT customer_id, AVG(distance) AS avg_distance
FROM cte
GROUP BY customer_id


/* 5. What was the difference between the longest and shortest delivery times for all orders? */

SELECT MAX(duration)-MIN(duration) AS delivery_dif
FROM runner_orders_t
WHERE cancellation=''

/* 6. What was the average speed for each runner for each delivery and do you notice any trend for these values? */

SELECT runner_id, ROUND(distance/duration * 60,2) AS 'km/h'
FROM runner_orders_t
WHERE cancellation=''
ORDER BY runner_id, [km/h]

/* 7. What is the successful delivery percentage for each runner? */

SELECT runner_id,
       SUM(CASE WHEN cancellation='' THEN 1 ELSE 0 END)*100/COUNT(*)
FROM runner_orders_t
GROUP BY runner_id


-------------------------------------------
/* C. Ingredient Optimisation */
-------------------------------------------

/* 1. What are the standard ingredients for each pizza? */

-- using cross apply
SELECT pizza_id, topping_name
FROM pizza_recipes_t
CROSS APPLY string_split(toppings, ',') as topping
JOIN pizza_toppings_t
ON topping.value = pizza_toppings_t.topping_id;

-- using recursive cte
WITH cte_split(pizza_id, split_values, toppings) AS
(
    -- anchor member
    SELECT
        pizza_id,
        LEFT(toppings, CHARINDEX(',', toppings) - 1),
        STUFF(toppings, 1, CHARINDEX(',', toppings)+1, '')
    FROM pizza_recipes_t

    UNION ALL

    -- recursive member
    SELECT
        pizza_id,
        LEFT(toppings, CHARINDEX(',', toppings + ',')-1),
        STUFF(toppings, 1, CHARINDEX(',', toppings)+1, '')
    FROM cte_split
    -- termination condition
    WHERE toppings > ''
)
SELECT pizza_id, topping_name
FROM cte_split
JOIN pizza_toppings_t
ON cte_split.split_values = pizza_toppings_t.topping_id
ORDER BY pizza_id;


/* 2. What was the most commonly added extra? */

-- using cross apply
SELECT topping_name, COUNT(*) AS occurence
FROM customer_orders_t
CROSS APPLY string_split(extras, ',') as topping
JOIN pizza_toppings_t
ON topping.value = pizza_toppings_t.topping_id
GROUP BY topping_name
ORDER BY 2 DESC;

-- using recursive cte
WITH cte_split(order_id, split_values, extras) AS
(
    -- anchor member
    SELECT
        order_id,
        LEFT(extras, CHARINDEX(',', extras+',') - 1),
        STUFF(extras, 1, CHARINDEX(',', extras)+1, '')
    FROM customer_orders_t
    WHERE extras > ''

    UNION ALL

    -- recursive member
    SELECT
        order_id,
        LEFT(extras, CHARINDEX(',', extras + ',')-1),
        STUFF(extras, 1, CHARINDEX(',', extras)+1, '')
    FROM cte_split
    -- termination condition
    WHERE extras > ''
)
SELECT split_values AS topping_id, topping_name, COUNT(*) as occurence
FROM cte_split
JOIN pizza_toppings_t
ON split_values = topping_id
GROUP BY split_values, topping_name
ORDER BY occurence DESC


/* 3. What was the most common exclusion? */

-- using cross apply
SELECT topping_name, COUNT(*) AS occurence
FROM customer_orders_t
CROSS APPLY string_split(exclusions, ',') as topping
JOIN pizza_toppings_t
ON topping.value = pizza_toppings_t.topping_id
GROUP BY topping_name
ORDER BY 2 DESC;

-- using recursive cte
WITH cte_split(order_id, split_values, exclusions) AS
(
    -- anchor member
    SELECT
        order_id,
        LEFT(exclusions, CHARINDEX(',', exclusions+',') - 1),
        STUFF(exclusions, 1, CHARINDEX(',', exclusions)+1, '')
    FROM customer_orders_t
    WHERE exclusions > ''

    UNION ALL

    -- recursive member
    SELECT
        order_id,
        LEFT(exclusions, CHARINDEX(',', exclusions + ',')-1),
        STUFF(exclusions, 1, CHARINDEX(',', exclusions)+1, '')
    FROM cte_split
    -- termination condition
    WHERE exclusions > ''
)
SELECT split_values AS topping_id, topping_name, COUNT(*) AS occurence
FROM cte_split
JOIN pizza_toppings_t
ON split_values = topping_id
GROUP BY split_values, topping_name
ORDER BY occurence DESC


/* 4. Generate an order item for each record in the customers_orders table in the format of one of the following:
        Meat Lovers
        Meat Lovers - Exclude Beef
        Meat Lovers - Extra Bacon
        Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers */

-- insert an row indicator in customer_orders_t
ALTER TABLE customer_orders_t
ADD record_id INT IDENTITY(1,1)

WITH cte AS 
(
  SELECT record_id,
        'Extra ' + STRING_AGG(topping_name, ', ') AS options
  FROM
    (SELECT record_id, topping_id, topping_name
      FROM customer_orders_t
      CROSS APPLY string_split(extras, ',') AS topping
      JOIN pizza_toppings_t
      ON topping.value = topping_id
    ) e
  GROUP BY record_id

  UNION 

  SELECT record_id, 
        'Exclude ' + STRING_AGG(topping_name, ', ') As options
  FROM (
    SELECT record_id, topping_id, topping_name
    FROM customer_orders_t
    CROSS APPLY string_split(exclusions, ',') AS topping
    JOIN pizza_toppings_t
    ON topping.value = topping_id
  ) e
  GROUP BY record_id
)
SELECT customer_orders_t.record_id, CONCAT_WS(' - ', pizza_name, STRING_AGG(options,' - ')) AS order_details
FROM customer_orders_t
JOIN pizza_names_t
ON customer_orders_t.pizza_id = pizza_names_t.pizza_id
LEFT JOIN cte
ON cte.record_id = customer_orders_t.record_id
GROUP BY customer_orders_t.record_id,  
        pizza_name


/* 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients */
        /* For example: "Meat Lovers: 2xBacon, Beef, ... , Salami" */

DROP TABLE IF EXISTS #detailed_cust_orders

WITH cte AS (
  SELECT record_id, customer_orders_t.pizza_id, topping_id, topping_name, 1 AS occurence
  FROM customer_orders_t
  JOIN pizza_recipes_t
  ON customer_orders_t.pizza_id = pizza_recipes_t.pizza_id
  CROSS APPLY string_split(toppings, ',') AS topping
  JOIN pizza_toppings_t
  ON topping.value = topping_id

  UNION ALL

  SELECT record_id, pizza_id, topping_id, topping_name, 1 AS occurence
  FROM customer_orders_t
  CROSS APPLY string_split(extras, ',') as topping
  JOIN pizza_toppings_t
  ON topping.value = pizza_toppings_t.topping_id

  UNION ALL

  SELECT record_id, pizza_id, topping_id, topping_name, -1 AS occurence
  FROM customer_orders_t
  CROSS APPLY string_split(exclusions, ',') as topping
  JOIN pizza_toppings_t
  ON topping.value = pizza_toppings_t.topping_id
)
SELECT record_id, pizza_id, topping_name, SUM(occurence) AS occurence
INTO #detailed_cust_orders
FROM cte
GROUP BY record_id, topping_name, pizza_id
HAVING SUM(occurence)>0


SELECT record_id, CONCAT( pizza_name + ': ', STRING_AGG (CASE WHEN occurence > 1 THEN CAST(occurence AS VARCHAR) +'x'+ topping_name 
                      ELSE topping_name END, ', ')) AS ingredients
FROM #detailed_cust_orders o
JOIN pizza_names_t p 
ON o.pizza_id = p.pizza_id
GROUP BY record_id, pizza_name


/* 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first? */

WITH cte AS (
  SELECT record_id, customer_orders_t.pizza_id, topping_id, topping_name, 1 AS occurence
  FROM customer_orders_t
  JOIN pizza_recipes_t
  ON customer_orders_t.pizza_id = pizza_recipes_t.pizza_id
  CROSS APPLY string_split(toppings, ',') AS topping
  JOIN pizza_toppings_t
  ON topping.value = topping_id
  WHERE order_id NOT IN (SELECT order_id
                          FROM runner_orders_t
                          WHERE cancellation > '')

  UNION ALL

  SELECT record_id, pizza_id, topping_id, topping_name, 1 AS occurence
  FROM customer_orders_t
  CROSS APPLY string_split(extras, ',') as topping
  JOIN pizza_toppings_t
  ON topping.value = pizza_toppings_t.topping_id
   WHERE order_id NOT IN (SELECT order_id
                          FROM runner_orders_t
                          WHERE cancellation > '')

  UNION ALL

  SELECT record_id, pizza_id, topping_id, topping_name, -1 AS occurence
  FROM customer_orders_t
  CROSS APPLY string_split(exclusions, ',') as topping
  JOIN pizza_toppings_t
  ON topping.value = pizza_toppings_t.topping_id
   WHERE order_id NOT IN (SELECT order_id
                          FROM runner_orders_t
                          WHERE cancellation > '')
)
SELECT topping_name, SUM(occurence) AS occurence
FROM cte
GROUP BY topping_name
HAVING SUM(occurence)>0
ORDER BY 2 DESC


-------------------------------------------
/* D. Pricing and Ratings */
-------------------------------------------

/* 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes 
- how much money has Pizza Runner made so far if there are no delivery fees? */

SELECT SUM(CASE WHEN pizza_id=1 THEN 12
              ELSE 10 END) AS renevue
FROM customer_orders_t
JOIN runner_orders_t
ON customer_orders_t.order_id = runner_orders_t.order_id
WHERE cancellation = ''

/* 2. What if there was an additional $1 charge for any pizza extras?
    Add cheese is $1 extra */

SELECT SUM(pizza_price) AS revenue
FROM (
  -- table with pizza prices
  SELECT record_id, SUM(CASE WHEN pizza_id=1 THEN 12
                ELSE 10 END) AS pizza_price
  FROM customer_orders_t
  JOIN runner_orders_t
  ON customer_orders_t.order_id = runner_orders_t.order_id
  WHERE cancellation = ''
  GROUP BY record_id

  UNION ALL

  -- table with topping prices
  SELECT record_id,
      SUM(CASE WHEN topping_id = 4 THEN 2
          ELSE 1 END) AS topping_price
  FROM customer_orders_t
  CROSS APPLY string_split(extras, ',') as topping
  JOIN pizza_toppings_t
  ON topping.value = pizza_toppings_t.topping_id
  WHERE order_id NOT IN (SELECT order_id
                          FROM runner_orders_t
                          WHERE cancellation > '')
  GROUP BY record_id
)a


/* 3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, 
how would you design an additional table for this new dataset - generate a schema for this new table and insert
your own data for ratings for each successful customer order between 1 to 5. */

DROP TABLE IF EXISTS runner_orders_rating
CREATE TABLE runner_orders_rating (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "rating" INTEGER
);


INSERT INTO runner_orders_rating
  ("order_id", "runner_id", "rating")
VALUES
  ('1', '1', '4'),
  ('2', '1', '4'),
  ('3', '1', '3'),
  ('4', '2', '5'),
  ('5', '3', '5'),
  ('7', '2', '3'),
  ('8', '2', '4'),
  ('10', '1', '3');

/* 4. Using your newly generated table - can you join all of the information together to form a table which has 
the following information for successful deliveries?    
        customer_id
        order_id
        runner_id
        rating
        order_time
        pickup_time
        Time between order and pickup
        Delivery duration
        Average speed
        Total number of pizzas */

SELECT customer_id, c.order_id, r1.runner_id, rating, order_time, pickup_time,
  DATEDIFF(minute,order_time, pickup_time) AS time_to_pickup,
  duration,
  ROUND(distance/duration * 60,2) AS 'km/h',
 COUNT(*) AS no_pizzas
from customer_orders_t c
JOIN runner_orders_t r1
ON c.order_id = r1.order_id
JOIN runner_orders_rating r2
ON c.order_id = r2.order_id
GROUP BY customer_id, c.order_id, r1.runner_id, rating, order_time, pickup_time, duration, ROUND(distance/duration * 60,2)


/* 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled
 - how much money does Pizza Runner have left over after these deliveries? */

WITH cte AS (
  SELECT c.order_id, 
        SUM(CASE WHEN pizza_id = 1 THEN 12
            ELSE 10 END) AS revenue
  FROM customer_orders_t c
  JOIN runner_orders_t r
  ON c.order_id = r.order_id
  WHERE cancellation = ''
  GROUP BY c.order_id
)
SELECT SUM(revenue)-SUM(delivery_fee) AS revenue
FROM cte 
JOIN (SELECT order_id, distance*0.3 AS delivery_fee
FROM runner_orders_t) d
ON cte.order_id = d.order_id


-------------------------------------------
 /* E. Bonus Questions */
-------------------------------------------
/* If Danny wants to expand his range of pizzas - how would this impact the existing data design? 
Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu? */

-- both the name and the recipe of the new pizza need to be added in their respective tables

INSERT INTO pizza_names_t
  ("pizza_id", "pizza_name")
VALUES
  (3, 'Supreme')

INSERT INTO pizza_recipes_t
  ("pizza_id", "toppings")
VALUES
  (3, '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12')

