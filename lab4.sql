--Lab 4
--Database Schema
DROP TABLE IF EXISTS employees;
CREATE TABLE employees (
 employee_id SERIAL PRIMARY KEY,
 first_name VARCHAR(50),
 last_name VARCHAR(50),
 department VARCHAR(50),
 salary NUMERIC(10,2),
 hire_date DATE,
 manager_id INTEGER,
 email VARCHAR(100)
);
DROP TABLE IF EXISTS projects;
CREATE TABLE projects (
 project_id SERIAL PRIMARY KEY,
 project_name VARCHAR(100),
 budget NUMERIC(12,2),
 start_date DATE,
 end_date DATE,
 status VARCHAR(20)
);
DROP TABLE IF EXISTS assignments;
CREATE TABLE assignments (
 assignment_id SERIAL PRIMARY KEY,
 employee_id INTEGER REFERENCES employees(employee_id),
 project_id INTEGER REFERENCES projects(project_id),
 hours_worked NUMERIC(5,1),
 assignment_date DATE
);

-- Insert sample data
INSERT INTO employees (first_name, last_name, department,
salary, hire_date, manager_id, email)
VALUES
('John', 'Smith', 'IT', 75000, '2020-01-15', NULL,
'john.smith@company.com'),
('Sarah', 'Johnson', 'IT', 65000, '2020-03-20', 1,
'sarah.j@company.com'),
('Michael', 'Brown', 'Sales', 55000, '2019-06-10', NULL,
'mbrown@company.com'),
('Emily', 'Davis', 'HR', 60000, '2021-02-01', NULL,
'emily.davis@company.com'),
('Robert', 'Wilson', 'IT', 70000, '2020-08-15', 1, NULL),
('Lisa', 'Anderson', 'Sales', 58000, '2021-05-20', 3,
'lisa.a@company.com');

INSERT INTO projects (project_name, budget, start_date,
end_date, status) VALUES
('Website Redesign', 150000, '2024-01-01', '2024-06-30',
'Active'),
('CRM Implementation', 200000, '2024-02-15', '2024-12-31',
'Active'),
('Marketing Campaign', 80000, '2024-03-01', '2024-05-31',
'Completed'),
('Database Migration', 120000, '2024-01-10', NULL, 'Active');
INSERT INTO assignments (employee_id, project_id,
hours_worked, assignment_date) VALUES
(1, 1, 120.5, '2024-01-15'),
(2, 1, 95.0, '2024-01-20'),
(1, 4, 80.0, '2024-02-01'),
(3, 3, 60.0, '2024-03-05'),
(5, 2, 110.0, '2024-02-20'),
(6, 3, 75.5, '2024-03-10');

--PART 1
--Task 1
--1.1
SELECT first_name || ' ' || last_name AS full_name,department,salary FROM employees;
--1.2
SELECT DISTINCT department FROM employees;
--1.3
SELECT
    project_name,
    budget,
    CASE
        WHEN budget > 150000 THEN 'Large'
        WHEN budget BETWEEN 100000 AND 150000 THEN 'Medium'
        ELSE 'Small'
    END AS budget_category
FROM projects;
--1.4
SELECT first_name || ' ' || last_name AS full_name,
       COALESCE(email,'No email provided') AS email FROM employees;
--PART 2
--Task 2
--2.1
--Task 2.1: Find all employees hired after January 1, 2020.
SELECT * FROM employees  WHERE hire_date>'01.01.2020';
--Task 2.2: Find all employees whose salary is between 60000 and 70000 (use the BETWEEN operator).
SELECT * FROM employees WHERE salary BETWEEN 60000 AND 70000;
--Task 2.3: Find all employees whose last name starts with 'S' or 'J' (use the LIKE operator).
SELECT * FROM employees WHERE last_name LIKE 'S%' OR last_name LIKE 'J%';
--Task 2.4: Find all employees who have a manager (manager_id IS NOT NULL) and work in the IT department.
SELECT * FROM employees WHERE manager_id IS NOT NULL AND  department = 'IT';

--PART 3
--Task 3
--3.1 Employee names in uppercase • Length of their last names • First 3 characters of their email address (use substring)
SELECT
    UPPER(first_name || ' ' || last_name) AS full_name,
    LENGTH(last_name) AS last_name_length,
    SUBSTRING (email FROM 1 FOR 3) AS email_prefix FROM employees;
--3.2 •Annual salary • Monthly salary (rounded to 2 decimal places) • A 10% raise amount (use mathematical operators)
SELECT first_name || ' ' || last_name AS full_name,
       salary*12 AS annual_salary,
       ROUND(salary/12,2) AS monthly_salary,
       salary*0.10 AS raise_amount FROM employees;
--3.3
SELECT
    FORMAT('Project:%s - Budget:$%s - Status : %s' ,project_name,budget,status) AS project_info FROM projects;
--3.4
SELECT first_name || ' ' || last_name AS full_name,
       EXTRACT(YEAR FROM AGE(CURRENT_DATE,hire_date)) AS years_with_company FROM employees;

--PART 4 Aggregate Functions and GROUP BY
-- Task 4
--4.1 Calculate the average salary for each department.
SELECT department,AVG(salary) AS avg_salary FROM employees GROUP BY department;
-- 4.2: Find the total hours worked on each project, including the project name.
SELECT p.project_name,SUM(a.hours_worked) AS total_hours
FROM assignments a
JOIN projects p ON a.project_id = p.project_id
GROUP BY p.project_name;
--4.3: Count the number of employees in each department. Only show departments with more than 1 employee (use HAVING).
SELECT department,COUNT(*) AS employee_count FROM employees
GROUP BY department
HAVING COUNT(*)>1;
-- 4.4: Find the maximum and minimum salary in the company, along with the total payroll (sum of all salaries)
SELECT
    MAX(salary) AS  max_salary,
    MIN(salary) AS min_salary,
    SUM(salary) AS total_payroll FROM employees;

--PART 5  Set Operations
--Task 5
--5.1
(
   SELECT employee_id , first_name || ' ' || last_name AS full_name,salary
   FROM employees WHERE salary>65000
)
UNION
(
    SELECT employee_id, first_name || ' ' || last_name AS full_name,salary
    FROM employees WHERE hire_date > '2020-01-01'

);
--5.2
SELECT employee_id, first_name || ' ' || last_name AS full_name, salary
FROM employees WHERE department = 'IT'
INTERSECT
SELECT employee_id, first_name || ' ' || last_name AS full_name, salary
FROM employees WHERE salary > 65000;
--5.3
SELECT e.* FROM employees e
EXCEPT
SELECT e.* FROM employees e
JOIN assignments a on e.employee_id = a.employee_id;

--PART 6 Subqueries
--Task 6
--6.1
SELECT * FROM employees e
WHERE EXISTS (
    SELECT 1
    FROM assignments a WHERE a.employee_id = e.employee_id);
--6.2
SELECT *
FROM employees
WHERE employee_id IN (
    SELECT a.employee_id
    FROM assignments a
    JOIN projects p ON a.project_id = p.project_id
    WHERE p.status = 'Active'
);
-- 6.3
SELECT * FROM employees
WHERE salary > ANY (
    SELECT salary
    FROM employees
    WHERE department = 'Sales'
);

-- PART 7: Complex Queries
--Task 7
--7.1
SELECT
    e.first_name || ' ' || e.last_name AS full_name,
    e.department,
    AVG(a.hours_worked) AS avg_hours,
    RANK() OVER (PARTITION BY e.department ORDER BY e.salary DESC) AS salary_rank
FROM employees e
LEFT JOIN assignments a ON e.employee_id = a.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name, e.department, e.salary;

--7.2
SELECT
    p.project_name,
    SUM(a.hours_worked) AS total_hours,
    COUNT(DISTINCT a.employee_id) AS num_employees
FROM projects p
JOIN assignments a ON p.project_id = a.project_id
GROUP BY p.project_name
HAVING SUM(a.hours_worked) > 150;

--7.3
SELECT
    e.department,
    COUNT(e.employee_id) AS total_employees,
    AVG(e.salary) AS avg_salary,
    MAX(e.salary) AS highest_salary,
    (SELECT e2.first_name || ' ' || e2.last_name
     FROM employees e2
     WHERE e2.department = e.department
     ORDER BY e2.salary DESC
     LIMIT 1) AS highest_paid_employee,
    GREATEST(MAX(e.salary), MIN(e.salary)) AS greatest_salary_value,
    LEAST(MAX(e.salary), MIN(e.salary)) AS least_salary_value
FROM employees e
GROUP BY e.department;
