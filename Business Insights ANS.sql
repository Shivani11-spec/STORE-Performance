USE STORE;

CREATE TABLE sales_stores (
transaction_id VARCHAR (15),
customer_id VARCHAR (15),
customer_name VARCHAR (30),
customer_age INT,
gender VARCHAR (15),
product_id VARCHAR (15),
product_name VARCHAR (15),
product_category VARCHAR (15),
quantiy INT,
prce FLOAT,
payment_mode VARCHAR (15),
purchase_date DATE,
time_of_purchase TIME,
status VARCHAR (15)
);

Select * FROM sales_stores;

SET DATEFORMAT dmy
BULK INSERT sales_stores
FROM 'C:\Users\Shivani Bhatteja\Documents\sales_stores.csv'
    WITH (
           FIRSTROW = 2,
           FIELDTERMINATOR = ',',
           ROWTERMINATOR='\n'
           );

Making Copy of the table:

SELECT * INTO SALES FROM sales_stores;
SELECT * FROM SALES;
SELECT * FROM sales_stores;

SELECT transaction_id, COUNT(*)
FROM SALES
GROUP BY transaction_id
HAVING COUNT (transaction_id) >1;

ANS :  TXN240646
TXN342128
TXN855235
TXN981773
SELECT *, ROW_NUMBER()OVER (PARTITION BY transaction_id ORDER BY transaction_id) AS ROW_NUMBER
FROM SALES;

WITH CTE AS (SELECT *, ROW_NUMBER()OVER (PARTITION BY transaction_id ORDER BY transaction_id) AS ROW_NUMBER
FROM SALES)
SELECT * FROM CTE
WHERE ROW_NUMBER>1;

WITH CTE AS (SELECT *, ROW_NUMBER()OVER (PARTITION BY transaction_id ORDER BY transaction_id) AS ROW_NUMBER
FROM SALES)
SELECT * FROM CTE
WHERE transaction_id IN ('TXN240646' , 'TXN342128' , 'TXN855235' , 'TXN981773' );

WITH CTE AS (SELECT *, ROW_NUMBER()OVER (PARTITION BY transaction_id ORDER BY transaction_id) AS ROW_NUMBER
FROM SALES)
DELETE FROM CTE
WHERE ROW_NUMBER=2;

Correction of header spelling:

EXEC sp_rename 'SALES.quantiy','quantity','COLUMN'
EXEC sp_rename 'SALES.prce','price','COLUMN'

DECLARE @SQL NVARCHAR(MAX) = '';
SELECT @SQL = STRING_AGG(
'SELECT '''+ COLUMN_NAME + '''AS COLUMNNAME,
COUNT(*) AS NULLCOUNT
FROM ' + QUOTENAME(TABLE_SCHEMA) + '.SALES
WHERE ' + QUOTENAME(COLUMN_NAME) + ' IS NULL',
 ' UNION ALL ' 
)
WITHIN GROUP (ORDER BY COLUMN_NAME)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'SALES';

--EXECUTE the dynamic SQL
EXEC sp_executesql @SQL;

----------------------------------------------------------------

TREATING NULL VALUES

SELECT * FROM SALES
WHERE transaction_id IS NULL
OR 
customer_id IS NULL
OR
customer_name IS NULL
OR
customer_age IS NULL
OR
gender IS NULL
OR
product_id IS NULL
OR 
product_name IS NULL
OR
product_category IS NULL
OR
quantity IS NULL
OR
price IS NULL
OR
payment_mode IS NULL
OR
purchase_date IS NULL
OR
time_of_purchase IS NULL
OR
status IS NULL;

SELECT * FROM SALES
WHERE customer_id = 'CUST1003';

UPDATE SALES
SET customer_name = 'Mahika Saini',customer_age = 35,gender = 'MALE'
WHERE customer_id = 'CUST1003';

UPDATE SALES
SET payment_mode = 'Credit Card'
WHERE payment_mode = 'CC'


------------------- DATA ANALYSIS (BUSINESS QUES------------------

SELECT * FROM SALES;
Q1. TOP 5 MOST SELLING PRODUCTS BY QUANTITY?
       SELECT TOP 5 product_name, SUM(quantity) AS toatal_number_of_quantity
       FROM SALES
       WHERE status = 'delivered'
       GROUP BY product_name
       ORDER BY toatal_number_of_quantity DESC;

Q2. Which products are frequently cancelled?
     SELECT TOP 5 product_name, COUNT(status) AS total_cancelled
     FROM SALES
     WHERE status = 'cancelled'
     GROUP BY product_name
     ORDER BY total_cancelled DESC;

Q3. What time of the day has the highestnumber of purchase?
         SELECT CASE WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 0 AND 5 THEN 'NIGHT'
                     WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 6 AND 11 THEN 'MORNING'
                     WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 12 AND 17 THEN 'AFTERNOON'
                     WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 18 AND 23 THEN 'EVENING'
                     END AS time_of_day,
                     COUNT (*) AS total_order
                     FROM SALES
                     GROUP BY CASE WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 0 AND 5 THEN 'NIGHT'
                     WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 6 AND 11 THEN 'MORNING'
                     WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 12 AND 17 THEN 'AFTERNOON'
                     WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 18 AND 23 THEN 'EVENING' END
   
   Q4. TOP 5 HIGHEST SPENDING CUSTOMERS?
            SELECT TOP 5 customer_name, FORMAT(SUM (price*quantity), 'C0' , 'en_IN') AS Total_spends
            FROM SALES
            GROUP BY customer_name
            ORDER BY SUM (price*quantity) desc;

    Q5.Which product categories genrate the highest income?
            
            SELECT product_category,FORMAT(SUM(price*quantity), 'C0','en_IN') AS total_revenue
             FROM SALES
             GROUP BY product_category
             ORDER BY SUM(price*quantity) DESC;

    Q6. WHAT IS THE RETURN AND CANCELLATION RATE PER PRODUCT CATEGORY?

            SELECT * FROM SALES;
            SELECT product_category, FORMAT(COUNT(CASE WHEN status = 'cancelled' THEN 1 END)*100.0/COUNT(*),'N3') + '%' AS cancelled_percent
            FROM SALES
            GROUP BY product_category
            ORDER BY cancelled_percent DESC;

            SELECT product_category, FORMAT(COUNT(CASE WHEN status = 'returned' THEN 1 END)*100.0/COUNT(*),'N3') + '%' AS returned_percent
            FROM SALES
            GROUP BY product_category
            ORDER BY returned_percent DESC;

    Q7. What is the most preffered payment mode?
              SELECT * FROM SALES;
              SELECT payment_mode,COUNT(payment_mode) AS mode_method
              FROM SALES
              GROUP BY payment_mode
              ORDER BY mode_method DESC;

    Q8. How does age group affect purchasing behaviour?

          SELECT CASE WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
          WHEN customer_age BETWEEN 26 AND 35 THEN '26-35'
           WHEN customer_age BETWEEN 36 AND 50 THEN '36-50'
          ELSE '51+' END AS customer_age,
          FORMAT(SUM(price*quantity),'C0','en-in') AS total_purchase
          FROM SALES
          GROUP BY CASE WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
            WHEN customer_age BETWEEN 26 AND 35 THEN '26-35'
            WHEN customer_age BETWEEN 36 AND 50 THEN '36-50'
          ELSE '51+' END
          ORDER BY total_purchase DESC;

        Q9. What is the monthly sales trend?

          
          SELECT YEAR(purchase_date) AS YEARS,
                MONTH(purchase_date) AS MONTHs,
          FORMAT(SUM(price*quantity),'C0','en-in') AS total_purchase,
          SUM (quantity) AS total_quantity
          FROM SALES
          GROUP BY YEAR(purchase_date),MONTH(purchase_date);



Q10. ARE Certain genders buying more specific products categories?
        
        SELECT * FROM(
          SELECT gender,product_category
          FROM sales) AS source_table
          PIVOT(
          COUNT(gender)
          FOR gender IN ([M],[F])
          ) AS pivot_table
          ORDER BY product_category;



            
              
            
           
          
  




                  
        




