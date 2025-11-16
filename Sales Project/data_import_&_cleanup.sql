create database sales_project;
use sales_project;

/* show variables like 'local_infile';
set global local_infile = 0;
SHOW VARIABLES LIKE 'secure_file_priv'; */

-- import returns_data
load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Returns_Data.csv"
into table returns_data
fields terminated by ','
optionally enclosed by '"'
lines terminated by '\r\n'
ignore 1 lines;

-- import product_subcategories
load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Product_Subcategories.csv"
into table product_subcategories
fields terminated by ','
optionally enclosed by '"'
lines terminated by '\r\n'
ignore 1 lines;

-- import calendar
load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Calendar.csv"
into table calendar
fields terminated by ','
optionally enclosed by '"'
lines terminated by '\r\n'
ignore 1 lines;

-- import fact_sales_data
load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/fact_sales_data.csv"
into table fact_sales_data
fields terminated by ','
optionally enclosed by '"'
lines terminated by '\r\n'
ignore 1 lines;

-- import product
load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/product.csv"
into table product
fields terminated by ','
optionally enclosed by '"'
lines terminated by '\r\n'
ignore 1 lines;

-- import customer_lookup
load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/customer_lookup.csv"
into table customer_lookup
fields terminated by ','
optionally enclosed by '"'
lines terminated by '\r\n'
ignore 1 lines;


-- fixing dates
set sql_safe_updates = 0;

-- calendar
UPDATE calendar 
SET 
    date = STR_TO_DATE(date, '%m/%d/%Y');
alter table calendar
modify date Date;

-- customer_lookup
UPDATE customer_lookup 
SET 
    Birthdate = STR_TO_DATE(Birthdate, '%m/%d/%Y');
alter table customer_lookup
modify BirthDate Date;

-- fact_sales_data
UPDATE fact_sales_data 
SET 
    OrderDate = STR_TO_DATE(OrderDate, '%m/%d/%Y');
alter table fact_sales_data
modify OrderDate Date;

UPDATE fact_sales_data 
SET 
    StockDate = STR_TO_DATE(StockDate, '%m/%d/%Y');
alter table fact_sales_data
modify StockDate Date;

-- returns_data
UPDATE returns_data 
SET 
    returndate = STR_TO_DATE(returndate, '%Y-%m-%d');
alter table returns_data
modify ReturnDate Date;
