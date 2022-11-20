The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid by each customer in the subscriptions table with the following requirements:

    - monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
    - upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
    - upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
    - once a customer churns they will no longer make payments

---    
  ```sql
  -- create a table with all the plan updates made by each customer
DROP TABLE IF EXISTS #payment_history
WITH cte AS 
(
    -- create an end_date that marks when the current plan ends
    -- if they churn, the end_date is the day when the current paid subscription ends
    SELECT customer_id,
            start_date,
            plan_id,
            LAG(plan_id) OVER (PARTITION BY customer_id
                                ORDER BY start_date) AS prev_plan_id,
            (CASE WHEN plan_id = 4 THEN start_date 
            ELSE LEAD(start_date) OVER (PARTITION BY customer_id
                                ORDER BY start_date) END) AS end_date
    FROM subscriptions                            
),
cte2 AS (
    -- if the subscription plan remains unchanged until 2021, this means the current plan is active until the end of 2020
    SELECT customer_id,
            plan_id,
            prev_plan_id,
            start_date,
            ISNULL(end_date, '2020-12-31') AS end_date
    FROM cte
)
-- remove the free trial periods
SELECT * 
INTO #payment_history
FROM cte2
WHERE prev_plan_id IS NOT NULL
```

|customer_id	|plan_id	|prev_plan_id	|start_date	|end_date|
|-----------|-------|----------|---------|--------|
|1	|1|	0|	2020-08-08|	2020-12-31|
|2	|3|	0|	2020-09-27|	2020-12-31|
|3	|1|	0|	2020-01-20|	2020-12-31|
|4	|1|	0|	2020-01-24|	2020-04-21|
|4	|4|	1|	2020-04-21|	2020-04-21|
|5	|1|	0|	2020-08-10|	2020-12-31|
|6	|1|	0|	2020-12-30|	2021-02-26|
|6	|4|	1|	2021-02-26|	2021-02-26|

---
```sql
-- calculate the monthly payments for the users with monthly subscriptions
    -- plan_id = 1 for basic monthly
    -- plan_id = 2 for pro monthly
DROP TABLE IF EXISTS #monthly_plans  
WITH cte AS 
(
    SELECT *
    FROM #payment_history
    WHERE plan_id IN (1,2)
),
cte1 AS
(
    -- anchor member
    SELECT customer_id, 
        plan_id,
        (CASE WHEN plan_id = 1 THEN 9.90
            WHEN plan_id = 2 THEN 19.90
            ELSE NULL END) AS amount,
        prev_plan_id,
        start_date,
        end_date,
        start_date as payment_date
    FROM cte

    UNION ALL

    -- recursive member
    SELECT customer_id, 
        plan_id,
        (CASE WHEN plan_id = 1 THEN 9.90
            WHEN plan_id = 2 THEN 19.90
            ELSE NULL END) AS amount,
        prev_plan_id,
        start_date,
        end_date,
        DATEADD(month, 1, payment_date) as payment_date
        FROM cte1
        WHERE payment_date < DATEADD(month, -1, end_date)
    )
SELECT *
INTO #monthly_plans
FROM cte1
ORDER BY customer_id, plan_id, payment_date
```


|customer_id	|plan_id	|amount	|prev_plan_id	|start_date	|end_date	|payment_date|
|-----------|-------|----------|-----------|-----------|--------|-----------|
|8	|1	|9.90	|0|	2020-06-18|	2020-08-03|	2020-06-18|
|8	|1	|9.90	|0|	2020-06-18|	2020-08-03|	2020-07-18|
|8	|2	|19.90	|1|	2020-08-03|	2020-12-31|	2020-08-03|
|8	|2	|19.90	|1|	2020-08-03|	2020-12-31|	2020-09-03|
|8	|2	|19.90	|1|	2020-08-03|	2020-12-31|	2020-10-03|
|8	|2	|19.90	|1|	2020-08-03|	2020-12-31|	2020-11-03|
|8	|2	|19.90	|1|	2020-08-03|	2020-12-31|	2020-12-03|

---
```sql
-- calculate the one-time fee for the annual plan
    -- plan_id = 3 for pro annual
DROP TABLE IF EXISTS #annual_plan
WITH cte AS 
(
    SELECT customer_id,
        plan_id,
        199.00 AS amount,
        prev_plan_id,
        start_date,
        end_date,
        start_date AS payment_date
    FROM #payment_history
    WHERE plan_id = 3
)
SELECT *
INTO #annual_plan
FROM cte
```

---
```sql
-- combine all payments under one single table
DROP TABLE IF EXISTS #all_payments;
WITH cte AS (
    SELECT *
    FROM #monthly_plans
    UNION ALL
    SELECT * 
    FROM #annual_plan
)
SELECT *
INTO #all_payments
FROM cte
```

---
```sql
-- correct the amount for the users that upgrade from basic to pro plans       
DROP TABLE IF EXISTS payments
WITH cte AS
(
    SELECT customer_id,
        p.plan_id, 
        plan_name,
        payment_date,
        CASE WHEN p.plan_id IN (2,3) AND (LAG(p.plan_id) OVER (PARTITION BY customer_id
                                                         ORDER BY start_date) ) = 1
                                                    THEN amount - 9.90 
        ELSE amount END AS amount,
        ROW_NUMBER() OVER (PARTITION BY customer_id
                    ORDER BY payment_date) AS payment_order
    FROM #all_payments p
    JOIN plans
    ON p.plan_id = plans.plan_id
)
SELECT *
INTO payments
FROM cte
WHERE DATEPART(year, payment_date) = 2020 
ORDER by customer_id, payment_date
```
