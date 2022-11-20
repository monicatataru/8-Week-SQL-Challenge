/* 

8 Week SQL Challenge: Case Study #1 Danny’s Diner

Check below link for more information about this case study:
https://8weeksqlchallenge.com

*/


CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');


----------------------------------------------
/* JOIN ALL TABLES */
----------------------------------------------

WITH cte AS
(
    SELECT sales.customer_id, order_date, product_name, price,
    CASE
        WHEN order_date >= join_date THEN 'Y'
        ELSE 'N'
        END as member
    FROM sales
    LEFT JOIN  menu
    ON sales.product_id = menu.product_id
    LEFT JOIN members
    ON sales.customer_id = members.customer_id
)
SELECT *, CASE 
    WHEN member='N' THEN NULL
    ELSE
    RANK() OVER (PARTITION BY customer_id, member
                ORDER BY order_date) END AS ranking
FROM cte


/* 1. What is the total amount each customer spent at the restaurant? */

SELECT customer_id, SUM(price) as total_amount
FROM sales
JOIN menu
ON sales.product_id = menu.product_id
GROUP BY customer_id

/* 2. How many days has each customer visited the restaurant? */

SELECT customer_id, COUNT(DISTINCT order_date) as no_visits
FROM sales
GROUP BY customer_id;


/* 3. What was the first item from the menu purchased by each customer? */
-- We make the assumption that the first sale per order is actually the first item purchased

WITH cte AS
(
    SELECT customer_id,product_name,
    ROW_NUMBER() OVER (PARTITION BY customer_id
                        ORDER BY order_date) as row_no
    FROM sales s 
    JOIN menu m
    ON s.product_id = m.product_id
)
SELECT customer_id, product_name
FROM cte
WHERE row_no = 1


/* 4. What is the most purchased item on the menu and how many times was it purchased by all customers? */

SELECT TOP 1 (COUNT(sales.product_id)) AS no_sales, product_name
FROM sales 
JOIN menu
ON sales.product_id = menu.product_id
GROUP BY sales.product_id, product_name
ORDER BY no_sales DESC

/* 5. Which item was the most popular for each customer? */

WITH cte AS 
(
    SELECT customer_id, product_name,  
    RANK() OVER (PARTITION BY customer_id
                ORDER BY COUNT(sales.product_id)) AS ranking
    FROM sales
    JOIN menu
    ON sales.product_id = menu.product_id
    GROUP BY customer_id, product_name
)
SELECT customer_id, product_name
FROM cte 
WHERE ranking = 1

/* 6. Which item was purchased first by the customer after they became a member? */

WITH cte AS 
(
    SELECT sales.customer_id, order_date, product_name,
    ROW_NUMBER() OVER (PARTITION BY sales.customer_id
                    ORDER BY order_date) AS counter
    FROM sales
    LEFT JOIN  menu
    ON sales.product_id = menu.product_id
    LEFT JOIN members
    ON sales.customer_id = members.customer_id
    WHERE order_date >= join_date
)
SELECT customer_id, product_name
FROM cte 
WHERE counter = 1

/* 7. Which item was purchased just before the customer became a member? */

WITH cte AS 
(
    SELECT sales.customer_id, product_name,
    DENSE_RANK() OVER (PARTITION BY sales.customer_id
                        ORDER BY order_date DESC) ranking
    FROM sales 
    JOIN members
    ON sales.customer_id = members.customer_id
    JOIN menu
    ON sales.product_id = menu.product_id
    WHERE order_date < join_date
)
SELECT customer_id, product_name
FROM cte 
WHERE ranking = 1


/* 8. What is the total items and amount spent for each member before they became a member? */

WITH cte AS (
SELECT sales.customer_id, sales.product_id, price
    FROM sales 
    JOIN members
    ON sales.customer_id = members.customer_id
    JOIN menu
    ON sales.product_id = menu.product_id
    WHERE order_date < join_date
)
SELECT customer_id, COUNT(*) AS no_items, SUM(price) AS sales
FROM cte    
GROUP BY customer_id


/* 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have? */
-- Points are calculated for all purchases, irrespective of the client's membership status
SELECT customer_id,
SUM(CASE    
    WHEN sales.product_id= 1 THEN price*20
    ELSE price*10 END) AS points
FROM sales 
JOIN menu
ON sales.product_id = menu.product_id
GROUP BY customer_id

/* 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi. 
How many points do customer A and B have at the end of January? */

SELECT sales.customer_id,
SUM(CASE 
        WHEN (order_date BETWEEN join_date AND DateAdd(day,7, join_date)) OR
        (sales.product_id=1 AND order_date>=join_date) THEN price*20
        ELSE price*10 END 
    ) AS points   
FROM sales 
JOIN members
ON sales.customer_id = members.customer_id
JOIN menu
ON sales.product_id = menu.product_id
WHERE order_date <= '2021-01-31'
GROUP BY sales.customer_id
