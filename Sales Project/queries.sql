-- 1. Retrieve all sales records
	select * from fact_sales_data;

-- 2. Get all distinct product names
	select distinct productname, row_number() over() as serial from product;

-- 3. Find all orders placed on a specific date.
	select * from fact_sales_data where orderdate = '2020-12-12';

-- 4. Retrieve all customers from a specific city
	select distinct c.full_name as regional_customer
	from customer_lookup c join fact_sales_data fsd on c.CustomerKey = fsd.CustomerKey
	join territory t on t.SalesTerritoryKey = fsd.TerritoryKey
	where t.region = 'central';

-- 5. Find customers with a specific occupation
	select * from customer_lookup where occupation = 'management';

-- 6. Count total number of products
	select count(distinct productname) total_products from product;

-- 7. Find the total number of orders.
	select count(distinct ordernumber) as total_orders from fact_sales_data;

-- 8. Show products that cost more than $50
	select productname, productprice from product where productprice > 50 order by productprice;

-- 9. Find customers who earn more than $75,000 annually
	select  full_name, annualincome from customer_lookup where AnnualIncome > 75000 order by AnnualIncome;

-- 10. Show customers born before 1980
	select * from customer_lookup where birthdate < '1980-01-01' order by birthdate;

-- 11. Find the oldest customer
	select * from customer_lookup order by birthdate limit 1;

-- 12. Get the most recent sales order
	select * from fact_sales_data order by orderdate desc limit 1;

-- 13. Find the highest-priced product
	select * from product order by productprice desc limit 1;

-- 14. Find the number of products in each category
	select pc.CategoryName, count(subcategoryname) as total_unique_products
	from product_subcategories ps join product_categories pc
	on ps.ProductCategoryKey = pc.ProductCategoryKey
	group by pc.CategoryName
	order by total_unique_products; -- unique items in each categories

select pc.CategoryName, count(SubcategoryName) as total_items
	from product p join product_subcategories ps on p.ProductSubcategoryKey = ps.ProductSubcategoryKey
	join product_categories pc on pc.ProductCategoryKey = ps.ProductCategoryKey
	group by pc.CategoryName
	order by total_items; -- total available stock under each categories

-- 15.	Get all products with their categories
	select p.productname, pc.categoryname
	from product p join product_subcategories ps
	on p.ProductSubcategoryKey = ps.ProductSubcategoryKey
	join product_categories pc on ps.ProductCategoryKey = pc.ProductCategoryKey
	order by CategoryName;

-- 16. Show total sales revenue per region.
	select region, round(sum(productprice), 2) as revenue from fact_sales_data fsd join product p on fsd.ProductKey = p.ProductKey
	join territory t on fsd.TerritoryKey = t.SalesTerritoryKey
	group by region
	order by region;

-- 17. Find total sales quantity per product
	select productname, sum(orderquantity) as total_sold
	from fact_sales_data fsd join product p on fsd.ProductKey = p.ProductKey
	group by productname;

-- 18. Get total revenue per product category
	select pc.CategoryName, round(sum(productprice), 2) as revenue
	from fact_sales_data fsd join product p on fsd.ProductKey = p.ProductKey
	join product_subcategories ps on  ps.ProductSubcategoryKey = p.ProductSubcategoryKey
	join product_categories pc on ps.productcategorykey = pc.ProductCategoryKey
	group by pc.CategoryName;

-- 19. Find customers who have spent the most
	select full_name, round(sum(productprice), 2) total_spent
	from customer_lookup c join fact_sales_data fsd on fsd.CustomerKey = c.CustomerKey
	join product p on fsd.ProductKey = p.ProductKey
	group by Full_name
	order by total_spent desc
	limit 1;

-- 20. Get total orders by region
	select region, count(ordernumber) as total_order
	from territory t join fact_sales_data fsd on t.SalesTerritoryKey = fsd.TerritoryKey
	GROUP BY region
	order by region;

-- 21. Find products that have been returned
	select p.productname, sum(returnquantity) as total_returned
	from product p join returns_data r on p.ProductKey = r.ProductKey
	group by p.productname
	order by p.productname;

-- 22.	Find sales trends over time
	select year(orderdate) as `year`, monthname(orderdate) as `monthname`,  sum(orderquantity) as total_orders
	from fact_sales_data
	group by `monthname`, `year`;

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
	select productname, round(sum(productprice), 2) as revenue
    from fact_sales_data fsd join product p on fsd.ProductKey = p.ProductKey
    group by productname
    order by revenue desc
    limit 5;

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
	select full_name, count(ordernumber) as total_orders
	from fact_sales_data fsd join customer_lookup c on fsd.CustomerKey = c.CustomerKey
	group by Full_name
	having total_orders > 1
	order by count(ordernumber) desc;
    
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
	select year(orderdate) `year`, monthname(orderdate) `month`, sum(orderquantity) sell
	from fact_sales_data
	group by year, month;
    
-- 30. Get top 3 products by sales in 2020
	select year(orderdate) as year, productname, sum(orderquantity) as sales
    from fact_sales_data fsd
    join product p on fsd.ProductKey = p.ProductKey
    group by year, productname
    having year = 2020
    order by sales desc
    limit 3;

    
    
    
    