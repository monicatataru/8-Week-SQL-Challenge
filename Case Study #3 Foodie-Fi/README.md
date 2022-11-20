8 Week SQL Challenge: Case Study #3 Foodie-Fi

Check below link for more information about this case study:
https://8weeksqlchallenge.com


-------------------------------------------
A. Data Analysis Questions
-------------------------------------------

1. How many customers has Foodie-Fi ever had?

 ```sql
SELECT COUNT(DISTINCT customer_id) AS distinct_customers
FROM subscriptions
 ```

|distinct_customers|
|-----------------------|
|1000|

---
2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value.

- all trial subscriptions started in 2020 only, so we can use the number of the month as identifier
 ```sql
 SELECT DATEPART(month, start_date) as subscription_month,
       COUNT(customer_id) AS customers_count
FROM subscriptions
WHERE plan_id = 0
GROUP BY DATEPART(month, start_date)
ORDER BY 1
 ```
 
| subscription_month	|customers_count|
 |------------|-----------|
|1	| 88|
|2 |	68|
|3	| 94|
|4	| 81|
|5	| 88|
|6	| 79|
|7	| 89|
|8	| 88|
|9	| 87|
|10	| 79|
|11	| 75|
|12	| 84|
 
---
3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
 ```sql
SELECT 
    s.plan_id, 
    plan_name, 
    COUNT(*) AS plan_count
FROM subscriptions s
JOIN plans p
ON s.plan_id = p.plan_id
WHERE DATEPART(year, start_date) >= 2021
GROUP BY s.plan_id, plan_name
ORDER BY s.plan_id
 ```
---
4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
 ```sql
 SELECT COUNT(*) as customers_churn,
        CAST(100*COUNT(*) AS FLOAT) / CAST((SELECT COUNT(DISTINCT customer_id)
                FROM subscriptions) AS FLOAT) AS percentage_churn
FROM subscriptions
WHERE plan_id = 4
 ```
---
5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
 ```sql
 WITH cte AS 
 (
     -- create a cte with the current and the previous plan IDs
     SELECT *,
        LAG(plan_id) OVER (PARTITION BY customer_id
                            ORDER BY start_date) AS prev_plan_id
     FROM subscriptions   
 ),
     -- mark with 1 the customers who have churned straight after trial
 cte2 AS (
     SELECT customer_id,
     COUNT(CASE WHEN plan_id=4 and prev_plan_id = 0 THEN 1 ELSE NULL END) AS churned_after_trial
     FROM cte
     GROUP BY customer_id
 )
 SELECT SUM(churned_after_trial) AS churned_after_trial, 100*SUM(churned_after_trial)/COUNT(*) AS perc_churned_after_trial
 FROM cte2
 ```
---
6. What is the number and percentage of customer plans after their initial free trial?
 ```sql
 WITH cte AS 
 (
     -- create a cte with the current and the previous plan IDs and track the number of updates done by each customer
     SELECT *,
        LAG(plan_id) OVER (PARTITION BY customer_id
                            ORDER BY start_date) AS prev_plan_id,
        ROW_NUMBER() OVER (PARTITION BY customer_id
                            ORDER BY start_date) AS rn                    
     FROM subscriptions   
 ),
    -- keep only the next plan update after their initial free trial
cte2 AS 
 (
    SELECT *
    FROM cte
    WHERE rn = 2
 )
SELECT 
    plan_id,  
    COUNT(*) AS customers, 
    CAST(100*COUNT(*) AS FLOAT) / (SELECT max(customer_id) FROM subscriptions) AS perc
FROM cte2
GROUP BY plan_id
 ```
---
7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
 ```sql
 WITH cte AS
(
    -- create a cte with all changes done until 2020-12-31 and add a counter per customer to track all updates in reverse chronological order,
    -- to have the last update marked with counter = 1 
    SELECT *,
    ROW_NUMBER() OVER (PARTITION BY customer_id
                    ORDER BY start_date DESC) AS counter
    FROM subscriptions
    WHERE start_date <= '2020-12-31'
),
cte2 AS (
    -- for each customer, keep only the last update
    SELECT *
    FROM cte
    WHERE counter = 1
)
SELECT plan_id,
    COUNT(customer_id) AS customers,
    CAST(100 * COUNT(customer_id) AS FLOAT) / (SELECT max(customer_id) FROM subscriptions) AS perc
FROM cte2
GROUP BY plan_id
ORDER BY 1
 ```
---
8. How many customers have upgraded to an annual plan in 2020?
 ```sql
 -- annual plan has plan_id = 3
SELECT COUNT(DISTINCT customer_id) AS annual_plan_customers
FROM subscriptions
WHERE DATEPART(year, start_date) = 2020 AND plan_id = 3
 ```
---
9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
 ```sql
 -- we need to calculate the datediff between the day they first joined (min(start_date) for each customer) and the day they upgraded to an annual plan
WITH cte AS 
(
    SELECT *,
    MIN(start_date) OVER (PARTITION BY customer_id) AS first_joined
    FROM subscriptions
)
SELECT AVG(DATEDIFF(day,first_joined, start_date)) as avg_no_of_days
FROM cte
WHERE plan_id = 3
 ```
---
10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
 ```sql
 WITH cte AS 
(
    -- add the date when each customer first joined
    SELECT *,
        MIN(start_date) OVER (PARTITION BY customer_id) AS first_joined
    FROM subscriptions
),
no_days AS (
    -- calculate the number of days from when they first joined to when they upgraded to the annual plan
    SELECT DATEDIFF(day,first_joined, start_date) as no_of_days
    FROM cte
    WHERE plan_id = 3
), 
bins AS(
    -- calculate which 30 day bin each customer belongs to
    SELECT *,
        FLOOR(no_of_days/30) AS bins
    FROM no_days   
)
SELECT 
    CONCAT(bins*30, '-', (bins+1)*30) AS no_of_days,
    COUNT(*) AS customers_count
FROM bins
GROUP BY bins
 ```


---
11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
```sql
-- select the customers with current plan_id is 1 and previous plan_id is 2
WITH cte AS 
 (
     -- create a cte with the current and the previous plan IDs
     SELECT *,
        LAG(plan_id) OVER (PARTITION BY customer_id
                            ORDER BY start_date) AS prev_plan_id
     FROM subscriptions 
 )
 SELECT COUNT(*) AS cust_downgraded
 FROM cte 
 WHERE plan_id = 1 AND prev_plan_id=2 AND DATEPART(year, start_date) = 2020
```
