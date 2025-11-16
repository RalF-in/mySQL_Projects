-- 1. Retrieve all sales records
	SELECT 
    *
FROM
    fact_sales_data;

-- 2. Get all distinct product names
	select distinct productname, row_number() over() as serial from product;

-- 3. Find all orders placed on a specific date.
	SELECT 
    *
FROM
    fact_sales_data
WHERE
    orderdate = '2020-12-12';

-- 4. Retrieve all customers from a specific city
	SELECT DISTINCT
    c.full_name AS regional_customer
FROM
    customer_lookup c
        JOIN
    fact_sales_data fsd ON c.CustomerKey = fsd.CustomerKey
        JOIN
    territory t ON t.SalesTerritoryKey = fsd.TerritoryKey
WHERE
    t.region = 'central';

-- 5. Find customers with a specific occupation
	SELECT 
    *
FROM
    customer_lookup
WHERE
    occupation = 'management';

-- 6. Count total number of products
	SELECT 
    COUNT(DISTINCT productname) total_products
FROM
    product;

-- 7. Find the total number of orders.
	SELECT 
    COUNT(DISTINCT ordernumber) AS total_orders
FROM
    fact_sales_data;

-- 8. Show products that cost more than $50
	SELECT 
    productname, productprice
FROM
    product
WHERE
    productprice > 50
ORDER BY productprice;

-- 9. Find customers who earn more than $75,000 annually
	SELECT 
    full_name, annualincome
FROM
    customer_lookup
WHERE
    AnnualIncome > 75000
ORDER BY AnnualIncome;

-- 10. Show customers born before 1980
	SELECT 
    *
FROM
    customer_lookup
WHERE
    birthdate < '1980-01-01'
ORDER BY birthdate;

-- 11. Find the oldest customer
	SELECT 
    *
FROM
    customer_lookup
ORDER BY birthdate
LIMIT 1;

-- 12. Get the most recent sales order
	SELECT 
    *
FROM
    fact_sales_data
ORDER BY orderdate DESC
LIMIT 1;

-- 13. Find the highest-priced product
	SELECT 
    *
FROM
    product
ORDER BY productprice DESC
LIMIT 1;

-- 14. Find the number of products in each category
	SELECT 
    pc.CategoryName,
    COUNT(subcategoryname) AS total_unique_products
FROM
    product_subcategories ps
        JOIN
    product_categories pc ON ps.ProductCategoryKey = pc.ProductCategoryKey
GROUP BY pc.CategoryName
ORDER BY total_unique_products;-- unique items in each categories

SELECT 
    pc.CategoryName, COUNT(SubcategoryName) AS total_items
FROM
    product p
        JOIN
    product_subcategories ps ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
        JOIN
    product_categories pc ON pc.ProductCategoryKey = ps.ProductCategoryKey
GROUP BY pc.CategoryName
ORDER BY total_items;-- total available stock under each categories

SELECT 
    p.productname, pc.categoryname
FROM
    product p
        JOIN
    product_subcategories ps ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
        JOIN
    product_categories pc ON ps.ProductCategoryKey = pc.ProductCategoryKey
ORDER BY CategoryName;

-- 16. Show total sales revenue per region.
	SELECT 
    region, ROUND(SUM(productprice), 2) AS revenue
FROM
    fact_sales_data fsd
        JOIN
    product p ON fsd.ProductKey = p.ProductKey
        JOIN
    territory t ON fsd.TerritoryKey = t.SalesTerritoryKey
GROUP BY region
ORDER BY region;

-- 17. Find total sales quantity per product
	SELECT 
    productname, SUM(orderquantity) AS total_sold
FROM
    fact_sales_data fsd
        JOIN
    product p ON fsd.ProductKey = p.ProductKey
GROUP BY productname;

-- 18. Get total revenue per product category
	SELECT 
    pc.CategoryName, ROUND(SUM(productprice), 2) AS revenue
FROM
    fact_sales_data fsd
        JOIN
    product p ON fsd.ProductKey = p.ProductKey
        JOIN
    product_subcategories ps ON ps.ProductSubcategoryKey = p.ProductSubcategoryKey
        JOIN
    product_categories pc ON ps.productcategorykey = pc.ProductCategoryKey
GROUP BY pc.CategoryName;

-- 19. Find customers who have spent the most
	SELECT 
    full_name, ROUND(SUM(productprice), 2) total_spent
FROM
    customer_lookup c
        JOIN
    fact_sales_data fsd ON fsd.CustomerKey = c.CustomerKey
        JOIN
    product p ON fsd.ProductKey = p.ProductKey
GROUP BY Full_name
ORDER BY total_spent DESC
LIMIT 1;

-- 20. Get total orders by region
	SELECT 
    region, COUNT(ordernumber) AS total_order
FROM
    territory t
        JOIN
    fact_sales_data fsd ON t.SalesTerritoryKey = fsd.TerritoryKey
GROUP BY region
ORDER BY region;

-- 21. Find products that have been returned
	SELECT 
    p.productname, SUM(returnquantity) AS total_returned
FROM
    product p
        JOIN
    returns_data r ON p.ProductKey = r.ProductKey
GROUP BY p.productname
ORDER BY p.productname;

-- 22.	Find sales trends over time
	SELECT 
    YEAR(orderdate) AS `year`,
    MONTHNAME(orderdate) AS `monthname`,
    SUM(orderquantity) AS total_orders
FROM
    fact_sales_data
GROUP BY `monthname` , `year`;

-- 23. Find the most popular product in each category
	with catgr_prdct as (
    select Categoryname, productname, sum(orderquantity) as total_sold
    from fact_sales_data fsd
    join product p on fsd.ProductKey = p.ProductKey
    join product_subcategories ps on p.ProductSubcategoryKey = ps.ProductSubcategoryKey
    join product_categories pc on ps.ProductCategoryKey = pc.ProductCategoryKey
    group by categoryname, productname)
    select categoryname, productname, total_sold from catgr_prdct where total_sold in(select max(total_sold)
    from catgr_prdct
    group by categoryname);    
    
    -- or in a slightly different way
    with catgr_prdct as (
    select Categoryname, productname, sum(orderquantity) as total_sold, rank() over(partition by CategoryName order by sum(orderquantity) desc) as rnk
    from fact_sales_data fsd
    join product p on fsd.ProductKey = p.ProductKey
    join product_subcategories ps on p.ProductSubcategoryKey = ps.ProductSubcategoryKey
    join product_categories pc on ps.ProductCategoryKey = pc.ProductCategoryKey
    group by categoryname, productname)
    select categoryname, productname, total_sold from catgr_prdct where rnk = 1;
    
-- 24. Find top 5 highest revenue-generating products
	SELECT 
    productname, ROUND(SUM(productprice), 2) AS revenue
FROM
    fact_sales_data fsd
        JOIN
    product p ON fsd.ProductKey = p.ProductKey
GROUP BY productname
ORDER BY revenue DESC
LIMIT 5;

-- 25. Find percentage of each returned products
	with sales as(
    select productkey, sum(orderquantity) as torder
    from fact_sales_data
    group by productkey),
    
    returns as(
    select productkey, sum(returnquantity) as treturn
    from returns_data
    group by productkey)
    
    select productname, (sum(treturn) / sum(torder)) * 100 as percentage
    from sales s join returns r on s.productkey = r.productkey
    join product p on p.productkey = s.productkey
    group by productname;
    
-- 26. Find repeat customers
	SELECT 
    full_name, COUNT(ordernumber) AS total_orders
FROM
    fact_sales_data fsd
        JOIN
    customer_lookup c ON fsd.CustomerKey = c.CustomerKey
GROUP BY Full_name
HAVING total_orders > 1
ORDER BY COUNT(ordernumber) DESC;
    
-- 27. Rank products by sales in each category
	select categoryname, productname, sum(orderquantity) as total_sell, rank() over(partition by categoryname order by sum(orderquantity) desc) as `ranking`
    from fact_sales_data fsd join product p on fsd.ProductKey = p.ProductKey
    join product_subcategories ps on p.ProductSubcategoryKey = ps.ProductSubcategoryKey
    join product_categories pc on pc.ProductCategoryKey = ps.ProductCategoryKey
    group by categoryname, productname;
    
-- 28. Rank products by total revenue using RANK()
	select categoryname, productname, round(sum(p.productprice* fsd.orderquantity), 2) as revenue, rank() over(partition by categoryname order by round(sum(p.productprice* fsd.orderquantity), 2) desc) as `ranking`
    from fact_sales_data fsd join product p on fsd.ProductKey = p.ProductKey
    join product_subcategories ps on p.ProductSubcategoryKey = ps.ProductSubcategoryKey
    join product_categories pc on pc.ProductCategoryKey = ps.ProductCategoryKey
    group by pc.categoryname, p.productname;
    
-- 29. Find monthly total sales quantity
	SELECT 
    YEAR(orderdate) `year`,
    MONTHNAME(orderdate) `month`,
    SUM(orderquantity) sell
FROM
    fact_sales_data
GROUP BY year , month;
    
-- 30. Get top 3 products by sales in 2020
	SELECT 
    YEAR(orderdate) AS year,
    productname,
    SUM(orderquantity) AS sales
FROM
    fact_sales_data fsd
        JOIN
    product p ON fsd.ProductKey = p.ProductKey
GROUP BY year , productname
HAVING year = 2020
ORDER BY sales DESC
LIMIT 3;