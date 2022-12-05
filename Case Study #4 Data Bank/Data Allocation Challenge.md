-------------------------------------------
C. Data Allocation Challenge
-------------------------------------------
To test out a few different hypotheses - the Data Bank team wants to run an experiment where different groups of customers would be allocated data using 3 different options:

Option 1: data is allocated based off the amount of money at the end of the previous month.  
Option 2: data is allocated on the average amount of money kept in the account in the previous 30 days.  
Option 3: data is updated real-time.  

For this multi-part challenge question, you have been requested to generate the following data elements to help the Data Bank team estimate how much data will need to be provisioned for each option:  
a. running customer balance column that includes the impact each transaction.  
b. customer balance at the end of each month.  
c. minimum, average and maximum values of the running balance for each customer.  

Using all of the data available - how much data would have been required for each option on a monthly basis?  

#### a. running customer balance column that includes the impact of each transaction
```sql
SELECT *,
    SUM(CASE WHEN txn_type = 'deposit' THEN txn_amount ElSE -txn_amount END) OVER (PARTITION BY customer_id
                                                                            ORDER BY txn_date) AS running_balance
FROM customer_transactions
```

|customer_id|	txn_date|	txn_type|	txn_amount|	running_balance|
|---------|---------|--------|-----------|-------------|
|1	|2020-01-02|	deposit|	312|	312|
|1	|2020-03-05|	purchase|	612|	-300|
|1	|2020-03-17|	deposit|	324|	24|
|1	|2020-03-19|	purchase|	664|	-640|
|2	|2020-01-03|	deposit|	549|	549|
|2	|2020-03-24|	deposit|	61|	610|


#### b. customer balance at the end of each month

First, we'll create a table that includes all the transactions and for every month a customer performs no transaction, insert the following details:
- customer_id
- end_of_month: it's the end of the month the customer didn't make any transaction
- txn_date: the same as end_of_month
- txn_type: 'no transaction'
- txn_amount: 0

```sql
DROP TABLE IF EXISTS #customer_transactions_allM;

WITH cte AS (
SELECT 
    #temp_end_of_month.customer_id,
    end_of_month,
    COALESCE(txn_date, end_of_month) AS txn_date,
    COALESCE(txn_type, 'no transaction') AS txn_type,
    COALESCE(txn_amount,0) AS txn_amount
FROM #temp_end_of_month
LEFT JOIN 
(SELECT 
    customer_id, 
    EOMONTH(txn_date) AS txn_month,
    txn_date,
    txn_type,
    txn_amount
FROM customer_transactions) txn_tab
ON #temp_end_of_month.customer_id = txn_tab.customer_id
    AND txn_month = end_of_month
ORDER BY customer_id, end_of_month OFFSET 0 ROW  
)
SELECT *
INTO #customer_transactions_allM
FROM cte;
```

Now, based on the newly created table, we are able to calculate the customer balance at the end of each month:
```sql
WITH cte AS (
SELECT 
    customer_id,
    end_of_month,
    SUM(CASE WHEN txn_type='deposit' THEN txn_amount    
            ELSE -txn_amount END) OVER (PARTITION BY customer_id
                                    ORDER BY end_of_month) AS running_balance,
    ROW_NUMBER() OVER (PARTITION BY customer_id, end_of_month
                        ORDER BY end_of_month) AS row_no                           
FROM #customer_transactions_allM
ORDER BY customer_id, end_of_month OFFSET 0 ROW  
)
SELECT customer_id, end_of_month, running_balance
FROM cte 
WHERE row_no = 1 
```

|customer_id|	end_of_month|	running_balance|
|---------|-----------|------------|
|1	|2020-01-31|	312|
|1	|2020-02-29|	312|
|1	|2020-03-31|	-640|
|1	|2020-04-30|	-640|
|2	|2020-01-31|	549|
|2	|2020-02-29|	549|
|2	|2020-03-31|	610|
|2	|2020-04-30|	610|


#### c. minimum, average and maximum values of the running balance for each customer
```sql
WITH cte AS (
SELECT *,
    SUM(CASE WHEN txn_type = 'deposit' THEN txn_amount ElSE -txn_amount END) OVER (PARTITION BY customer_id
                                                                            ORDER BY txn_date) AS running_balance
FROM customer_transactions
)
SELECT 
    customer_id,
    EOMONTH(txn_date) AS end_of_month,
    MIN(running_balance) AS min_balance,
    AVG(running_balance) AS avg_balance,
    MAX(running_balance) AS max_balance
FROM cte 
GROUP BY customer_id, EOMONTH(txn_date)
ORDER BY customer_id, EOMONTH(txn_date)
```

|customer_id|	end_of_month|	min_balance|	avg_balance|	max_balance|
|---------|---------|----------|-----------|-------------|
|1	|2020-01-31|	312	|312|	312|
|1	|2020-03-31|	-640|	-305|	24|
|2	|2020-01-31|	549|	549|	549|
|2	|2020-03-31|	610	|610|	610|
|3	|2020-01-31|	144|	144|	144|
|3	|2020-02-29|	-821|	-821|	-821|
|3	|2020-03-31|	-1222|	-1128|	-1034|
|3	|2020-04-30|	-729|	-729|	-729|


### Calculate the amount of data allocated based on the following 3 options:  
#### Option 1: data is allocated based off the amount of money at the end of the previous month

```sql
-- if the amount of money at the end of the month is below zero, then 0 data will be allocated for that customer
WITH cte AS (
SELECT 
    customer_id,
    end_of_month,
    SUM(CASE WHEN txn_type = 'deposit' THEN txn_amount ELSE -txn_amount END) OVER (PARTITION BY customer_id
                                                                            ORDER BY end_of_month) AS running_balance,
    ROW_NUMBER() OVER (PARTITION BY customer_id, end_of_month
                    ORDER BY end_of_month) AS row_no                                       
FROM #customer_transactions_allM
)
SELECT 
    end_of_month, 
    SUM(CASE WHEN running_balance > 0 THEN running_balance
        ELSE 0 END) AS balance
FROM cte
WHERE row_no = 1
GROUP BY end_of_month
ORDER BY end_of_month
```

|end_of_month|	balance|
|---------|---------|
|2020-01-31|	235595|
|2020-02-29|	261508|
|2020-03-31|	260971|
|2020-04-30|	264857|


#### Option 2: data is allocated on the average amount of money kept in the account in the previous 30 days

```sql
-- for each customer, we'll calculate the impact each transaction on the running balance
-- then, we'll calculate the average running balance in a month for each customer
-- finally, we'll sum all those averages to the month level

WITH all_txn AS (
SELECT 
    customer_id,
    end_of_month,
    txn_date,
    txn_amount,
    SUM(CASE WHEN txn_type='deposit' THEN txn_amount
        ELSE -txn_amount END) OVER (PARTITION BY customer_id
                                    ORDER BY txn_date) AS running_balance
FROM #customer_transactions_allM
GROUP BY customer_id, end_of_month, txn_date, txn_type, txn_amount
),
monthly_balance AS (
SELECT 
    customer_id,
    end_of_month,
    AVG(running_balance) AS avg_monthly_balance
FROM all_txn 
GROUP BY customer_id, end_of_month
)
SELECT 
    end_of_month,
    SUM(CASE WHEN avg_monthly_balance > 0 THEN avg_monthly_balance 
        ELSE 0 END) AS total_avg_monthly_balance
FROM monthly_balance
GROUP BY end_of_month
```

|end_of_month|	total_avg_monthly_balance|
|---------|--------------------|
|2020-01-31|	226299|
|2020-03-31|	256055|
|2020-02-29|	253946|
|2020-04-30|	258482|

#### Option 3: data is updated real-time 

```sql
-- calculate the total data used per day by every customer
-- then, for each customer, calculate the min, avg, max used in each month
-- finally, sum all those averages to the month level
-- note that for customers that have more than 1 transaction in a day, we'll keep only one record, which is the final amount available at the end of the day

WITH cte AS (
SELECT 
    customer_id,
    end_of_month,
    txn_date,
    txn_amount,
    SUM(CASE WHEN txn_type='deposit' THEN txn_amount
        ELSE -txn_amount END) OVER (PARTITION BY customer_id
                                    ORDER BY txn_date) AS running_balance
FROM #customer_transactions_allM
GROUP BY customer_id, end_of_month, txn_date, txn_type, txn_amount
),
daily_amount_cte AS (
SELECT 
    customer_id,
    end_of_month,
    (CASE WHEN running_balance > 0 THEN running_balance
        ELSE 0 END) AS daily_data
FROM cte
GROUP BY customer_id, end_of_month, running_balance
),
amounts_cte AS (
SELECT 
    customer_id,
    end_of_month,
    MIN(daily_data) OVER (PARTITION BY customer_id, end_of_month
                            ORDER BY end_of_month) AS min_daily_data,
    AVG(daily_data) OVER (PARTITION BY customer_id, end_of_month
                            ORDER BY end_of_month) AS avg_daily_data,
    MAX(daily_data) OVER (PARTITION BY customer_id, end_of_month
                            ORDER BY end_of_month) AS max_daily_data,
    ROW_NUMBER() OVER (PARTITION BY customer_id, end_of_month
                            ORDER BY end_of_month) AS row_no                                                                     
FROM daily_amount_cte
)
SELECT 
    end_of_month,
    SUM(min_daily_data) AS total_amount_min,
    SUM(avg_daily_data) AS total_amount_avg,
    SUM(max_daily_data) AS total_amount_max
from amounts_cte
WHERE row_no = 1
GROUP BY end_of_month
ORDER BY end_of_month;
```

|end_of_month	|total_amount_min	|total_amount_avg	|total_amount_max|
|---------|-------------|-------------|--------------|
|2020-01-31|	147692|	241626|	356618|
|2020-02-29|	170059|	264495|	375151|
|2020-03-31|	183627|	267390|	367810|
|2020-04-30|	233042|	261444|	291016|
