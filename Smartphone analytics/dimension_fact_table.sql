create database smartphones;
use smartphones;

-- Dimension Table
delimiter $$
create procedure dim_table()
begin

-- drop table if exists fact_table;
-- dim_brand
drop table if exists Dim_model;
drop table if exists Dim_Brand;
create table Dim_Brand(
		brand_id int auto_increment primary key,
        brand_name varchar(50) unique not null
        );
insert into dim_brand(brand_name)
select distinct brand_name from smart_phones;

-- dim_model
drop table if exists Dim_model;
create table Dim_Model(
		model_id int auto_increment primary key,
        model_name varchar(50) unique not null,
        brand_id int,
        foreign key(brand_id) references dim_brand(brand_id)
        );
insert into dim_model(model_name, brand_id)
select distinct model, brand_id
from smart_phones join dim_brand on dim_brand.brand_name = smart_phones.brand_name;

-- dim_processor
drop table if exists Dim_Processor;
create table Dim_Processor(
		processor_id int auto_increment primary key,
        processor_brand varchar(50) not null,
        num_cores int,
        processor_speed double
        );
insert into Dim_Processor(processor_brand, num_cores, processor_speed)
select distinct processor_brand, num_cores, processor_speed from smart_phones;

-- dim_battery
drop table if exists Dim_Battery;
create table Dim_Battery(
		battery_id int auto_increment primary key,
        battery_capacity int,
        fast_charging_available int,
        fast_charging int
        );
insert into dim_battery(battery_capacity, fast_charging_available, fast_charging)
select distinct battery_capacity, fast_charging_available, fast_charging
from smart_phones;

-- dim_memory
drop table if exists Dim_memory;
create table Dim_Memory(
		memory_id int auto_increment primary key,
        ram_capacity int,
        internal_memory int,
        extended_memory_available int
        );
insert into Dim_Memory(ram_capacity,
        internal_memory,
        extended_memory_available)
select distinct ram_capacity,
        internal_memory,
        extended_memory_available
from smart_phones;

-- dim_display
drop table if exists Dim_Display;
create table dim_display(
		display_id int auto_increment primary key,
        screen_size double,
        refresh_rate int,
        resolution_height int,
        resolution_width int
        );
insert into dim_display(screen_size,
        refresh_rate,
        resolution_height,
        resolution_width)
        
select distinct screen_size,
        refresh_rate,
        resolution_height,
        resolution_width
from smart_phones;

-- dim_camera
drop table if exists Dim_camera;
create table dim_camera(
		camera_id int auto_increment primary key,
        num_rear_cameras int,
        primary_camera_rear int,
        primary_camera_front int
        );
insert into dim_camera(num_rear_cameras,
        primary_camera_rear,
        primary_camera_front)
select distinct num_rear_cameras,
        primary_camera_rear,
        primary_camera_front
from smart_phones;

-- dim_os
drop table if exists dim_os;
create table dim_os(
		os_id int auto_increment primary key,
        os text
        );
insert into dim_os(os)
select distinct os
from smart_phones;

end $$
delimiter ;
call dim_table();


-- Fact Table
delimiter $$
create procedure FactTable() 
begin

drop table if exists fact_table;
create table fact_table(
		smartphone_id int auto_increment primary key,
        brand_id int,
        model_id int,
        processor_id int,
        battery_id int,
        memory_id int,
        display_id int,
        camera_id int,
		os_id int,
		price int,
		avg_rating double,
		is_5G int
        );
        
insert into fact_table(brand_id, model_id, processor_id, battery_id, memory_id, display_id, camera_id, os_id, price, avg_rating, is_5G)
with dup as(
		select brand_name, model, price, avg_rating, is_5G, processor_brand, num_cores, processor_speed, battery_capacity, fast_charging_available, fast_charging, ram_capacity, internal_memory, screen_size, refresh_rate, num_rear_cameras, os, primary_camera_rear, primary_camera_front, extended_memory_available, resolution_height, resolution_width,
        row_number()
        over(partition by brand_name, model, price, avg_rating, is_5G, processor_brand, num_cores, processor_speed, battery_capacity, fast_charging_available, fast_charging, ram_capacity, internal_memory, screen_size, refresh_rate, num_rear_cameras, os, primary_camera_rear, primary_camera_front, extended_memory_available, resolution_height, resolution_width)
        as rn
        from smart_phones
),
filtered as(
		select brand_name, model, price, avg_rating, is_5G, processor_brand, num_cores, processor_speed, battery_capacity, fast_charging_available, fast_charging, ram_capacity, internal_memory, screen_size, refresh_rate, num_rear_cameras, os, primary_camera_rear, primary_camera_front, extended_memory_available, resolution_height, resolution_width
        from dup
        where rn = 1
        )
select  b.brand_id, -- done
        m.model_id, -- done
        p.processor_id, -- done
        bt.battery_id, -- done
        mm.memory_id, -- done
        d.display_id, -- done
        c.camera_id, -- done
		o.os_id,
		fl.price,
		fl.avg_rating,
		fl.is_5G
from filtered fl
				 join dim_brand b on fl.brand_name = b.brand_name
				 join dim_model m on fl.model = m.model_name
                 join dim_processor p on fl.processor_brand = p.processor_brand
						and	fl.num_cores = p.num_cores
						and fl.processor_speed = p.processor_speed
                 join dim_battery bt on fl.battery_capacity = bt.battery_capacity
						and fl.fast_charging_available = bt.fast_charging_available
						and fl.fast_charging = bt.fast_charging
                 join dim_memory mm on fl.ram_capacity = mm.ram_capacity
						and fl.internal_memory = mm.internal_memory
						and fl.extended_memory_available = mm.extended_memory_available
                 join dim_display d on fl.screen_size = d.screen_size
						and fl.refresh_rate = d.refresh_rate
						and fl.resolution_height = d.resolution_height
						and fl.resolution_width = d.resolution_width
                 join dim_camera c on fl.num_rear_cameras = c.num_rear_cameras
						and fl.primary_camera_rear = c.primary_camera_rear
						and fl.primary_camera_front = c.primary_camera_front
                 join dim_os o on fl.os = o.os;

end $$
delimiter ;
call FactTable();
SELECT 
    *
FROM
    fact_table;
