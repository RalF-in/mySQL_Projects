create database hr_analysis;
use hr_analysis;
rename table `hr analysis` to hr_analysis;
SELECT 
    *
FROM
    hr_analysis;

load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/HR analysis.csv"
into table hr_analysis
fields terminated by ','
optionally enclosed by '"'
lines terminated by '\r\n'
ignore 1 lines;

delimiter $$
create procedure dim_table ()
begin

-- dim_employee
drop table if exists Dim_Employee;
create table Dim_Employee(
employee_id int primary key,
employee_name text,
age int);

insert into dim_employee(employee_id, employee_name, age)
select distinct employee_id, employee_name, age
from hr_analysis;

-- dim_job
drop table  if exists dim_job;
create table dim_job(
job_id int primary key auto_increment,
job_role text);

insert into dim_job(job_role)
select distinct jobrole from hr_analysis;

-- dim_department
drop table  if exists dim_department;
create table dim_department(
department_id int auto_increment primary key,
department_name text);

insert into dim_department(department_name)
select distinct Department from hr_analysis;

-- Dim_Gender
drop table  if exists Dim_Gender;
create table Dim_Gender(
gender_id int auto_increment primary key,
gender text);

insert into dim_gender(gender)
select distinct gender from hr_analysis;

-- marital_status
drop table if exists dim_marital_status;
create table dim_marital_status(
status_id int auto_increment primary key,
marital_status varchar(20) unique not null);

insert into dim_marital_status(marital_status)
select distinct maritalstatus from hr_analysis;

end $$
delimiter ;

call dim_table();

delimiter $$
create procedure fact_table() 
begin

drop table if exists fact_table;
create table fact_table(
fact_id int auto_increment primary key,
employee_id int,
job_id int,
department_id int,
gender_id int,
marital_status_id int,
attrition text,
daily_rate int,
hourly_rate int,
monthly_income int,
monthly_rate int,
num_companies_worked int,
percent_salary_hike int,
total_working_years int,
years_at_company int
);

insert into fact_table(employee_id, job_id, department_id, gender_id, marital_status_id,
attrition, daily_rate, hourly_rate, monthly_income, monthly_rate,
num_companies_worked, percent_salary_hike, total_working_years,
years_at_company)

with duplicates as(
select *, row_number() over(partition by employee_Id, Employee_name, Age, Attrition, BusinessTravel, DailyRate, Department, Education, EducationField, Gender, HourlyRate, JobLevel, JobRole, MaritalStatus, MonthlyIncome, MonthlyRate, NumCompaniesWorked, OverTime, PercentSalaryHike, PerformanceRating, StockOptionLevel, TotalWorkingYears, TrainingTimesLastYear, YearsAtCompany, YearsInCurrentRole) as rn
from hr_analysis),
no_dup as(select * from duplicates where rn = 1)

select e.employee_id, j.job_id, d.department_id, g.gender_id, m.status_id, n.attrition, n.dailyrate, n.hourlyrate, n.monthlyincome, n.monthlyrate,
n.numcompaniesworked, n.percentsalaryhike, n.totalworkingyears, n.yearsatcompany
from no_dup n join dim_employee e on n.employee_id = e.employee_id
join dim_job j on n.jobrole = j.job_role
join dim_gender g on n.gender = g.gender
join dim_marital_status m on n.maritalstatus = m.marital_status
join dim_department d on n.department = d.department_name;

end $$
delimiter ;
call fact_table();