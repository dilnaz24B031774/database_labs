--Lab 6

--PART 1

--1.1
CREATE TABLE employees(
  emp_id INT PRIMARY KEY,
  emp_name VARCHAR(50),
  dept_id INT,
  salary DECIMAL(10,2)
);

DROP TABLE IF EXISTS departments CASCADE;
CREATE TABLE departments(
  dept_id INT PRIMARY KEY,
  dept_name VARCHAR(50),
  location VARCHAR(50)
);
DROP TABLE IF EXISTS projects CASCADE;
CREATE  TABLE projects(
  project_id INT PRIMARY KEY,
  project_name VARCHAR(50),
  dept_id INT,
  budget DECIMAL(10,2)
);

--1.2 Insert Sample Data
INSERT INTO employees(emp_id,emp_name,dept_id,salary)
VALUES
(1,'John Smith',101,50000),
(2,'Jane Doe',102,60000),
(3,'Mike Johnson',101,55000),
(4,'Sarah Williams',103,65000),
(5,'Tom Brown',NULL,45000);

INSERT INTO departments(dept_id,dept_name,location)
VALUES
(101,'IT','Building A'),
(102,'HR','Building B'),
(103,'Finance','Building C'),
(104,'Marketing','Building D');

INSERT INTO projects (project_id, project_name, dept_id, budget)
VALUES
(1,'Website Redesign',101,100000),
(2,'Employee Training',102,50000),
(3,'Budget Analysis',103,75000),
(4,'Cloud Migration',101,150000),
(5,'AI Research',NULL,200000);

--PART 2 CROSS JOIN

--2.1
SELECT e.emp_name ,d.dept_name
FROM employees e CROSS JOIN departments d;
--2.2
--A
SELECT e.emp_name ,d.dept_name FROM employees e,departments d;
--B
SELECT e.emp_name ,d.dept_name FROM employees e INNER JOIN  departments d ON TRUE;
--2.3
SELECT e.emp_id ,e.emp_name,p.project_id,p.project_name FROM employees e CROSS JOIN projects p ORDER BY e.emp_id,p.project_id;

--PART 3 INNER JOIN
--3.1
SELECT e.emp_name,d.dept_name,d.location FROM employees e INNER JOIN departments d ON e.dept_id = d.dept_id;
--3.2
SELECT e.emp_name,d.dept_name,d.location FROM employees e INNER JOIN departments d USING (dept_id);
--3.3
SELECT e.emp_name,d.dept_name,d.location FROM employees e NATURAL INNER JOIN departments d;
--3.4
SELECT e.emp_name,d.dept_name,p.project_name FROM employees e INNER JOIN departments d ON e.dept_id = d.dept_id
INNER JOIN projects p ON d.dept_id = p.dept_id;

--PART 4 LEFT JOIN
--4.1
SELECT e.emp_name,e.dept_id AS emp_dept ,d.dept_id AS dept_dept ,d.dept_name FROM employees e LEFT JOIN departments d
ON e.dept_id = d.dept_id;
--ANSWER:Tom Brown's row returns null because there's no matched dept_name for him
--4.2
SELECT emp_name,dept_id,dept_name FROM employees LEFT JOIN departments USING(dept_id);
--4.3
SELECT e.emp_name,e.dept_id FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id WHERE d.dept_id IS NULL;
--4.4
SELECT d.dept_name,COUNT(e.emp_id) AS employee_count FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id,d.dept_name ORDER BY employee_count DESC;

--PART 5 RIGHT JOIN

--5.1
SELECT e.emp_name,d.dept_name FROM employees e RIGHT JOIN departments d ON e.dept_id = d.dept_id;
--5.2
SELECT e.emp_name,d.dept_name FROM employees e LEFT JOIN departments d ON e.dept_id = d.dept_id;
--5.3
SELECT d.dept_name,d.location FROM employees e  RIGHT JOIN departments d ON e.dept_id = d.dept_id WHERE e.emp_id IS NUlL;

--PART 6 FULL JOIN

--6.1
SELECT d.dept_name,p.project_name,p.budget FROM departments d FULL JOIN projects p ON d.dept_id=p.dept_id;

--6.2
SELECT d.dept_name,p.project_name,p.budget FROM departments d FULL JOIN projects p ON  d.dept_id  = p.dept_id;
--6.3