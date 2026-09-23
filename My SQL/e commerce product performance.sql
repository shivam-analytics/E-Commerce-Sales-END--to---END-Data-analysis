CREATE DATABASE ecommerce_sales;
USE ecommerce_sales;
CREATE TABLE ecommerce_sales_data (
    Order_ID INT,
    Order_Date DATE,
    Customer_Name VARCHAR(100),
    Region VARCHAR(50),
    City VARCHAR(100),
    Category VARCHAR(100),
    Sub_Category VARCHAR(100),
    Product_Name VARCHAR(255),
    Quantity INT,
    Unit_Price INT,
    Discount INT,
    Sales DECIMAL(12,2),
    Profit DECIMAL(12,2),
    Payment_Mode VARCHAR(50)
);
SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE "C:/Users/vishw/OneDrive/Desktop/projects 6   sep/E-Commerce Sales/Ecommerce_sales_clean.csv"
INTO TABLE ecommerce_sales_data 
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*)  AS total_Rows 
from  ecommerce_sales_data;

ALTER TABLE ecommerce_sales_data 
RENAME TO  ecommerce_sales ;

SELECT COUNT(*) AS total_rowsd 
from  ecommerce_sales;

SELECT  * FROM 
ecommerce_sales  limit 5;


-- product wise total sales 
SELECT 
	Product_Name ,
    ROUND(sum(Sales),2) as Total_sales 
FROM  ecommerce_sales 
GROUP BY Product_Name 
ORDER BY  Total_sales DESC ;

-- Top 10 product by sales 
SELECT 
		Product_Name ,
        ROUND(SUM(Sales),2) AS  total_Sales
FROM ecommerce_sales
GROUP BY Product_Name
ORDER BY total_Sales DESC  LIMIT 10;

-- Product wise total quantity
SELECT Product_Name,
SUM(Quantity) AS total_Quantity 
FROM  ecommerce_sales
GROUP BY  Product_Name
ORDER BY total_Quantity DESC ;

-- Product wise total profit
SELECT Product_Name ,
ROUND(SUM(Profit),2) AS total_profit
FROM ecommerce_sales 
GROUP BY  Product_Name 
ORDER  BY total_profit DESC;

-- Product wise sales vs profit
SELECT Product_Name ,
ROUND(SUM(Sales),2) AS total_sales,
ROUND(SUM(Profit),2) AS total_profit
FROM ecommerce_sales 
GROUP BY  Product_Name
ORDER BY total_sales DESC;

-- Product wise profit margin 
-- profit margin =(total profit / total sales )*100 
 
SELECT Product_Name ,
ROUND(SUM(Sales),2) AS total_sales,
ROUND(SUM(Profit),2) AS total_profit,
ROUND(
		(SUM(Profit) / NULLIF (SUM(Sales),0)) *100 , 
        2
	) AS profit_Margin_percent
    
From ecommerce_sales
Group  by Product_Name 
Order by profit_Margin_percent desc ;

-- Product wise average discount

SELECT Product_Name ,
ROUND(AVG(Discount),2)  AS avg_discount
FROM  ecommerce_sales
GROUP  BY Product_Name 
order by avg_discount DESC ;

-- product with above average sales 

SELECT Product_Name,
ROUND(SUM(Sales),2) AS total_sales 
FROM ecommerce_sales
GROUP BY  Product_Name 
HAVING SUM(Sales) >(
		SELECT AVG(Product_Total_Sales)
	FROM(
		SELECT 
				Product_Name,
                SUM(Sales) AS Product_Total_Sales
			FROM ecommerce_sales
            GROUP  BY Product_Name 
		) AS Product_Summary
	)
     ORDER BY total_Sales DESC ;

-- Products with Above-Average Profit

SELECT Product_Name ,
ROUND(SUM(Profit),2) AS total_profit
FROM ecommerce_sales
GROUP BY Product_Name 
HAVING SUM(profit) > (
	SELECT AVG(product_Total_profit)
    FROM (
		SELECT	Product_Name,
        SUM(profit) AS  product_Total_profit
        FROM  ecommerce_sales
        GROUP  BY  Product_Name 
	) AS product_summary
)  
	order by  total_profit ;
    
-- Product Performance using

WITH product_summary AS (
	SELECT	Product_Name ,
    SUM(Sales) AS total_Sales,
    SUM(Profit) AS total_profit,
    SUM(Quantity) AS total_Quantity
FROM ecommerce_sales
GROUP BY Product_Name
) 

SELECT Product_Name,
ROUND(total_sales,2)   as total_sales,
ROUND(total_profit,2) as total_profit,
total_Quantity
FROM  product_summary
ORDER BY total_Sales desc ;

--  Product Profit Margin using 

WITH product_Summary AS (
SELECT
Product_Name ,
SUM(Sales) as total_Sales,
sum(profit) as total_profit
from ecommerce_sales 
group  by Product_Name
) 

SELECT
		Product_Name,
        ROUND(total_sales,2) as total_Sales,
        round(total_profit,2) as total_profit,
        round(
				(total_profit /NULLIF (total_sales ,0))*100 ,
                2
			) as profit_margin_percent
		from  product_Summary 
        order by  profit_margin_percent desc ;
        
        
--  Product Sales Ranking using 

WITH  product_summary  AS (
select Product_Name ,
sum(sales) as total_sales 
from  ecommerce_sales
group by Product_Name
) 
select Product_Name ,
round(total_sales,2) as total_sales ,
rank() over (order by  total_sales desc ) as sales_rank
from product_summary
order by  sales_rank;

--   Product Sales Ranking using DENSE_RANK()  

WITH product_Summary  AS (
SELECT Product_Name ,
sum(sales) as total_Sales
from ecommerce_sales 
group  by  Product_Name
)  
	select 
    Product_Name,
    round(total_sales,2) as total_Sales,
    DENSE_RANK() OVER(ORDER BY total_Sales DESC ) AS sales_rank
FROM product_Summary
ORDER BY  sales_rank;


--    Product Sales Ranking using ROW_NUMBER()

WITH Product_Summary AS (
SELECT
Product_Name,
	SUM(Sales) AS Total_Sales
    FROM ecommerce_sales
    GROUP BY Product_Name
)
SELECT
    Product_Name,
    ROUND(Total_Sales, 2) AS Total_Sales,
    ROW_NUMBER() OVER (ORDER BY Total_Sales DESC) AS Sales_Row_Number
FROM Product_Summary
ORDER BY Sales_Row_Number;

  -- Top 3 Products by Sales using RANK()
  
  WITH Product_Summary AS (
SELECT Product_Name,
	SUM(Sales) AS Total_Sales
    FROM ecommerce_sales
    GROUP BY Product_Name
),
Product_Ranking AS (
    SELECT
	Product_Name,
	Total_Sales,
	RANK() OVER (ORDER BY Total_Sales DESC) AS Sales_Rank
    FROM Product_Summary
)
SELECT
    Product_Name,
    ROUND(Total_Sales, 2) AS Total_Sales,
    Sales_Rank
FROM Product_Ranking
WHERE Sales_Rank <= 3
ORDER BY Sales_Rank;


