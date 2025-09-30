--Lab 3 exercises
--Part A: Database and Table Setup

-- 1
CREATE DATABASE advanced_lab;

DROP TABLE IF EXISTS employees ;
CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(50),
    salary INTEGER,
    hire_date DATE,
    status VARCHAR(20) DEFAULT 'Active'
);

DROP TABLE IF EXISTS departments;
CREATE TABLE departments (
  dept_id SERIAL PRIMARY KEY,
  dept_name VARCHAR(50),
  budget INTEGER,
  manager_id INTEGER
);

DROP TABLE IF EXISTS projects;
CREATE TABLE projects(
  project_id SERIAL PRIMARY KEY,
  project_name VARCHAR(100) NOT NULL,
  dept_id INTEGER,
  start_date DATE,
  end_date DATE,
  budget INTEGER
 --CONSTRAINT fk_dept FOREIGN_KEY (dept_id) REFERENCES departments(dept_id)
);


--Part B: Advanced INSERT Operations

--2 INSERT with column specification
INSERT INTO employees (emp_id, first_name, last_name, department)
VALUES(1,'Dilnaz','Zhanabergenova','IT');

--3. INSERT with DEFAULT values
ALTER TABLE employees
ALTER COLUMN salary SET DEFAULT 0;

INSERT INTO employees(first_name, last_name, department, salary, status)
VALUES('Aikorkem','Zholaman','Finance',DEFAULT,DEFAULT);

--4 INSERT multiple rows in single statement
INSERT INTO departments(dept_name, budget, manager_id)
VALUES(
  ('IT', 200000, 1),
  ('Finance', 150000, 2),
  ('Sales', 180000, 3)
);
-- 5. INSERT with expressions
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Alice', 'Brown', 'Sales', 50000 * 1.1, CURRENT_DATE);

--6 INSERT from SELECT (subquery)
DROP TABLE IF EXISTS temp_employees;
CREATE TEMP TABLE temp_employees AS
SELECT*FROM employees WHERE department = 'IT';

--Part C

--7. UPDATE with arithmetic expressions
UPDATE employees SET salary = salary * 1.10 WHERE department = 'IT';

--8. UPDATE with WHERE clause and multiple conditions
UPDATE employees SET status = 'Senior' WHERE salary>60000 AND hire_date < '2020-01-01';
--9. UPDATE using CASE expression
UPDATE employees
SET department = CASE
    WHEN salary>80000 THEN 'MANAGEMENT'
    WHEN salary BETWEEN 50000 and 80000 THEN 'Senior'
    ELSE 'Junior'
END WHERE salary IS NOT NULL;
--10.UPDATE with DEFAULT
UPDATE employees SET department = DEFAULT WHERE status = 'Inactive';
-- 11. UPDATE with subquery
UPDATE departments d
SET budget = (
    SELECT AVG(salary) * 1.20
    FROM employees e
    WHERE e.department = d.dept_name
)
WHERE EXISTS (
    SELECT 1
    FROM employees e
    WHERE e.department = d.dept_name
);

-- 12. UPDATE multiple columns
UPDATE employees
SET salary = salary * 1.15,
    status = 'Promoted'
WHERE department = 'Sales';

--Part D
--13.Delete  with simple WHERE condition
DELETE FROM employees WHERE status = 'Terminated';
--14.DELETE with complex WHERE clause
DELETE FROM employees WHERE salary<40000 AND  hire_date>'2023-01-01' AND department IS NULL;
--15 DELETE with subquery
DELETE FROM departments
WHERE dept_id NOT IN (
    SELECT DISTINCT department::INT
    FROM employees
    WHERE department IS NOT NULL
);
--16. DELETE with RETURNING clause
--Delete	all	projects	where	end_date	<	‘2023-01-01’	and	return	all	deleted	data.
DELETE FROM projects WHERE end_date < '2023-01-01' RETURNING *;

--Part E

--17 INSERT with NULL values
INSERT INTO employees(first_name, last_name, department, salary)
VALUES('Zhannur','Yeleusizova','NULL',NULL);
--18 UPDATE NULL handling
UPDATE employees SET department = 'Unassigned' WHERE department IS NULL;
--19 . DELETE with NULL conditions
DELETE FROM employees WHERE salary IS NULL OR department IS NULL;

--Part F

--20.INSERT with RETURNING
--Insert	new	employee	and	return	the	auto-generated	emp_id	and	full	name	(concatenated).
INSERT INTO employees(first_name, last_name,department)
VALUES('Kylian','Mbappe','footballer')
RETURNING emp_id,first_name || ' ' || last_name AS full_name;
--21 UPDATE with RETURNING
UPDATE employees SET salary = salary + 5000 WHERE department = 'IT'
RETURNING emp_id,salary-5000 AS old_salary ,salary AS new_salary;
--22. DELETE with RETURNING all columns
--Delete	employees	where	hire_date	<	‘2020-01-01’	and	return	all	columns	of	deleted	rows
DELETE FROM employees WHERE hire_date <'2020-01-01'
RETURNING *;

--Part G
--23.Conditional INSERT
--Write	INSERT	that	only	adds	employee	if	no	employee	with	same	first_name	and	last_name
INSERT INTO employees(first_name,last_name,department)
SELECT 'Unique','Person','IT'
WHERE NOT EXISTS(SELECT  1 FROM employees WHERE first_name = 'Unique' AND last_name = 'Person');


--24 UPDATE with JOIN logic using subqueries
--Update	employee	salaries	based	on	department	budget:	if	department	budget	>	100000,
UPDATE employees e
SET salary = salary * CASE
    WHEN d.budget > 100000 THEN 1.10
    ELSE 1.05
END
FROM departments d
WHERE e.department = d.dept_name;
--25 Bulk operations
--Insert	5	employees	in	single	statement,	then	update	all	their	salaries	to	be	10%	higher	in
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES
  ('Aiganym', 'Bakhyt', 'Sales', 40000, CURRENT_DATE),
  ('Ernur', 'Elhanov', 'Sales', 42000, CURRENT_DATE),
  ('Zhibek', 'Kuat', 'Sales', 43000, CURRENT_DATE),
  ('Ayazhan', 'Shormanova', 'Sales', 44000, CURRENT_DATE),
  ('Aldiyar', 'Zhaksylyk', 'Sales', 45000, CURRENT_DATE);

UPDATE employees
SET salary = salary * 1.10
WHERE last_name = 'Test';
--26 Data migration simulation
CREATE TABLE employee_archive AS TABLE employees WITH NO DATA;
INSERT INTO employee_archive SELECT * FROM employees WHERE status = 'Inactive';
DELETE FROM employees WHERE status = 'Inactive';
--27 . Complex business logic
UPDATE projects SET end_date = end_date + INTERVAL '30 days'
WHERE budget > 50000 AND dept_id IN (
    SELECT d.dept_id
    FROM departments d
    JOIN employees e ON e.department = d.dept_name
    GROUP BY d.dept_id
    HAVING COUNT(e.emp_id) > 3
);
