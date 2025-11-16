-- 1. All employees with their job roles.
SELECT 
    e.employee_name, j.job_role
FROM
    dim_employee e
        JOIN
    fact_table f ON e.employee_id = f.employee_id
        JOIN
    dim_job j ON f.job_id = j.job_id;

-- 2. All employees with their job role and department.
SELECT 
    e.employee_name, j.job_role, d.department_name
FROM
    dim_employee e
        JOIN
    fact_table f ON e.employee_id = f.employee_id
        JOIN
    dim_job j ON f.job_id = j.job_id
        JOIN
    dim_department d ON f.department_id = d.department_id;

-- 3. Count number of employees in each department.
SELECT 
    d.department_name, COUNT(employee_id) AS number_of_employees
FROM
    dim_department d
        JOIN
    fact_table f ON d.department_id = f.department_id
GROUP BY department_name;

-- 4. Count employees per department using CTE.
with temp as(
select d.department_name, f.employee_id
from dim_department d join fact_table f on d.department_id = f.department_id
)
select department_name, count(*) as emp from temp
group by department_name;

-- 5. Highest and lowest monthly income per department.
SELECT 
    d.department_name,
    MAX(monthly_income) AS highest_paid,
    MIN(monthly_income) AS lowest_paid
FROM
    dim_department d
        JOIN
    fact_table f ON d.department_id = f.department_id
GROUP BY department_name;

-- 6. Top 5 employees with highest monthly income.
SELECT 
    e.employee_name, monthly_rate
FROM
    dim_employee e
        JOIN
    fact_table f ON e.employee_id = f.employee_id
ORDER BY monthly_rate DESC
LIMIT 5;

-- 7. Average monthly income by department.
SELECT 
    d.department_name,
    ROUND(AVG(monthly_rate), 2) AS average_salary
FROM
    dim_department d
        JOIN
    fact_table f ON d.department_id = f.department_id
GROUP BY department_name;

-- 8. Employees who have more than 5 years of total working experience.
SELECT 
    e.employee_name, f.total_working_years
FROM
    dim_employee e
        JOIN
    fact_table f ON e.employee_id = f.employee_id
WHERE
    total_working_years > 5
ORDER BY total_working_years;

-- 9. All employees with monthly income > 10000 using CTE.
with joined as(
select employee_name, monthly_rate
from dim_employee e join fact_table f on e.employee_id = f.employee_id
)

select * from joined
where monthly_rate > 1000
order by monthly_rate;

-- 10. Rank employees by monthly income within each department.
select department_name, employee_name, monthly_rate, rank() over(partition by department_name order by monthly_rate desc) as ranking
from dim_department d join fact_table f on d.department_id = f.department_id
join dim_employee e on f.employee_id = e.employee_id;

-- 11. Top 3 earners in each department using rank.
with temp as(
select department_name, employee_name, monthly_rate, rank() over(partition by department_name order by monthly_rate desc) as ranking
from dim_department d join fact_table f on d.department_id = f.department_id
join dim_employee e on f.employee_id = e.employee_id
)

select * from temp where ranking in (1, 2, 3);

-- 12. Top 3 earners in each department.
with temp as(
select department_name, employee_name, monthly_rate, row_number() over(partition by department_name order by monthly_rate desc) as ranking
from dim_department d join fact_table f on d.department_id = f.department_id
join dim_employee e on f.employee_id = e.employee_id
)
select * from temp where ranking in (1, 2, 3)
order by department_name, monthly_rate desc;

-- 13. Total and average monthly income by job role.
SELECT 
    job_role,
    SUM(monthly_rate) AS total,
    ROUND(AVG(monthly_rate), 2) AS average
FROM
    dim_job j
        JOIN
    fact_table f ON j.job_id = f.job_id
GROUP BY job_role;

-- 14. Count employees in each labeled age group
SELECT 
    CASE
        WHEN age < 30 THEN 'junior'
        WHEN age BETWEEN 30 AND 40 THEN 'senior'
        WHEN age > 30 THEN 'most_experienced'
    END AS post,
    COUNT(employee_id) AS total_employees
FROM
    dim_employee
GROUP BY post;