-- Lab 5 by
-- Student Name: Zhanabergenova Dilnaz
-- Student ID: 24B031774


-- PART 1
-- Task 1.1:
DROP TABLE IF EXISTS employees CASCADE;
CREATE TABLE IF NOT EXISTS employees (
    employee_id INTEGER,
    first_name TEXT,
    last_name TEXT,
    age INTEGER CHECK (age BETWEEN 18 AND 65),
    salary NUMERIC(12,2) CHECK (salary > 0)
);

INSERT INTO employees (employee_id, first_name, last_name, age, salary) VALUES
(1, 'Zhibek', 'Kuat', 20, 80000.00),
(2, 'Amina', 'Shakirbek', 22, 120000.50);

-- Попытки некорректных вставок (закомментированы):
-- 1) Нарушение ограничения по возрасту (age < 18)
-- INSERT INTO employees VALUES (3, 'Young', 'Kid', 16, 20000.00);

-- 2) Нарушение ограничения зарплаты (salary <= 0)
-- INSERT INTO employees VALUES (4, 'Negative', 'Pay', 35, -1000.00);

-- Task 1.2
DROP TABLE IF EXISTS products_catalog;
CREATE TABLE IF NOT EXISTS products_catalog (
    product_id INTEGER,
    product_name TEXT,
    regular_price NUMERIC(10,2),
    discount_price NUMERIC(10,2),
    CONSTRAINT valid_discount CHECK (
        regular_price > 0 AND
        discount_price > 0 AND
        discount_price < regular_price
    )
);

INSERT INTO products_catalog VALUES
(1, 'Phone X', 350.00, 300.00),
(2, 'Headphones Z', 99.99, 79.99);

-- Некорректные вставки (закомментировано):
-- 1) discount_price >= regular_price
-- INSERT INTO products_catalog VALUES (3, 'BadDeal', 50.00, 60.00);

-- 2) regular_price = 0 (недопустимо)
-- INSERT INTO products_catalog VALUES (4, 'FreeItem', 0.00, 0.00);
-- Описание нарушения: regular_price > 0 и discount_price > 0 не выполнены.


-- Task 1.3
CREATE TABLE IF NOT EXISTS bookings (
    booking_id INTEGER,
    check_in_date DATE,
    check_out_date DATE,
    num_guests INTEGER,
    CHECK (num_guests BETWEEN 1 AND 10),
    CHECK (check_out_date > check_in_date)
);

INSERT INTO bookings VALUES
(1, '2025-10-01', '2025-10-05', 2),
(2, '2025-12-24', '2025-12-26', 4);

-- Некорректные вставки (закомментировано):
-- 1) num_guests вне диапазона
-- INSERT INTO bookings VALUES (3, '2025-11-01', '2025-11-02', 0);
-- 2) check_out_date не после check_in_date
-- INSERT INTO bookings VALUES (4, '2025-11-10', '2025-11-10', 2);


-- PART 2
-- Task 2.1
CREATE TABLE IF NOT EXISTS customers (
    customer_id INTEGER NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    registration_date DATE NOT NULL
);

-- Успешные вставки:
INSERT INTO customers VALUES
(1, 'sila2007', '77011234567', '2024-01-10'),
(2, 'kbtubest@example.kz', NULL, '2024-02-20');

-- Некорректные вставки (закомментировано):
-- 1) NULL в email (NOT NULL)
-- INSERT INTO customers VALUES (3, NULL, '77009876543', '2024-03-01');

-- 2) NULL в registration_date
-- INSERT INTO customers VALUES (4, 'client@example.kz', '77005551234', NULL);

-- Task 2.2
CREATE TABLE IF NOT EXISTS inventory (
    item_id INTEGER NOT NULL,
    item_name TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity >= 0),
    unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price > 0),
    last_updated TIMESTAMP NOT NULL
);
-- Task 2.3
INSERT INTO inventory VALUES
(1, 'Screwdriver', 100, 9.99, '2025-01-01 10:00:00'),
(2, 'Hammer', 50, 15.50, '2025-01-05 11:00:00');

-- Некорректные вставки (закомментировано):
-- 1) NULL в NOT NULL поле item_name
-- INSERT INTO inventory VALUES (3, NULL, 10, 3.00, '2025-01-02 09:00:00');

-- 2) quantity отрицательное
-- INSERT INTO inventory VALUES (4, 'Nails', -10, 0.05, '2025-01-03 09:00:00');

-- 3) unit_price <= 0
-- INSERT INTO inventory VALUES (5, 'Glue', 10, 0.00, '2025-01-04 09:00:00');



-- PART 3
-- Task 3.1
CREATE TABLE IF NOT EXISTS users (
    user_id INTEGER,
    username TEXT,
    email TEXT,
    created_at TIMESTAMP
);

INSERT INTO users VALUES
(1, 'ayan98', 'ayan98@example.com', '2025-01-01 09:00:00'),
(2, 'dina_b', 'dina@example.com', '2025-02-01 10:00:00');

-- Task 3.2
CREATE TABLE IF NOT EXISTS course_enrollments (
    enrollment_id INTEGER,
    student_id INTEGER,
    course_code TEXT,
    semester TEXT,
    UNIQUE (student_id, course_code, semester)
);

INSERT INTO course_enrollments
VALUES (1, 101, 'MATH101', '2025-Fall'),
       (2, 102, 'CS101', '2025-Fall'),
       (3, 101, 'CS101', '2025-Fall');

-- Некорректная вставка:
-- INSERT INTO course_enrollments VALUES (4, 101, 'MATH101', '2025-Fall')
-- --UNIQUE (student_id, course_code, semester) — дублирование комбинации.

-- Task 3.3
CREATE TABLE IF NOT EXISTS users (
    user_id INTEGER,
    username TEXT CONSTRAINT unique_username UNIQUE,
    email TEXT CONSTRAINT unique_email UNIQUE,
    created_at TIMESTAMP
);

INSERT INTO users (user_id, username, email, created_at) VALUES
(1, 'user_1', 'a@example.com', NOW()),
(2, 'user_2', 'b@example.com', NOW());

-- После добавления именованных ограничений, повторные вставки с одинаковыми username/email приведут к ошибке.
-- Примеры некорректных вставок (закомментировано):
-- Повтор username
-- INSERT INTO users VALUES (3, 'user_1', 'c@example.com', now());
-- Повтор email
-- INSERT INTO users VALUES (4, 'dilya', 'b@example.com', now());

-- PART 4
-- Task 4.1
DROP TABLE IF EXISTS departments CASCADE;
CREATE TABLE IF NOT EXISTS departments (
    dept_id INTEGER PRIMARY KEY,
    dept_name TEXT NOT NULL,
    location TEXT
);

INSERT INTO departments VALUES
(1, 'Human Resources', 'Almaty'),
(2, 'IT', 'Almaty'),
(3, 'Finance', 'Nur-Sultan');

-- Некорректные вставки:
-- 1) Дублирование dept_id
-- INSERT INTO departments VALUES (1, 'Marketing', 'Shymkent');

-- 2) NULL в dept_id
-- INSERT INTO departments VALUES (NULL, 'Legal', 'Karaganda');

-- Task 4.2
CREATE TABLE IF NOT EXISTS student_courses (
    student_id INTEGER,
    course_id INTEGER,
    enrollment_date DATE,
    grade TEXT,
    PRIMARY KEY (student_id, course_id)
);

INSERT INTO student_courses VALUES
(201, 301, '2025-02-01', 'A'),
(202, 301, '2025-02-02', 'B');

-- Некорректная вставка: повтор комбинации (student_id, course_id)
-- INSERT INTO student_courses VALUES (201, 301, '2025-03-01', 'A-');



-- Task 4.3
-- 1) The difference between UNIQUE and PRIMARY KEY:
--PRIMARY KEY: uniquely identifies a row, does not allow NULL (in PostgreSQL PK, NOT NULL by default),
-- there can only be one PRIMARY KEY on a table (one composite or single set of columns).
--UNIQUE: guarantees uniqueness of values in one or more columns, allows NULL (NULL is interpreted
-- as an unequal value to other nulls), and there may be several UNIQUE constraints on the table.
--
-- 2) When to use single-column vs composite PRIMARY KEY:
-- - Single-column PK: when each row has a natural or surrogate identifier (e.g. id),
-- convenient for linking and indexing.
--Composite PK: when uniqueness is determined by a combination of columns (e.g. (student_id, course_id) for records
-- about the student's participation in a particular course).

-- 3) Why can a table have only one PRIMARY KEY, but several UNIQUE ones:
-- PRIMARY KEY is conceptually the only main row identifier; UNIQUE can be used for additional
-- limitations of uniqueness (alternative cases) — technically, these are different semantics.


-- PART 5
-- Task 5.1
CREATE TABLE IF NOT EXISTS employees_dept (
    emp_id INTEGER PRIMARY KEY,
    emp_name TEXT NOT NULL,
    dept_id INTEGER REFERENCES departments(dept_id), -- FK -> departments
    hire_date DATE
);

INSERT INTO employees_dept VALUES
(10, 'Inkar', 1, '2023-05-10'),
(11, 'Ali', 2, '2024-07-01');

-- Некорректная вставка: несуществующий dept_id
-- INSERT INTO employees_dept VALUES (12, 'Liza', 99, '2025-01-01');
-- Foreign key constraint — dept_id 99 отсутствует в таблице departments.


-- Task 5.2
CREATE TABLE IF NOT EXISTS authors (
    author_id INTEGER PRIMARY KEY,
    author_name TEXT NOT NULL,
    country TEXT
);

CREATE TABLE IF NOT EXISTS publishers (
    publisher_id INTEGER PRIMARY KEY,
    publisher_name TEXT NOT NULL,
    city TEXT
);

CREATE TABLE IF NOT EXISTS books (
    book_id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    author_id INTEGER REFERENCES authors(author_id),
    publisher_id INTEGER REFERENCES publishers(publisher_id),
    publication_year INTEGER,
    isbn TEXT UNIQUE
);

INSERT INTO authors VALUES
(1, 'Gabriel Garcia Marquez', 'Colombia'),
(2, 'George Orwell', 'United Kingdom'),
(3, 'Chingiz Aitmatov', 'Kyrgyzstan');

INSERT INTO publishers VALUES
(1, 'Penguin Books', 'London'),
(2, 'Vintage', 'New York'),
(3, 'Kazakh Publishing', 'Almaty');

INSERT INTO books VALUES
(1, 'One Hundred Years of Solitude', 1, 1, 1967, '978-0-14-303996-0'),
(2, '1984', 2, 2, 1949, '978-0-452-28423-4'),
(3, 'Jamila', 3, 3, 1966, '978-9961-0-1234-5');

-- INSERT INTO books VALUES (4, 'Duplicate ISBN', 2, 1, 1950, '978-0-452-28423-4');
-- Описание нарушения: isbn UNIQUE.


-- Task 5.3
CREATE TABLE IF NOT EXISTS categories (
    category_id INTEGER PRIMARY KEY,
    category_name TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS products_fk (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category_id INTEGER REFERENCES categories(category_id) ON DELETE RESTRICT
    -- ON DELETE RESTRICT: запрещает удаление категории, если существуют продукты в ней
);

CREATE TABLE IF NOT EXISTS orders_demo (
    order_id INTEGER PRIMARY KEY,
    order_date DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS order_items (
    item_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders_demo(order_id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products_fk(product_id),
    quantity INTEGER CHECK (quantity > 0)
    -- При удалении заказа через ON DELETE CASCADE, связанные записи в order_items будут автоматически удалены
);

INSERT INTO categories VALUES
(1, 'Electronics'),
(2, 'Home');

INSERT INTO products_fk VALUES
(100, 'Smartphone', 1),
(101, 'Vacuum Cleaner', 2);

INSERT INTO orders_demo VALUES
(500, '2025-09-01'),
(501, '2025-09-02');

INSERT INTO order_items VALUES
(1000, 500, 100, 2),
(1001, 500, 101, 1),
(1002, 501, 100, 1);

-- 1) Попытка удалить категорию, у которой есть продукты — должно завершиться ошибкой (RESTRICT)
-- DELETE FROM categories WHERE category_id = 1; -- Ожидаемый результат: ошибка из-за products_fk.product_id с category_id=1
-- Описание: ON DELETE RESTRICT запрещает удаление категории, если существуют связанные продукты.

-- 2) Удалить заказ и увидеть, что order_items удаляются автоматически (CASCADE)
-- DELETE FROM orders_demo WHERE order_id = 500; -- Ожидается: строки с item_id 1000 и 1001 удалятся
-- Затем: SELECT * FROM order_items WHERE order_id = 500;


-- PART 6

CREATE TABLE IF NOT EXISTS ecommerce_customers (
    customer_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT,
    registration_date DATE NOT NULL
);


CREATE TABLE IF NOT EXISTS ecommerce_products (
    product_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC(12,2) NOT NULL CHECK (price >= 0), -- цена неотрицательная
    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0)
);

CREATE TABLE IF NOT EXISTS ecommerce_orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER REFERENCES ecommerce_customers(customer_id) ON DELETE RESTRICT,
    order_date DATE NOT NULL,
    total_amount NUMERIC(12,2) NOT NULL CHECK (total_amount >= 0),
    status TEXT NOT NULL CHECK (status IN ('pending','processing','shipped','delivered','cancelled'))
    -- ON DELETE RESTRICT для customer: запрещаем удалять клиента с существующими заказами
);


CREATE TABLE IF NOT EXISTS ecommerce_order_details (
    order_detail_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES ecommerce_orders(order_id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES ecommerce_products(product_id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(12,2) NOT NULL CHECK (unit_price >= 0)
    -- При удалении заказа детали удаляются (CASCADE). Удаление товара запрещено, если он присутствует в order_details (RESTRICT).
);


INSERT INTO ecommerce_customers VALUES
(1, 'Aigerim S.', 'aigerim.shop@example.kz', '77011230001', '2024-03-10'),
(2, 'Nurlan A.', 'nurlan.shop@example.kz', '77011230002', '2024-04-12'),
(3, 'Gulnar T.', 'gulnar@example.kz', NULL, '2024-05-01'),
(4, 'Dmitry P.', 'dmitry@example.kz', '77011230004', '2024-06-20'),
(5, 'Sara K.', 'sara@example.kz', '77011230005', '2024-07-15');


INSERT INTO ecommerce_products VALUES
(10, 'UltraPhone', 'Flagship phone', 799.99, 25),
(11, 'PowerBank', '10000mAh', 29.99, 150),
(12, 'Wireless Earbuds', 'Noise cancelling', 129.99, 60),
(13, 'Laptop Sleeve 15"', 'Water resistant', 24.50, 200),
(14, 'USB-C Cable', '1m nylon', 7.99, 500);


INSERT INTO ecommerce_orders VALUES
(9001, 1, '2025-09-20', 859.98, 'pending'),
(9002, 2, '2025-09-21', 29.99, 'processing'),
(9003, 1, '2025-09-22', 129.99, 'shipped'),
(9004, 3, '2025-09-23', 32.49, 'delivered'),
(9005, 4, '2025-09-24', 799.99, 'cancelled');


INSERT INTO ecommerce_order_details VALUES
(1, 9001, 10, 1, 799.99), -- UltraPhone
(2, 9001, 14, 3, 7.99),   -- USB-C Cable x3
(3, 9002, 11, 1, 29.99),  -- PowerBank
(4, 9003, 12, 1, 129.99), -- Earbuds
(5, 9004, 14, 4, 7.99);   -- USB-C Cable x4

-- Проверочные (некорректные) вставки для демонстрации работы ограничений (закомментированы):
-- 1) Положительная проверка цены
-- INSERT INTO ecommerce_products VALUES (15, 'BadPrice', 'Invalid', -5.00, 10);
-- Описание нарушения: CHECK (price >= 0) — отрицательная цена не допускается.

-- 2) Невозможный статус заказа
-- INSERT INTO ecommerce_orders VALUES (9006, 5, '2025-09-25', 10.00, 'unknown');
-- Описание нарушения: CHECK (status IN (...)) — статус должен быть одним из разрешённых.

-- 3) quantity <= 0 в деталях заказа
-- INSERT INTO ecommerce_order_details VALUES (6, 9001, 11, 0, 29.99);
-- Описание нарушения: CHECK (quantity > 0) — количество должно быть положительным.

-- 4) Попытка вставить клиента с дублирующим email
-- INSERT INTO ecommerce_customers VALUES (6, 'Clone', 'aigerim.shop@example.kz', '77000000000', '2025-01-01');
-- Описание нарушения: UNIQUE (email) — email должен быть уникален.

-- 5) Попытка удалить клиента, у которого есть заказы (ON DELETE RESTRICT)
-- DELETE FROM ecommerce_customers WHERE customer_id = 1; -- Ожидается: ошибка, т.к. для customer_id=1 есть заказы

-- 6) Удаление заказа и проверка CASCADE (order_details должны удалиться автоматически)
-- -- предположим, выполняем:
-- DELETE FROM ecommerce_orders WHERE order_id = 9002; -- удалит заказ 9002
-- SELECT * FROM ecommerce_order_details WHERE order_id = 9002; -- ожидается: 0 строк

-- 7) Попытка удалить товар, который используется в order_details (ON DELETE RESTRICT)
-- DELETE FROM ecommerce_products WHERE product_id = 10; -- Ожидается: ошибка, т.к. товар присутствует в order_details

-- Дополнительные тестовые запросы:
-- SELECT * FROM employees;
-- SELECT * FROM products_catalog;
-- SELECT * FROM bookings;
-- SELECT * FROM customers;
-- SELECT * FROM inventory;
-- SELECT * FROM users;
-- SELECT * FROM course_enrollments;
-- SELECT * FROM departments;
-- SELECT * FROM student_courses;
-- SELECT * FROM employees_dept;
-- SELECT * FROM authors;
-- SELECT * FROM publishers;
-- SELECT * FROM books;
-- SELECT * FROM categories;
-- SELECT * FROM products_fk;
-- SELECT * FROM orders_demo;
-- SELECT * FROM order_items;
-- SELECT * FROM ecommerce_customers;
-- SELECT * FROM ecommerce_products;
-- SELECT * FROM ecommerce_orders;
-- SELECT * FROM ecommerce_order_details;