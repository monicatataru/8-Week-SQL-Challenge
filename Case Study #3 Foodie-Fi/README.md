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

---
4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

---
5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

---
6. What is the number and percentage of customer plans after their initial free trial?

---
7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

---
8. How many customers have upgraded to an annual plan in 2020?

---
9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

---
10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

---
11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
