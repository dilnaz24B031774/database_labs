--Laboratory Work 8 by Dilnaz
-- PART 1
-- Create tables
CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location VARCHAR(50)
);

CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100),
    dept_id INT,
    salary DECIMAL(10,2),
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

CREATE TABLE projects (
    proj_id INT PRIMARY KEY,
    proj_name VARCHAR(100),
    budget DECIMAL(12,2),
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

-- Insert sample data
INSERT INTO departments VALUES
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Operations', 'Building C');

INSERT INTO employees VALUES
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 101, 55000),
(3, 'Mike Johnson', 102, 48000),
(4, 'Sarah Williams', 102, 52000),
(5, 'Tom Brown', 103, 60000);

INSERT INTO projects VALUES
(201, 'Website Redesign', 75000, 101),
(202, 'Database Migration', 120000, 101),
(203, 'HR System Upgrade', 50000, 102);


-- PART 2: BASIC INDEXES
-- 2.1 Simple index
CREATE INDEX emp_salary_idx ON employees(salary);

-- Check indexes
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees';

-- 2.2 Index on foreign key
CREATE INDEX emp_dept_idx ON employees(dept_id);

SELECT * FROM employees WHERE dept_id = 101;

-- 2.3 View index info
SELECT tablename, indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- PART 3: MULTICOLUMN INDEXES

-- 3.1 Multicolumn index
CREATE INDEX emp_dept_salary_idx ON employees(dept_id, salary);

SELECT emp_name, salary
FROM employees
WHERE dept_id = 101 AND salary > 52000;

-- 3.2 Column order reversed
CREATE INDEX emp_salary_dept_idx ON employees(salary, dept_id);

SELECT * FROM employees WHERE dept_id = 102 AND salary > 50000;
SELECT * FROM employees WHERE salary > 50000 AND dept_id = 102;

-- PART 4: UNIQUE INDEXES
ALTER TABLE employees ADD COLUMN email VARCHAR(100);

UPDATE employees SET email = 'john.smith@company.com' WHERE emp_id = 1;
UPDATE employees SET email = 'jane.doe@company.com' WHERE emp_id = 2;
UPDATE employees SET email = 'mike.johnson@company.com' WHERE emp_id = 3;
UPDATE employees SET email = 'sarah.williams@company.com' WHERE emp_id = 4;
UPDATE employees SET email = 'tom.brown@company.com' WHERE emp_id = 5;

-- Unique index
CREATE UNIQUE INDEX emp_email_unique_idx ON employees(email);

-- Should fail:
-- INSERT INTO employees VALUES (6, 'New Employee', 101, 55000, 'john.smith@company.com');

-- Unique constraint creates index:
ALTER TABLE employees ADD COLUMN phone VARCHAR(20) UNIQUE;

SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees' AND indexname LIKE '%phone%';

-- PART 5: INDEXES AND SORTING
-- DESC sort index
CREATE INDEX emp_salary_desc_idx ON employees(salary DESC);

SELECT emp_name, salary
FROM employees
ORDER BY salary DESC;

-- NULLS FIRST index
CREATE INDEX proj_budget_nulls_first_idx ON projects(budget NULLS FIRST);

SELECT project_name, budget FROM projects
ORDER BY budget NULLS FIRST;

-- PART 6: EXPRESSION INDEXES

-- 6.1 Function index
CREATE INDEX emp_name_lower_idx ON employees(LOWER(emp_name));

SELECT * FROM employees WHERE LOWER(emp_name) = 'john smith';

-- 6.2 Calculated index
ALTER TABLE employees ADD COLUMN hire_date DATE;

UPDATE employees SET hire_date = '2020-01-15' WHERE emp_id = 1;
UPDATE employees SET hire_date = '2019-06-20' WHERE emp_id = 2;
UPDATE employees SET hire_date = '2021-03-10' WHERE emp_id = 3;
UPDATE employees SET hire_date = '2020-11-05' WHERE emp_id = 4;
UPDATE employees SET hire_date = '2018-08-25' WHERE emp_id = 5;

CREATE INDEX emp_hire_year_idx ON employees(EXTRACT(YEAR FROM hire_date));

SELECT emp_name, hire_date
FROM employees
WHERE EXTRACT(YEAR FROM hire_date) = 2020;


-- PART 7: MANAGING INDEXES
-- Rename index
ALTER INDEX emp_salary_idx RENAME TO employees_salary_index;

SELECT indexname FROM pg_indexes WHERE tablename = 'employees';

-- Drop unused index
DROP INDEX emp_salary_dept_idx;

-- Reindex
REINDEX INDEX employees_salary_index;

-- PART 8: PRACTICAL SCENARIOS
-- 8.1 Optimize frequent query
CREATE INDEX emp_salary_filter_idx ON employees(salary) WHERE salary > 50000;

-- JOIN index already exists: emp_dept_idx
-- ORDER BY index exists: emp_salary_desc_idx

-- 8.2 Partial index
CREATE INDEX proj_high_budget_idx ON projects(budget)
WHERE budget > 80000;

SELECT project_name, budget
FROM projects
WHERE budget > 80000;

-- 8.3 Analyze index usage
EXPLAIN SELECT * FROM employees WHERE salary > 52000;

-- PART 9: INDEX TYPE COMPARISON
 -- Hash index
CREATE INDEX dept_name_hash_idx ON departments USING HASH (dept_name);

SELECT * FROM departments WHERE dept_name = 'IT';

-- B-tree vs Hash on project name
CREATE INDEX project_name_btree_idx ON projects(project_name);
CREATE INDEX project_name_hash_idx ON projects USING HASH (project_name);

SELECT * FROM projects WHERE project_name = 'Website Redesign';
SELECT * FROM projects WHERE project_name > 'Database';

-- PART 10: CLEANUP
-- Show index sizes
SELECT
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexname::regclass)) AS index_size
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- Drop unnecessary indexes
DROP INDEX IF EXISTS proj_name_hash_idx;

-- Documentation view
CREATE VIEW index_documentation AS
SELECT
    tablename,
    indexname,
    indexdef,
    'Improves salary-based queries' AS purpose
FROM pg_indexes
WHERE schemaname = 'public'
  AND indexname LIKE '%salary%';


SELECT * FROM index_documentation;
