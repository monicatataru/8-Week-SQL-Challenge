8 Week SQL Challenge: Case Study #4 Data Bank

Check below link for more information about this case study:
[https://8weeksqlchallenge.com](https://8weeksqlchallenge.com/case-study-4/)


-------------------------------------------
A. Customer Nodes Exploration
-------------------------------------------

1. How many unique nodes are there on the Data Bank system?

```sql
SELECT COUNT(DISTINCT node_id) AS unique_nodes
FROM customer_nodes
```

|unique_nodes|
|-----------|
|5|

2. What is the number of nodes per region?

```sql
SELECT  region_name,
        COUNT(node_id) AS nodes_count
FROM customer_nodes c
JOIN regions r
    ON c.region_id = r.region_id
GROUP BY region_name
```

|region_name|nodes_count|
|---------|----------|
|Africa	|714|
|America	|735|
|Asia	|665|
|Australia	|770|
|Europe	|616|


3. How many customers are allocated to each region?

```sql
SELECT region_name,
       COUNT(DISTINCT customer_id) AS customer_count
FROM customer_nodes c
JOIN regions r
    ON c.region_id = r.region_id
GROUP BY region_name
```

|region_name|customer_count|
|---------|----------|
|Africa	|102|
|America	|105|
|Asia	|95|
|Australia	|110|
|Europe	|88|

4. How many days on average are customers reallocated to a different node?

```sql
-- for each customer, we'll keep only the records when they are reallocated to a different node
-- then, calculate the difference in days between the start_dates of two consecutive allocations

WITH cte AS
(
    -- if previous node is the same as the current node, then counter = 0 and the record will be further ignored
    SELECT *,
        CASE WHEN LAG(node_id) OVER (PARTITION BY customer_id
                        ORDER BY  start_date)=node_id THEN 0 ELSE 1 END AS counter
    FROM customer_nodes
),
cte2 AS(
    SELECT *,
    DATEDIFF(day, LAG(start_date) OVER (PARTITION BY customer_id
                            ORDER BY start_date), start_date) AS days_v
    FROM cte 
    WHERE counter = 1
)
select AVG(days_v) AS avg_days
FROM cte2
```

|avg_days|
|--------|
|18|

5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region? 
