--LAB 7 tasks
--By Dilnaz Zhanabergenova (24B031774)
--PART 1
--already done
--PART 2

--2.1
CREATE VIEW employee_details AS
SELECT e.emp_name,e.salary,d.dept_name,d.location
FROM employees  e JOIN departments d ON e.dept_id = d.dept_id
WHERE e.dept_id IS NOT NULL;
--Check
SELECT * FROM employee_details;

--2.2
CREATE VIEW dept_statistics AS
SELECT d.dept_name,
       COUNT(e.emp_id) AS employee_count,
       COALESCE(AVG(e.salary),0) AS average_salary,
       COALESCE(MAX(e.salary),0) AS max_salary,
       COALESCE(MIN(e.salary),0) AS min_salary
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_name;

SELECT * FROM dept_statistics
ORDER BY employee_count DESC;

--2.3
CREATE VIEW project_overview AS
SELECT p.project_name,p.budget,d.dept_name,d.location,COUNT(e.emp_id) AS team_size
FROM projects p JOIN departments d ON p.dept_id = d.dept_id
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY p.project_name,p.budget,d.dept_name,d.location;

--2.4
CREATE VIEW high_earners AS
SELECT e.emp_name,e.salary,d.dept_name FROM employees e
JOIN departments d ON e.dept_id = d.dept_id WHERE e.salary>55000;

SELECT * FROM high_earners;

--PART 3:Modifying and Managing Views
--3.1
CREATE OR REPLACE VIEW employee_details AS
SELECT e.emp_name,e.salary,d.dept_name,d.location,
CASE
    WHEN e.salary>60000 THEN 'High'
    WHEN e.salary>50000 THEN 'Medium'
    ELSE 'Standard'
END AS salary_grade FROM employees e JOIN departments d ON e.emp_id = d.dept_id;

--3.2
ALTER VIEW high_earners RENAME TO top_performers;
SELECT * FROM top_performers;

--3.3
CREATE VIEW temp_view AS SELECT * FROM employees
WHERE salary<50000;

DROP VIEW temp_view;

--PART 4:Updatable Views

--4.1
CREATE VIEW employee_salaries AS SELECT emp_id,emp_name,dept_id,salary FROM employees;

--4.2
UPDATE employee_salaries SET salary = 52000 WHERE emp_name = 'John Smith';
--Check
SELECT * FROM employees WHERE emp_name = 'John Smith';

--4.3
INSERT INTO employee_salaries (emp_id,emp_name,dept_id,salary)
VALUES (6,'Alice Johnson',102,58000);
--Check
SELECT * FROM employees WHERE emp_name = 'Alice Johnson';

--4.4
CREATE VIEW it_employees AS
SELECT * FROM employees WHERE dept_id = 101 WITH LOCAL CHECK OPTION ;
INSERT INTO it_employees (emp_id, emp_name, dept_id, salary)
VALUES(7,'Bob Wilson',103,60000);

--the check option guarantees the view stays consistent with its filter condition -you cannot update or insert rows that would 'fall outside'

--PART 5 :Materialized Views

--5.1
CREATE MATERIALIZED VIEW dept_summary_mv AS
SELECT d.dept_id,
       d.dept_name,
       COUNT(e.emp_id) AS total_employees,
       COALESCE(SUM(e.salary),0) AS  total_salaries,
       COUNT(DISTINCT p.project_id) AS total_projects,
       COALESCE(SUM(p.budget),0) AS total_project_budget
FROM departments d LEFT JOIN employees e ON d.dept_id = e.dept_id
LEFT JOIN projects p ON d.dept_id = e.emp_id
GROUP BY d.dept_id,d.dept_name WITH DATA;
--Check
SELECT * FROM dept_summary_mv ORDER BY total_employees DESC;

--5.2
INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES(8,'Charlie Brown',101,54000);
--Before refresh
SELECT * FROM dept_summary_mv;
--After refresh
REFRESH MATERIALIZED VIEW  dept_summary_mv ;
SELECT * FROM dept_summary_mv;

--5.3
CREATE UNIQUE INDEX ON dept_summary_mv (dept_id);
REFRESH MATERIALIZED VIEW CONCURRENTLY dept_summary_mv;

--5.4
CREATE MATERIALIZED VIEW project_status_mv AS
SELECT p.project_name,p.budget,d.dept_name,COUNT(e.emp_id) AS employee_count
FROM projects p
LEFT JOIN departments d ON p.dept_id = d.dept_id
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY p.project_name,p.budget,d.dept_name WITH NO DATA;

--Check
SELECT * FROM project_status_mv;
--Refresh
REFRESH MATERIALIZED VIEW  project_status_mv ;

--PART 6:Create Basic Roles

--6.1
CREATE ROLE analyst;
CREATE ROLE data_viewer LOGIN PASSWORD 'viewer123';
CREATE ROLE report_user LOGIN PASSWORD 'report456';

--View all roles
SELECT rolname FROM pg_roles WHERE rolname NOT LIKE 'pg_%';

--6.2
CREATE ROLE db_creator LOGIN PASSWORD 'creator789' CREATEDB;
CREATE ROLE user_manager LOGIN PASSWORD 'manager101' CREATEROLE;
CREATE ROLE admin_user LOGIN PASSWORD 'admin999' SUPERUSER;

--6.3:Grant Privileges
GRANT SELECT ON employees,departments,projects TO analyst;
GRANT ALL PRIVILEGES ON  employee_details TO data_viewer;
GRANT SELECT,INSERT ON employees TO report_user;

--6.4:Create Group Roles
--1
CREATE ROLE hr_team;
CREATE ROLE finance_team;
CREATE ROLE it_team;
--2
CREATE ROLE hr_user1 LOGIN PASSWORD 'hr001';
CREATE ROLE hr_user2 LOGIN PASSWORD 'hr002';
CREATE ROLE finance_user1 LOGIN PASSWORD 'fin001';
--3
GRANT hr_team TO hr_user1,hr_user2;
--4
GRANT finance_team TO  finance_user1;
--5
GRANT SELECT,INSERT ON employees TO hr_team;
--6
GRANT SELECT ON dept_statistics TO finance_team;

--6.5 Revoke Privileges
REVOKE UPDATE ON employees FROM hr_team;
REVOKE hr_team FROM hr_user2;
REVOKE ALL PRIVILEGES ON employee_details FROM data_viewer;

--6.6
ALTER ROLE analyst LOGIN PASSWORD 'analyst123';
ALTER ROLE user_manager SUPERUSER;
ALTER ROLE analyst PASSWORD NULL;
ALTER ROLE data_viewer CONNECTION LIMIT 5;

--PART 7
--7.1
CREATE ROLE read_only;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO read_only;

CREATE ROLE junior_analyst LOGIN PASSWORD 'junior123';
CREATE ROLE senior_analyst LOGIN PASSWORD 'senior123';

GRANT read_only TO junior_analyst, senior_analyst;
GRANT INSERT, UPDATE ON employees TO senior_analyst;

--7.2
CREATE ROLE project_manager LOGIN PASSWORD 'pm123';

ALTER VIEW dept_statistics OWNER TO project_manager;
ALTER TABLE projects OWNER TO project_manager;

SELECT tablename, tableowner
FROM pg_tables
WHERE schemaname = 'public';

--7.3
CREATE ROLE temp_owner LOGIN;
CREATE TABLE temp_table (id INT);

ALTER TABLE temp_table OWNER TO temp_owner;
REASSIGN OWNED BY temp_owner TO postgres;
DROP OWNED BY temp_owner;
DROP ROLE temp_owner;

--7.4
CREATE VIEW hr_employee_view AS
SELECT * FROM employees WHERE dept_id = 102;
GRANT SELECT ON hr_employee_view TO hr_team;

CREATE VIEW finance_employee_view AS
SELECT emp_id, emp_name, salary FROM employees;
GRANT SELECT ON finance_employee_view TO finance_team;

--PART 8

--8.1
CREATE VIEW dept_dashboard AS
SELECT d.dept_name,
       d.location,
       COUNT(e.emp_id) AS employee_count,
       ROUND(AVG(e.salary), 2) AS avg_salary,
       COUNT(DISTINCT p.project_id) AS active_projects,
       COALESCE(SUM(p.budget), 0) AS total_project_budget,
       ROUND(
           COALESCE(SUM(p.budget), 0) /
           NULLIF(COUNT(e.emp_id), 0),
           2
       ) AS budget_per_employee
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
LEFT JOIN projects p ON d.dept_id = p.dept_id
GROUP BY d.dept_name, d.location;

--8.2
ALTER TABLE projects
ADD COLUMN created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

CREATE VIEW high_budget_projects AS
SELECT p.project_name,
       p.budget,
       d.dept_name,
       p.created_date,
       CASE
           WHEN p.budget > 150000 THEN 'Critical Review Required'
           WHEN p.budget > 100000 THEN 'Management Approval Needed'
           ELSE 'Standard Process'
       END AS approval_status
FROM projects p
JOIN departments d ON p.dept_id = d.dept_id;

--8.3
-- Level 1
CREATE ROLE viewer_role;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO viewer_role;

-- Level 2
CREATE ROLE entry_role;
GRANT viewer_role TO entry_role;
GRANT INSERT ON employees, projects TO entry_role;

-- Level 3
CREATE ROLE analyst_role;
GRANT entry_role TO analyst_role;
GRANT UPDATE ON employees, projects TO analyst_role;

-- Level 4
CREATE ROLE manager_role;
GRANT analyst_role TO manager_role;
GRANT DELETE ON employees, projects TO manager_role;

-- Users
CREATE ROLE alice LOGIN PASSWORD 'alice123';
CREATE ROLE bob LOGIN PASSWORD 'bob123';
CREATE ROLE charlie LOGIN PASSWORD 'charlie123';

GRANT viewer_role TO alice;
GRANT analyst_role TO bob;
GRANT manager_role TO charlie;
