--Part 1
--Task 1.1
DROP DATABASE IF EXISTS university_main;

CREATE DATABASE university_main
    TEMPLATE = template0
    ENCODING = 'UTF8';
ALTER DATABASE university_main OWNER TO CURRENT_USER;


--Part 1: Multiple Database Management
--Task 1.1: Database Creation with Parameters

DROP DATABASE IF EXISTS university_main;
CREATE DATABASE university_main
    WITH OWNER = postgres
         TEMPLATE = template0
         ENCODING = 'UTF8';

DROP DATABASE IF EXISTS university_archive;
CREATE DATABASE university_archive
    WITH TEMPLATE = template0
         CONNECTION LIMIT = 50;

-- Drop if it already exists
DROP DATABASE IF EXISTS university_test;
CREATE DATABASE university_test
    WITH TEMPLATE = template0
         CONNECTION LIMIT = 10;

ALTER DATABASE university_test WITH IS_TEMPLATE = true;




--Task 1.2: Tablespace Operations
-- Удаляем, если пусты (если не пусты — см. пункт C)
DROP TABLESPACE IF EXISTS student_data;
DROP TABLESPACE IF EXISTS course_data;

CREATE TABLESPACE student_data LOCATION 'C:/PostgresData/students';
CREATE TABLESPACE course_data  LOCATION 'C:/PostgresData/courses';

-- Выполняем  будучи подключенными к postgres

DROP  DATABASE IF EXISTS  university_distributed;
CREATE DATABASE university_distributed
  WITH TEMPLATE = template0
       TABLESPACE = student_data
       ENCODING = 'LATIN9'
       LC_COLLATE = 'C'
       LC_CTYPE   = 'C';

--Part 2: Complex Table Creation
--Task 2.1: University Management System

--\c university_main;
DROP TABLE IF EXISTS  students;
CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    phone CHAR(15),
    date_of_birth DATE,
    enrollment_date DATE,
    gpa NUMERIC(4,2),
    is_active BOOLEAN,
    graduation_year SMALLINT
);
DROP TABLE IF EXISTS professors;
CREATE TABLE professors (
    professor_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    office_number VARCHAR(20),
    hire_date DATE,
    salary NUMERIC(12,2),
    is_tenured BOOLEAN,
    years_experience INTEGER
);
DROP TABLE IF EXISTS courses ;
CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    course_code CHAR(8),
    course_title VARCHAR(100),
    description TEXT,
    credits SMALLINT,
    max_enrollment INTEGER,
    course_fee NUMERIC(10,2),
    is_online BOOLEAN,
    created_at TIMESTAMP WITHOUT TIME ZONE
);

--Task 2.2: Time-based and Specialized Tables

--\c university_main;
DROP TABLE IF EXISTS class_schedule ;
CREATE TABLE class_schedule (
    schedule_id   SERIAL PRIMARY KEY,
    course_id     INTEGER,
    professor_id  INTEGER,
    classroom     VARCHAR(20),
    class_date    DATE,
    start_time    TIME WITHOUT TIME ZONE,
    end_time      TIME WITHOUT TIME ZONE,
    duration      INTERVAL
);

DROP TABLE IF EXISTS student_records ;
CREATE TABLE student_records (
    record_id              SERIAL PRIMARY KEY,
    student_id             INTEGER,
    course_id              INTEGER,
    semester               VARCHAR(20),
    year                   INTEGER,
    grade                  CHAR(2),
    attendance_percentage  NUMERIC(4,1),
    submission_timestamp   TIMESTAMPTZ,
    last_updated           TIMESTAMPTZ
);

--Part 3: Advanced ALTER TABLE Operations
--Task 3.1: Modifying Existing Tables

-- --- students ---
ALTER TABLE students
  ADD COLUMN middle_name VARCHAR(30);

ALTER TABLE students
  ADD COLUMN student_status VARCHAR(20);

ALTER TABLE students
  ALTER COLUMN phone TYPE VARCHAR(20);

ALTER TABLE students
  ALTER COLUMN student_status SET DEFAULT 'ACTIVE';

ALTER TABLE students
  ALTER COLUMN gpa SET DEFAULT 0.00;

-- --- professors ---
ALTER TABLE professors
  ADD COLUMN department_code CHAR(5);

ALTER TABLE professors
  ADD COLUMN research_area TEXT;

ALTER TABLE professors
  ALTER COLUMN years_experience TYPE SMALLINT
  USING years_experience::SMALLINT;

ALTER TABLE professors
  ALTER COLUMN is_tenured SET DEFAULT FALSE;

ALTER TABLE professors
  ADD COLUMN last_promotion_date DATE;

-- --- courses ---
ALTER TABLE courses
  ADD COLUMN prerequisite_course_id INTEGER;

ALTER TABLE courses
  ADD COLUMN difficulty_level SMALLINT;

ALTER TABLE courses
  ALTER COLUMN course_code TYPE VARCHAR(10);

ALTER TABLE courses
  ALTER COLUMN credits SET DEFAULT 3;

ALTER TABLE courses
  ADD COLUMN lab_required BOOLEAN DEFAULT FALSE;

-- Task 3.2: Column Management Operations

-- --- class_schedule ---
ALTER TABLE class_schedule
  ADD COLUMN room_capacity INTEGER;

ALTER TABLE class_schedule DROP COLUMN IF EXISTS duration;

ALTER TABLE class_schedule
  ADD COLUMN session_type VARCHAR(15);

ALTER TABLE class_schedule
  ALTER COLUMN classroom TYPE VARCHAR(30);

ALTER TABLE class_schedule
  ADD COLUMN equipment_needed TEXT;

-- --- student_records ---
ALTER TABLE student_records
  ADD COLUMN extra_credit_points NUMERIC(3,1);

ALTER TABLE student_records
  ALTER COLUMN grade TYPE VARCHAR(5);

ALTER TABLE student_records
  ALTER COLUMN extra_credit_points SET DEFAULT 0.0;

ALTER TABLE student_records
  ADD COLUMN final_exam_date DATE;

ALTER TABLE student_records
  DROP COLUMN last_updated;

--Part 4: Table Relationships and Management
-- Task 4.1: Additional Supporting Tables
DROP TABLE IF EXISTS  departments;
CREATE TABLE departments (
    department_id     SERIAL PRIMARY KEY,
    department_name   VARCHAR(100),
    department_code   CHAR(5),
    building          VARCHAR(50),
    phone             VARCHAR(15),
    budget            NUMERIC(14,2),
    established_year  INTEGER
);
DROP TABLE IF EXISTS  library_books;
CREATE TABLE library_books (
    book_id              SERIAL PRIMARY KEY,
    isbn                 CHAR(13),
    title                VARCHAR(200),
    author               VARCHAR(100),
    publisher            VARCHAR(100),
    publication_date     DATE,
    price                NUMERIC(10,2),
    is_available         BOOLEAN,
    acquisition_timestamp TIMESTAMP WITHOUT TIME ZONE
);
DROP TABLE IF EXISTS student_book_loans ;
CREATE TABLE student_book_loans (
    loan_id      SERIAL PRIMARY KEY,
    student_id   INTEGER,
    book_id      INTEGER,
    loan_date    DATE,
    due_date     DATE,
    return_date  DATE,
    fine_amount  NUMERIC(10,2),
    loan_status  VARCHAR(20)
);

---- Task 4.2: Integration

ALTER TABLE professors ADD COLUMN department_id INTEGER;
ALTER TABLE students   ADD COLUMN advisor_id INTEGER;
ALTER TABLE courses    ADD COLUMN department_id INTEGER;

DROP TABLE IF EXISTS grade_scale;
CREATE TABLE grade_scale (
    grade_id       SERIAL PRIMARY KEY,
    letter_grade   CHAR(2),
    min_percentage NUMERIC(4,1),
    max_percentage NUMERIC(4,1),
    gpa_points     NUMERIC(4,2)
);
DROP  TABLE IF EXISTS  semester_calendar;
CREATE TABLE semester_calendar (
    semester_id           SERIAL PRIMARY KEY,
    semester_name         VARCHAR(20),
    academic_year         INTEGER,
    start_date            DATE,
    end_date              DATE,
    registration_deadline TIMESTAMPTZ,
    is_current            BOOLEAN
);

--Part 5: Table Deletion and Cleanup
--Task 5.1: Conditional Table Operations

DROP TABLE IF EXISTS student_book_loans;
DROP TABLE IF EXISTS library_books;
DROP TABLE IF EXISTS grade_scale;

CREATE TABLE grade_scale (
    grade_id       SERIAL PRIMARY KEY,
    letter_grade   CHAR(2),
    min_percentage NUMERIC(4,1),
    max_percentage NUMERIC(4,1),
    gpa_points     NUMERIC(4,2),
    description    TEXT
);

DROP TABLE IF EXISTS semester_calendar CASCADE;

CREATE TABLE semester_calendar (
    semester_id           SERIAL PRIMARY KEY,
    semester_name         VARCHAR(20),
    academic_year         INTEGER,
    start_date            DATE,
    end_date              DATE,
    registration_deadline TIMESTAMPTZ,
    is_current            BOOLEAN
);
-- Task 5.2: Database Cleanup
-- Удаляем university_test даже если она помечена как template

--\c postgres;

-- Снимем template-флаг только если БД существует
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_database WHERE datname = 'university_test') THEN
    EXECUTE 'ALTER DATABASE university_test WITH IS_TEMPLATE = false';
  END IF;
END $$;

SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'university_test'
  AND pid <> pg_backend_pid();

DROP DATABASE IF EXISTS university_test;

-- Завершаем подключения и удаляем distributed
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'university_distributed'
  AND pid <> pg_backend_pid();

DROP DATABASE IF EXISTS university_distributed;

-- Удаляем старую backup
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'university_backup'
  AND pid <> pg_backend_pid();

DROP DATABASE IF EXISTS university_backup;
-----

CREATE DATABASE university_backup TEMPLATE university_main;






