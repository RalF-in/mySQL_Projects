# HR Analytics Data Warehouse Project

A MySQL-based HR analytics warehouse project designed to clean, normalize, and analyze employee data for actionable insights on workforce structure, attrition, pay, and organizational demographics.

---

## Project Overview

This project transforms a flat, redundant HR employee dataset into a star schema-based data warehouse to support advanced querying, analytics, and HR reporting. It supports efficient answers to typical HR questions regarding employee details, roles, compensation, departmental distribution, and attrition using optimized SQL and window functions

---

## Data Model & ER Diagram

The schema includes:
- **Fact Table (`fact_table`)**: Quantitative metrics (income, rate, years at company, attrition, etc.) and foreign keys to all dimension tables
- **Dimension Tables**:
  - `dim_employee` (employee_name, age)
  - `dim_job` (job_role)
  - `dim_department` (department_name)
  - `dim_gender` (gender)
  - `dim_marital_status` (marital_status)

See the ER diagram in this directory for a visual representation:

![ER Diagram](./HR%20analysis/ER.jpg)

---

## Setup & ETL Process

1. **Database Initialization**  
   - Create and select the database:
     ```
     CREATE DATABASE hranalysis;
     USE hranalysis;
     ```
2. **Table Formation & Normalization**  
   - Execute [`table_formation.sql`](./HR%20analysis/table_formation.sql) to:
     - Import flat data from [`Dataset_HR_analysis.csv`](./HR%20analysis/Dataset_HR_analysis.csv)
     - Create all star schema tables (dimensions and fact)
     - Populate dimension tables with unique entries via `INSERT ... SELECT DISTINCT`
     - Remove duplicate data using window functions/row numbers
     - Create and fill the fact table using appropriate foreign keys
3. **Data Integrity**  
   - Foreign key relationships established as per the schema to enforce referential integrity

---

## Analytical Queries

A complete set of business-oriented queries is provided in [`queries.sql`](./HR%20analysis/queries.sql), including:

| Question                                                        | Query Example                                                              |
|-----------------------------------------------------------------|-----------------------------------------------------------------------------|
| Show all employees with job roles                               | Join `dim_employee` and `dim_job` via `fact_table`                          |
| Count number of employees in each department                    | Aggregation on `department_id` in `fact_table`                              |
| List highest and lowest monthly income per department           | Use `MAX`/`MIN` with groupings                                              |
| Rank employees by income within each department                 | Window functions with `RANK()` or `ROW_NUMBER()`                            |
| Get top 3 earners in each department                            | Partitioned ranking window functions                                        |
| List employees with >5 years' total working experience          | Conditional queries on `total_working_years`                                |
| Count employees in labeled age groups                           | `CASE WHEN` logic for banding ages                                          |

Refer to [`queries.sql`](./HR%20analysis/queries.sql) for all SQL solutions and window function usage.

---

## Files and Directory Structure

- [`Dataset_HR_analysis.csv`](./HR%20analysi/Dataset_HR_analysis.csv)
- [`table_formation.sql`](./HR%20analysis/table_formation.sql): Script for table creation, normalization, and loading
- [`queries.sql`](./HR%20analysis/queries.sql): All business, ranking, and analytics queries
- [`ER.jpg`](./HR%20analysis/ER.jpg): Star schema ER diagram
- [`HR-Analytics-Project-Requirements.pdf`](./HR%20analysis/HR-Analytics_Project-Requirements.pdf): Project requirements and design notes

---

## Usage

- Import data via provided scripts after setting up MySQL environment
- Run analytical SQL queries as per requirement
- Extend with your own business questions or visualization tools
