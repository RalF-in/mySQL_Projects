# Smartphone Analytics Data Warehouse Project

A MySQL-based smartphone analytics data warehouse designed for efficient querying and deep analysis of mobile device features, brand trends, and performance metrics.

---

## Project Overview

This project converts a flat smartphone dataset into a normalized star schema warehouse, supporting advanced analytical queries on device specifications, brand/model distribution, pricing, ratings, and hardware capabilities. The structure supports device comparisons, trends analysis, and feature-based benchmarks.

---

## Data Model & ER Diagram

Major tables:
- **Fact Table (`fact_table`)**: Quantitative and categorical measures for each smartphone, with foreign keys to dimension tables.
- **Dimension Tables**:
  - `dim_brand` (brand_name)
  - `dim_model` (model_name, brand_id)
  - `dim_processor` (processor_brand, num_cores, processor_speed)
  - `dim_battery` (battery_capacity, fast_charging)
  - `dim_memory` (ram_capacity, internal_memory, extended_memory_available)
  - `dim_display` (screen_size, refresh_rate, resolution)
  - `dim_camera` (num_rear_cameras, camera specs)
  - `dim_os` (os)
- **Original Staging Table**: `smart_phones` for raw data import and normalization.

See the ER diagram:

![ER Diagram](https://github.com/RalF-in/mySQL_Projects/raw/main/Smartphone%20analytics/ER.png)

---

## Setup & ETL Process

1. **Database Initialization**  
   - Create database and use:
     ```
     CREATE DATABASE smartphone_analytics;
     USE smartphone_analytics;
     ```
2. **Table Formation & Data Import**
   - Script: [`dimension_fact_table.sql`](https://github.com/RalF-in/mySQL_Projects/blob/main/Smartphone%20analytics/dimension_fact_table.sql)  
     - Loads `dataset_smartphones.csv`  
     - Creates and populates all dimension tables  
     - Builds normalized `fact_table` with foreign keys and metrics
3. **Data Integrity**
   - Ensures consistent FKs and de-duplicated dimension entries

---

## Analytical Queries

Business and technical analytics are found in:
- [`Queries.sql`](https://github.com/RalF-in/mySQL_Projects/blob/main/Smartphone%20analytics/Queries.sql)

Example analysis includes:
- Average price/rating by brand or processor
- Most common RAM, display type, or camera configurations
- Top devices by battery, speed, rating, or 5G support
- Feature-based device recommendations

---

## Files and Directory Structure

- [`dataset_smartphones.csv`](https://github.com/RalF-in/mySQL_Projects/blob/main/Smartphone%20analytics/dataset_smartphones.csv): Main device data source
- [`dimension_fact_table.sql`](https://github.com/RalF-in/mySQL_Projects/blob/main/Smartphone%20analytics/dimension_fact_table.sql): All table creation and ETL operations
- [`Queries.sql`](https://github.com/RalF-in/mySQL_Projects/blob/main/Smartphone%20analytics/Queries.sql): Research, analytics, and reporting queries
- [`ER.png`](https://github.com/RalF-in/mySQL_Projects/raw/main/Smartphone%20analytics/ER.png): Data model ER diagram

## Usage

- Run ETL scripts to load and normalize data.
- Execute sample and custom queries from the provided scripts.
- Analyze, benchmark, or visualize device features and trends as needed.
