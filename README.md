# Sales-Analysis-MYSQL




## 1. Markets Operated by "Atliq Exclusive" in the APAC Region 
### Query:
```sql
SELECT MARKET, PLATFORM, `CHANNEL`, SUB_ZONE  
FROM DIM_CUSTOMER  
WHERE CUSTOMER = "ATLIQ EXCLUSIVE" AND REGION = "APAC";
```

### Results:

| Market       | Platform       | Channel  | Sub Zone |
|-------------|--------------|---------|----------|
| Australia   | Brick & Mortar | Direct  | ANZ      |
| Bangladesh  | Brick & Mortar | Direct  | ROA      |
| India       | Brick & Mortar | Direct  | India    |
| India       | Brick & Mortar | Retailer| India    |
| Indonesia   | Brick & Mortar | Direct  | ROA      |
| Japan       | Brick & Mortar | Direct  | ROA      |
| New Zealand | Brick & Mortar | Direct  | ANZ      |
| Philippines | Brick & Mortar | Direct  | ROA      |
| South Korea | Brick & Mortar | Direct  | ROA      |

### Summary:
- "Atliq Exclusive" operates in **9 markets** within the APAC region.  
- The primary platform is **Brick & Mortar** across all markets.  
- The company mainly operates in the **Direct** channel, except for one **Retailer** presence in India.  
- Markets are divided into sub-zones: **ANZ (Australia, New Zealand), ROA (Rest of Asia), and India.**

---

## 2. Percentage Increase in Unique Products (2020 vs. 2021)  

### Query:  
```sql
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

SELECT PRODUCT_COUNT2020, PRODUCT_COUNT2021,  
       ((PRODUCT_COUNT2021 - PRODUCT_COUNT2020) / PRODUCT_COUNT2020) * 100 AS percentage_chg  
FROM unique_products_2020  
CROSS JOIN unique_products_2021;
```

### Output:  

| PRODUCT_COUNT2020 | PRODUCT_COUNT2021 | percentage_chg |
|------------------|------------------|---------------|
| 245             | 334               | 36.33%        |

### Summary:  
- The number of unique products increased from **245 in 2020** to **334 in 2021**.  
- This represents a **36.33% growth** in unique products.  
- The increase suggests an expansion in product offerings or new product launches in 2021.  


---

## 3. Unique Product Counts by Segment  

### Query:  
```sql
SELECT segment, COUNT(PRODUCT) AS PRODUCT_COUNT  
FROM dim_product  
GROUP BY segment  
ORDER BY PRODUCT_COUNT DESC;  
```

### Output:  

| Segment      | Product Count |
|-------------|--------------|
| Notebook    | 129          |
| Accessories | 116          |
| Peripherals | 84           |
| Desktop     | 32           |
| Storage     | 27           |
| Networking  | 9            |

### Summary:  
- The **Notebook** segment has the highest number of unique products (**129**).  
- **Accessories** and **Peripherals** follow with **116** and **84** unique products, respectively.  
- The **Networking** segment has the lowest number of unique products (**9**).  
- This report helps understand which product categories have the most variety in offerings.  

---


## 4. Increase in Unique Products by Segment (2021 vs 2020)  

### Query:  
```sql
WITH TABLE_VIEW AS 
(
	SELECT SEGMENT , PRODUCT_CODE , FISCAL_YEAR
    FROM dim_product
    JOIN fact_sales_monthly USING(PRODUCT_CODE)
),
 
product_count_2020 AS 
(
	SELECT SEGMENT, COUNT(PRODUCT_CODE) AS PRODUCT_COUNT2020
    FROM TABLE_VIEW
    WHERE FISCAL_YEAR = 2020
    GROUP BY SEGMENT
),

product_count_2021 AS 
(
	SELECT SEGMENT, COUNT(PRODUCT_CODE) AS PRODUCT_COUNT2021
    FROM TABLE_VIEW
    WHERE FISCAL_YEAR = 2021
    GROUP BY SEGMENT
),
PRODUCT_COUNT_2020_2021 AS
(
	SELECT *
    FROM product_count_2021
    JOIN product_count_2020 USING(SEGMENT)
)

SELECT *, PRODUCT_COUNT2021 - PRODUCT_COUNT2020 AS DIFFERENCE
FROM PRODUCT_COUNT_2020_2021;
```

### Output:  

| Segment      | Product Count 2021 | Product Count 2020 | Difference |
|-------------|------------------|------------------|------------|
| Notebook    | 193,825          | 112,187          | 81,638     |
| Accessories | 193,598          | 112,763          | 80,835     |
| Peripherals | 141,045          | 102,878          | 38,167     |
| Desktop     | 30,734           | 2,026            | 28,708     |
| Storage     | 31,977           | 22,453           | 9,524      |
| Networking  | 16,929           | 11,216           | 5,713      |

### Summary:  
- The **Notebook** segment saw the highest increase in unique products, adding **81,638** new products in 2021.  
- The **Accessories** segment closely follows with **80,835** new products.  
- **Peripherals** also saw a significant increase of **38,167** unique products.  
- **Desktop** had an increase of **28,708**, while **Storage** and **Networking** had smaller increases of **9,524** and **5,713**, respectively.  
- This analysis helps identify which product segments experienced the most growth in terms of unique offerings.  

---


## 5. Products with Highest and Lowest Manufacturing Costs  

### Query:  
```sql
WITH TABLE_VIEW AS (
    SELECT product_code, product, manufacturing_cost
    FROM dim_product
    JOIN fact_manufacturing_cost USING(product_code)
),
MAX_COST AS (
    SELECT product, MAX(manufacturing_cost) AS MAX_manufacturing_cost
    FROM TABLE_VIEW
    GROUP BY product
),
MIN_COST AS (
    SELECT product, MIN(manufacturing_cost) AS MIN_manufacturing_cost
    FROM TABLE_VIEW
    GROUP BY product
),
MAX_MIN_manufacturing_cost AS (
    SELECT * 
    FROM MIN_COST 
    JOIN MAX_COST USING(product) 
)

SELECT DISTINCT product, product_code,
       CONCAT(MIN_manufacturing_cost, " - ", MAX_manufacturing_cost) AS MAX_MIN_COST
FROM TABLE_VIEW
JOIN MAX_MIN_manufacturing_cost USING(product);
```

### Output:  

| Product | Product Code | Min - Max Manufacturing Cost |
|---------|-------------|------------------------------|
| AQ Dracula HDD – 3.5 Inch SATA 6 Gb/s 5400 RPM 256 MB Cache | A0118150101 | 5.0207 - 6.8199 |
| AQ Dracula HDD – 3.5 Inch SATA 6 Gb/s 5400 RPM 256 MB Cache | A0118150102 | 5.0207 - 6.8199 |
| AQ Dracula HDD – 3.5 Inch SATA 6 Gb/s 5400 RPM 256 MB Cache | A0118150103 | 5.0207 - 6.8199 |
| AQ Dracula HDD – 3.5 Inch SATA 6 Gb/s 5400 RPM 256 MB Cache | A0118150104 | 5.0207 - 6.8199 |
| AQ WereWolf NAS Internal Hard Drive HDD – 8.89 cm | A0219150201 | 6.4858 - 7.3563 |
| AQ WereWolf NAS Internal Hard Drive HDD – 8.89 cm | A0219150202 | 6.4858 - 7.3563 |
| AQ WereWolf NAS Internal Hard Drive HDD – 8.89 cm | A0220150203 | 6.4858 - 7.3563 |
| AQ Zion Saga | A0320150301 | 6.8414 - 8.4291 |
| AQ Zion Saga | A0321150302 | 6.8414 - 8.4291 |
| AQ Zion Saga | A0321150303 | 6.8414 - 8.4291 |

### Summary:  
- The **AQ Dracula HDD – 3.5 Inch SATA** series has manufacturing costs ranging between **$5.02 and $6.81**.  
- The **AQ WereWolf NAS Internal Hard Drive HDD** costs range from **$6.48 to $7.35**.  
- The **AQ Zion Saga** has the highest cost variation, ranging from **$6.84 to $8.42**.  

This report provides insights into the variation in manufacturing costs across different products, which can help optimize pricing and cost management strategies.  

---


## 6. Top 5 Customers with Highest Average Pre-Invoice Discount in 2021 (Indian Market)  

### Query:  
```sql
WITH main_table AS (
    SELECT a.customer_code, 
           a.customer,
           a.market, 
           b.fiscal_year,
           b.pre_invoice_discount_pct
    FROM dim_customer AS a
    JOIN fact_pre_invoice_deductions AS b 
    ON a.customer_code = b.customer_code
    WHERE a.market = "India" AND b.fiscal_year = 2021
)
SELECT 
    customer_code, 
    customer,
    AVG(pre_invoice_discount_pct) * 100 AS average_discount_percentage
FROM main_table
GROUP BY customer_code, customer
ORDER BY average_discount_percentage DESC
LIMIT 5;
```

### Output:  

| Customer Code | Customer  | Average Discount Percentage |
|--------------|----------|----------------------------|
| 90002009     | Flipkart | 30.83%                      |
| 90002006     | Viveks   | 30.38%                      |
| 90002003     | Ezone    | 30.28%                      |
| 90002002     | Croma    | 30.25%                      |
| 90002016     | Amazon   | 29.33%                      |

### Summary:  
- **Flipkart** received the highest average pre-invoice discount at **30.83%**.  
- **Amazon** had the lowest discount among the top 5 at **29.33%**.  
- The discount percentages are close, indicating competitive pricing strategies among top retailers in the Indian market.  

This report helps identify the key customers benefiting from higher discounts, which can be useful for sales strategy and negotiations.  

---


## 7. Monthly Gross Sales Report for "Atliq Exclusive"  

This report provides an overview of the **gross sales amount** for "Atliq Exclusive" on a **monthly** and **yearly** basis. This analysis helps in identifying **high-performing** and **low-performing** months to assist in strategic decision-making.  

### Query:  
```sql
WITH MAIN_TABLE AS (
    SELECT CUSTOMER,
           customer_code,
           product_code,
           `date`,
           gross_price,
           sold_quantity
    FROM dim_customer
    JOIN fact_sales_monthly USING(customer_code)
    JOIN fact_gross_price USING(product_code)
    WHERE customer = 'Atliq Exclusive'
)
SELECT 
    MONTH(`DATE`) AS `MONTH`,
    YEAR(`DATE`) AS `YEAR`,
    SUM(sold_quantity * GROSS_PRICE) AS Gross_SALES_AMOUNT
FROM MAIN_TABLE
GROUP BY `MONTH`, `YEAR`
ORDER BY `YEAR`, `MONTH`;
```

### Output:  

| Month | Year | Gross Sales Amount (₹) |
|--------|------|----------------------|
| 9  | 2019 | 9,092,670.34  |
| 10 | 2019 | 10,378,637.60 |
| 11 | 2019 | 15,231,894.97 |
| 12 | 2019 | 9,755,795.06  |
| 1  | 2020 | 9,584,951.94  |
| 2  | 2020 | 8,083,995.55  |
| 3  | 2020 | 766,976.45   |
| 4  | 2020 | 800,071.95   |
| 5  | 2020 | 1,586,964.48  |
| 6  | 2020 | 3,429,736.57  |
| 7  | 2020 | 5,151,815.40  |
| 8  | 2020 | 5,638,281.83  |
| 9  | 2020 | 19,530,271.30 |
| 10 | 2020 | 21,016,218.21 |
| 11 | 2020 | 32,247,289.79 |
| 12 | 2020 | 20,409,063.18 |
| 1  | 2021 | 19,570,701.71 |
| 2  | 2021 | 15,986,603.89 |
| 3  | 2021 | 19,149,624.92 |
| 4  | 2021 | 11,483,530.30 |
| 5  | 2021 | 19,204,309.41 |
| 6  | 2021 | 15,457,579.66 |
| 7  | 2021 | 19,044,968.82 |
| 8  | 2021 | 11,324,548.34 |

### Key Insights:  
- **Best performing month:** **November 2020** (₹32,247,289.79)  
- **Lowest performing month:** **March 2020** (₹766,976.45)  
- Sales saw a sharp dip from **March to May 2020**, possibly due to **COVID-19 lockdowns**.  
- Recovery was observed in the latter half of **2020 and early 2021**, with consistent sales figures.  

This report can help in evaluating sales trends, optimizing inventory, and aligning business strategies for peak sales periods.  

---


## 8. Quarterly Sales Analysis for 2020  

This report identifies the **quarter with the highest total sold quantity** in the **fiscal year 2020**. The data is sorted by **total sold quantity** to highlight the quarter with the maximum sales.  

### Query:  
```sql
WITH MAIN_TABLE AS (
    SELECT fiscal_year, sold_quantity, MONTH(`DATE`) AS `MONTH`
    FROM FACT_SALES_MONTHLY
)
SELECT 
    SUM(SOLD_QUANTITY) AS total_sold_quantity,		
    CASE
        WHEN `MONTH` IN (9,10,11) THEN 1
        WHEN `MONTH` IN (12,1,2) THEN 2
        WHEN `MONTH` IN (3,4,5) THEN 3
        WHEN `MONTH` IN (6,7,8) THEN 4
    END AS `QUARTER`
FROM MAIN_TABLE
WHERE fiscal_year = 2020
GROUP BY `QUARTER`
ORDER BY total_sold_quantity DESC;
```

### Output:  

| Quarter | Total Sold Quantity |
|---------|--------------------|
| 1       | 7,005,619         |
| 4       | 5,042,541         |
| 2       | 6,649,642         |
| 3       | 2,075,087         |

### Key Insights:  
- **Q1 (Sept-Nov 2020) had the highest sales** with **7,005,619** units sold.  
- **Q3 (March-May 2020) recorded the lowest sales**, possibly due to COVID-19 lockdowns.  
- A significant drop was observed in **Q3**, followed by a **strong recovery in Q4**.  

Understanding these trends can help in **inventory management**, **marketing strategies**, and **sales forecasting** for future quarters.  


---

## 9. Channel-wise Gross Sales Analysis for 2021  

This report identifies the **channel that contributed the most to gross sales** in **fiscal year 2021**, along with its percentage contribution.  

### Query:  
```sql
WITH main_table AS (
    SELECT dim_customer.`channel`, 
           fact_sales_monthly.sold_quantity,
           fact_gross_price.gross_price,
           fact_sales_monthly.fiscal_year
    FROM dim_customer
    JOIN fact_sales_monthly USING(customer_code)
    JOIN fact_gross_price USING(product_code)
),
sell_table AS (
    SELECT `channel`, 
           SUM(sold_quantity * gross_price) AS gross_sales
    FROM main_table
    WHERE fiscal_year = 2021
    GROUP BY `channel`
)
SELECT `channel`,
       ROUND(gross_sales / 1000000, 2) AS gross_sales_mln,
       ROUND((gross_sales / ts) * 100, 2) AS percentage
FROM sell_table, 
     (SELECT SUM(gross_sales) AS ts FROM sell_table) AS tsell;
```

### Output:  

| Channel     | Gross Sales (Million) | Percentage Contribution |
|------------|----------------------|-------------------------|
| Retailer   | 1924.17              | 73.22%                  |
| Direct     | 406.69               | 15.47%                  |
| Distributor| 297.18               | 11.31%                  |

### Key Insights:  
- **Retailers contributed the most** to gross sales in 2021, accounting for **73.22%** of total revenue.  
- **Direct sales made up 15.47%**, while **Distributors contributed 11.31%**.  
- The dominance of **Retailer sales** suggests a strong **B2C market presence**, and future **marketing and distribution strategies** should capitalize on this channel.  


---

## 10. Top 3 High-Selling Products in Each Division (2021)  

This report highlights the **top 3 products in each division** based on **total sold quantity** for the **fiscal year 2021**.  

### Query:  
```sql
WITH main_table AS (
    SELECT product_code, product, division, SUM(sold_quantity) AS total_sold_quan
    FROM dim_product
    JOIN fact_sales_monthly USING(product_code)
    WHERE fiscal_year = 2021
    GROUP BY product_code, product, division
), 
rank_valu AS ( 
    SELECT *, 
           RANK() OVER(PARTITION BY division ORDER BY total_sold_quan DESC) AS rank_order 
    FROM main_table
)
SELECT * 
FROM rank_valu
WHERE rank_order <= 3;
```

### Output:  

| Product Code  | Product                 | Division | Total Sold Quantity | Rank Order |
|--------------|-------------------------|----------|---------------------|------------|
| A7321160301  | AQ Wi Power Dx3         | N & S    | 281,363             | 1          |
| A7220160203  | AQ Wi Power Dx2         | N & S    | 277,299             | 2          |
| A7219160201  | AQ Wi Power Dx2         | N & S    | 275,328             | 3          |
| A3718150105  | AQ LION x1              | P & A    | 34,080              | 1          |
| A3718150102  | AQ LION x1              | P & A    | 34,022              | 2          |
| A3920150304  | AQ LION x3              | P & A    | 33,523              | 3          |
| A6119110204  | AQ HOME Allin1 Gen 2    | PC       | 2,286               | 1          |
| A6119110202  | AQ HOME Allin1 Gen 2    | PC       | 2,285               | 2          |
| A6018110106  | AQ Home Allin1          | PC       | 2,281               | 3          |

### Key Insights:  
- **"AQ Wi Power Dx3"** was the **top-selling product in the N & S division** with **281,363 units sold**.  
- **"AQ LION x1"** dominated the **P & A division**, with **34,080 units sold**.  
- **"AQ HOME Allin1 Gen 2"** was the **top product in the PC division**, selling **2,286 units**.  
- The **N & S division** had significantly **higher sales volume** compared to **P & A and PC divisions**.  

---


