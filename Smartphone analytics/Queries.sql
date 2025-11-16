-- 1. Average Price and Count of Smartphones by Brand.⚡
SELECT 
    b.brand_name,
    ROUND(AVG(price), 2) AS avg_price,
    COUNT(smartphone_id) AS total_smartphone
FROM
    fact_table f
        JOIN
    dim_brand b ON f.brand_id = b.brand_id
GROUP BY brand_name
ORDER BY brand_name;

-- 2. Top 5 Smartphones by Rating & Price.
SELECT 
    f.smartphone_id,
    b.brand_name,
    m.model_name,
    avg_rating,
    price
FROM
    fact_table f
        JOIN
    dim_brand b ON f.brand_id = b.brand_id
        JOIN
    dim_model m ON f.model_id = m.model_id
ORDER BY avg_rating DESC , price DESC
LIMIT 5;

-- 3. Smartphone Price Distribution by Brand and OS.
SELECT 
    brand_name,
    OS,
    AVG(price) AS average_price,
    MIN(price) AS lowest_priced,
    MAX(price) AS highest_priced
FROM
    dim_brand b
        JOIN
    fact_table f ON f.brand_id = b.brand_id
        JOIN
    dim_os o ON f.os_id = o.os_id
GROUP BY brand_name , os
ORDER BY brand_name , os ASC;

-- 4. Count of Smartphones by Brand and Processor Speed ⚡
select brand_name, processor_speed, count(smartphone_id) as total_phones
from dim_brand b join fact_table f on f.brand_id = b.brand_id
				 join dim_processor p on f.processor_id = p.processor_id
group by brand_name, processor_speed
order by brand_name asc, processor_speed asc;

-- 5. Number of Models and Avg Price by RAM Size and Brand.
select brand_name, ram_capacity as ram_size, count(model_id) as total_models, round(avg(price),2) as average_price
from  dim_memory m join fact_table f on f.memory_id = m.memory_id
				   join dim_brand b on f.brand_id = b.brand_id
group by ram_capacity, brand_name
order by brand_name, ram_capacity;

-- 6. Top 3 Fastest Charging Smartphones by Price
select brand_name, model_name, price, fast_charging
from fact_table f join dim_brand b on f.brand_id = b.brand_id
				  join dim_model m on f.model_id = m.model_id
                  join dim_battery bt on f.battery_id = bt.battery_id
order by fast_charging desc, price asc
limit 3;

-- 7. Brand Performance by 5G Availability.
select processor_brand, processor_speed
from dim_processor p join fact_table f on f.processor_id = p.processor_id
where is_5G = 1
order by processor_speed desc;

-- 8. Correlation Between Processor Speed and Price by Brand
select brand_name, processor_speed, round(avg(price), 2) as average_price
from dim_brand d join fact_table f on d.brand_id = f.brand_id
				 join dim_processor p on p.processor_id = f.processor_id
group by brand_name, processor_speed
order by brand_name, processor_speed;

-- 9. Price-to-Performance Ratio by Brand.
with tempo as(
select brand_name, model_name, (processor_speed * num_cores) as performance, price, price / (processor_speed * num_cores) as price_per_performance_unit
from dim_brand b join fact_table f on b.brand_id = f.brand_id
				 join dim_model m on m.model_id = f.model_id
                 join dim_processor p on p.processor_id = f.processor_id
                 )
select brand_name, round(avg(price_per_performance_unit), 2) as average_price_per_performance_unit
from tempo
group by brand_name
order by average_price_per_performance_unit;

-- 10. Most Common Display Features by Brand (screen size, refresh rate, resolution) ⚡
with size as(
select brand_name, screen_size, count(screen_size) as total_screen
from dim_display d join fact_table f on d.display_id = f.display_id
					join dim_brand b on b.brand_id = f.brand_id
group by brand_name, screen_size
),

size_rank as(
select brand_name, screen_size, total_screen, rank() over(partition by brand_name order by total_screen desc) as ranking_size
from size),

size_filter as(
select * from size_rank where ranking_size = 1),
-- ---------------

refresh as(
select brand_name, refresh_rate, count(refresh_rate) as total_refresh
from dim_display d join fact_table f on d.display_id = f.display_id
					join dim_brand b on b.brand_id = f.brand_id
group by brand_name, refresh_rate
),

refresh_rank as(
select brand_name, refresh_rate, total_refresh, rank() over(partition by brand_name order by total_refresh desc) as ranking_refresh
from refresh),

refresh_filter as(
select * from refresh_rank where ranking_refresh = 1),
-- ------------------------


res as(
select brand_name, (resolution_height * resolution_width / 1000000) as resolution, count((resolution_height * resolution_width / 1000000)) as total_res
from dim_display d join fact_table f on d.display_id = f.display_id
					join dim_brand b on b.brand_id = f.brand_id
group by brand_name, resolution
),

res_rank as(
select brand_name, round((resolution),2) as resolution , total_res, rank() over(partition by brand_name order by total_res desc) as ranking_res
from res),

res_filter as(
select * from res_rank where ranking_res = 1)

select s.brand_name, s.screen_size as most_frequent_screen_size, s.total_screen as frequency_count, r.refresh_rate as most_frequent_refresh_rate, r.total_refresh as frequency_count, rr.resolution as most_frequent_resolution, rr.total_res as frequency_count
from size_filter s join size_filter sc on s.brand_name = sc.brand_name
					join refresh_filter r on s.brand_name = r.brand_name
                    join res_filter rr on s.brand_name = rr.brand_name;
                    
-- 11. Multi-Feature Ranking (Composite Score)
-- Let AI do this one
WITH smartphone_features AS (
    SELECT 
        f.smartphone_id,
        b.brand_name,
        m.model_name,
        p.processor_speed,
        p.num_cores,
        mem.ram_capacity,
        bat.battery_capacity,
        bat.fast_charging, 
        f.avg_rating,
        f.is_5G,           
        -- Composite score using numeric 1/0 for fast_charging and is_5G
        (f.avg_rating * 0.4
         + p.processor_speed * 0.3
         + mem.ram_capacity * 0.15
         + bat.battery_capacity / 1000 * 0.1
         + bat.fast_charging * 0.05
         + f.is_5G * 0.05
        ) AS composite_score
    FROM fact_table f
    JOIN dim_brand b ON f.brand_id = b.brand_id
    JOIN dim_model m ON f.model_id = m.model_id
    JOIN dim_processor p ON f.processor_id = p.processor_id
    JOIN dim_memory mem ON f.memory_id = mem.memory_id
    JOIN dim_battery bat ON f.battery_id = bat.battery_id
)
SELECT 
    smartphone_id,
    brand_name,
    model_name,
	round((composite_score), 2) as composite_score,
    RANK() OVER (ORDER BY composite_score DESC) AS ranking
FROM smartphone_features
ORDER BY ranking
LIMIT 10;

-- 12. Average Battery Capacity and Fast-Charging Comparison by OS.
select os, round(avg(battery_capacity)) as average_battery_capacity, round(avg(fast_charging)) as average_fast_charging
from dim_os o join fact_table f on f.os_id = o.os_id
			  join dim_battery b on b.battery_id = f.battery_id
group by os;