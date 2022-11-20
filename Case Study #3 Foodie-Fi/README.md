/* 

8 Week SQL Challenge: Case Study #3 Foodie-Fi

Check below link for more information about this case study:
https://8weeksqlchallenge.com

*/

-------------------------------------------
A. Data Analysis Questions
-------------------------------------------

1. How many customers has Foodie-Fi ever had?

'''sql
SELECT COUNT(DISTINCT customer_id) AS distinct_customers
FROM subscriptions
'''
