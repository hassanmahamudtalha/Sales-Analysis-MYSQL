USE gdb023;

/* 1.	Provide the list of markets in which customer "Atliq Exclusive" operates 
its business in the APAC region. */

 SELECT MARKET,PLATFORM,`CHANNEL`,SUB_ZONE 
 FROM DIM_CUSTOMER
 WHERE CUSTOMER = "ATLIQ EXCLUSIVE" AND REGION = "APAC";  
 
 /* 2.	What is the percentage of unique product increase in 2021 vs. 2020?
 The final output contains these fields,  
 unique_products_2020  unique_products_2021  percentage_chg  */
 
WITH unique_products_2020 AS 
( 
	SELECT COUNT(DISTINCT(PRODUCT_CODE)) AS PRODUCT_COUNT2020
    FROM FACT_GROSS_PRICE
    WHERE FISCAL_YEAR = 2020
),
unique_products_2021 AS 
( 
	SELECT COUNT(DISTINCT(PRODUCT_CODE)) AS PRODUCT_COUNT2021
    FROM FACT_GROSS_PRICE
    WHERE FISCAL_YEAR = 2021
)

SELECT   PRODUCT_COUNT2020 ,PRODUCT_COUNT2021 , 
((PRODUCT_COUNT2021 - PRODUCT_COUNT2020 ) / PRODUCT_COUNT2020) * 100 AS percentage_chg
FROM unique_products_2020
cross JOIN unique_products_2021;

/* 3.	Provide a report with all the unique product counts for each segment and sort
 them in descending order of product counts. The final output contains 2 fields,  
 segment product_count  */
 

SELECT segment,count(PRODUCT) AS PRODUCT_COUNT
from dim_product
GROUP BY segment
order by PRODUCT_COUNT DESC ; 

/* 4. Follow-up: Which segment had the most increase in unique products in
2021 vs 2020? The final output contains these fields,
segment
product_count_2020
product_count_2021
difference */

WITH TABLE_VIEW AS 
(
	SELECT SEGMENT , PRODUCT_CODE , FISCAL_YEAR
    FROM dim_product
    JOIN fact_sales_monthly USING(PRODUCT_CODE)
),
 
product_count_2020 AS 
(
	select SEGMENT,count(PRODUCT_CODE) AS PRODUCT_COUNT2020
    FROM TABLE_VIEW
    WHERE FISCAL_YEAR = 2020
    group by SEGMENT
),

product_count_2021 AS 
(
	select SEGMENT,count(PRODUCT_CODE) AS PRODUCT_COUNT2021
    FROM TABLE_VIEW
    WHERE FISCAL_YEAR = 2021
    group by SEGMENT
),
PRODUCT_COUNT_2020_2021 AS
(
	select *
    FROM product_count_2021
    JOIN product_count_2020 using(SEGMENT)
)

SELECT * , PRODUCT_COUNT2021 - PRODUCT_COUNT2020 AS DEFFERENT
FROM  PRODUCT_COUNT_2020_2021;

/** 5. Get the products that have the highest and lowest manufacturing costs.
The final output should contain these fields,
product_code
product
manufacturing_cosT **/

WITH TABLE_VIWE AS (
select product_code , product ,manufacturing_cost
FROM dim_product
JOIN fact_manufacturing_cost USING(product_code)
),
MAX_COST AS (
select PRODUCT , max(manufacturing_cost) AS MAX_manufacturing_cost
FROM TABLE_VIWE
group by PRODUCT
),
MIN_COST AS (
select PRODUCT , MIN(manufacturing_cost) AS MIN_manufacturing_cost
FROM TABLE_VIWE
group by PRODUCT
),
MAX_MIN_manufacturing_cost AS (
select * 
FROM MIN_COST 
JOIN MAX_COST USING(PRODUCT) 
)

select DISTINCT (product) AS product ,product_code  ,
 concat( MIN_manufacturing_cost, " || " ,MAX_manufacturing_cost ) AS MAX_MIN_COST

FROM TABLE_VIWE
JOIN MAX_MIN_manufacturing_cost USING(PRODUCT);

/* 6. Generate a report which contains the top 5 customers who received an
average high pre_invoice_discount_pct for the fiscal year 2021 and in the
Indian market. The final output contains these fields,
customer_code
customer
average_discount_percentage */

with main_table as (
select a.customer_code , 
	   a.customer ,
       a.market , 
       b.fiscal_year,
       b.pre_invoice_discount_pct
from dim_customer as a
join fact_pre_invoice_deductions as b 
ON a.customer_code = B.customer_code
where A.market = "india" and b.fiscal_year = 2021
)
SELECT 
	  CUSTOMER_CODE, customer ,
      avg(pre_invoice_discount_pct)*100 AS average_discount_percentage
      FROM MAIN_TABLE
      group by  CUSTOMER_CODE, customer
      order by average_discount_percentage DESC
      limit 5;
/* 7. Get the complete report of the Gross sales amount for the customer
'Atliq Exclusive' for each month. This analysis helps to get an idea of low and
high-performing months and take strategic decisions.
The final report contains these columns:
Month
Year
Gross sales Amount */
WITH MAIN_TABLE AS (
	SELECT CUSTOMER ,
    customer_code,
    product_code,
   `date`,
   gross_price,
   sold_quantity
   from dim_customer
   JOIN fact_sales_monthly USING(customer_code)
   JOIN fact_gross_price using(product_code)
   WHERE customer = 'Atliq Exclusive'
)
	select month(`DATE`) AS`MONTH`,
    year(`DATE`) AS `YEAR`,
	SUM( sold_quantity * GROSS_PRICE) AS Gross_SALES_AMOUNT
    FROM MAIN_TABLE
    group by `MONTH`, `YEAR`
    order by    `YEAR`,`MONTH`;
 
/* 8. In which quarter of 2020, got the maximum total_sold_quantity? The final
output contains these fields sorted by the total_sold_quantity,
Quarter
total_sold_quantity */
 
 
WITH MAIN_TABLE AS (
select fiscal_year , sold_quantity, MONTH(`DATE`) AS `MONTH`
FROM FACT_SALES_MONTHLY
)
SELECT 
	SUM(SOLD_QUANTITY) AS total_sold_quantity,		
    CASE
		WHEN `MONTH` IN (9,10,11) THEN 1
        WHEN `MONTH` IN (12,1,2) THEN 2
        WHEN `MONTH` IN (3,4,5) THEN 3
        WHEN `MONTH` IN (6,7,8) THEN 4
	END AS`QUARTER`
FROM MAIN_TABLE
WHERE fiscal_year = 2020
group by `QUARTER`;

/* 9. Which channel helped to bring more gross sales in the fiscal year 2021
and the percentage of contribution? The final output contains these fields,
channel
gross_sales_mln
percentage */ 
 
with main_table as (
	select dim_customer.`channel` , 
    fact_sales_monthly.sold_quantity,
	fact_gross_price.gross_price,
    fact_sales_monthly.fiscal_year
    from dim_customer
    join fact_sales_monthly using(customer_code)
    join fact_gross_price using(product_code)
  
),
sell_table as (
	 select `channel` , sum(sold_quantity * gross_price) as gross_sales
     from main_table
     where fiscal_year = 2021
     group by `channel`
)

 select `channel`,
 round(gross_sales / 1000000,2) as gross_sales_mln ,
 round((gross_sales / ts)*100,2) as percentage
from sell_table , 
(select sum(gross_sales) as ts from sell_table) as tsell;
 
/* 10. Get the Top 3 products in each division that have a high
total_sold_quantity in the fiscal_year 2021? The final output contains these
fields,
division
product_code
product
total_sold_quan
rank_order */ 

with main_table as (
select product_code , product , division ,sum(sold_quantity) as total_sold_quan
from dim_product
join fact_sales_monthly using(product_code)
where fiscal_year = 2021
group by  product_code , product , division
) ,
rank_valu as ( 
 select * ,
 rank () over(partition by division order by total_sold_quan  ) as rank_order 
 from main_table
 )
 select * 
 from rank_valu
 where rank_order <= 3;
 
 
 
 
 
 
 
 
 