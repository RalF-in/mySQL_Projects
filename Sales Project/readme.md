# Sales Data Warehouse Project

A comprehensive MySQL-based sales analytics project designed to centralize, clean, and analyze business sales data using a robust star schema and powerful analytical queries.

---

## Project Overview

This project provides a feature-rich database for managing and analyzing sales, customer demographics, products, territories, returns, and time dimensions. It supports a variety of business queries including sales KPIs, trends, rankings, and product/category-level insights, making it useful for business decision-making and reporting purposes.
---

## Database Schema

Key tables and relationships used in this project:

- **Fact Tables:**
  - `fact_sales_data`: Main sales transactions with references to products, customers, territories, dates.
  - `returns_data`: Store product return events.
- **Dimension Tables:**
  - `customer_lookup`: Customer demographic attributes.
  - `product`: Product metadata.
  - `product_subcategories`, `product_categories`: Hierarchical product grouping.
  - `calendar`: Date and time breakdown.
  - `territory`: Geographic segmentation.

Refer to the ER diagram below for detailed schema structure:
![ER Diagram](Sales%20Project/ER.png)

---

## Installation & Data Import

1. **Create the Database:**  

2. **Import Data:**  
- Execute the provided `data_import_&_cleanup.sql` script to import and clean all major datasets. You may need to create the table with columns first(could be done by importing from the wizard and then cancel it followed by a truncation)
- Key operations:
  - Import data from: `Customer_Lookup.csv`, `Product.csv`, `Product_Categories.csv`, `Product_Subcategories.csv`, `Returns_Data.csv`, `Territory.csv`.
  - Normalize date columns using `STR_TO_DATE` for each relevant table.
  - Ensure type consistency and integrity with `ALTER TABLE` commands.
- The script safely configures MySQL local file settings and security for importing.

---

## Key Queries & Analytics

All required analytics and reporting needs are addressed in `queries.sql`. Examples include:

| Requirement                                  | SQL Implementation Example                                          |
|-----------------------------------------------|---------------------------------------------------------------------|
| Retrieve all sales records                    | `SELECT * FROM fact_sales_data;`                                    |
| Distinct product names                        | `SELECT DISTINCT ProductName FROM product;`                         |
| Orders on specific dates                      | `SELECT * FROM fact_sales_data WHERE OrderDate = 'YYYY-MM-DD';`     |
| Aggregate totals/revenue by region/category   | Uses `SUM`, `COUNT`, `GROUP BY` across the schema                   |
| Top/bottom-N analysis and rankings            | Window functions like `RANK`, `ROW_NUMBER`, `LAG`                   |
| Repeat customers and return rates             | Customer/product-level summaries and percentages                    |
| Stored procedures for dynamic searches        | By customer, date range, or product category                        |

Refer to the full query codes and advanced analytics in [`queries.sql`](./Sales%20Project/queries.sql).

---

## Usage Instructions

- Ensure local file privileges are set in MySQL (`secure_file_priv`, `local_infile` flags as per script).
- Import all datasets using the cleanup script before querying.
- Run examples and custom analytics queries from `queries.sql`.

---

## Datasets Used

- `Customer_Lookup.csv`
- `Product.csv`
- `Product_Categories.csv`
- `Product_Subcategories.csv`
- `Returns_Data.csv`
- `Territory.csv`

All data is synthetic or anonymized for educational use.