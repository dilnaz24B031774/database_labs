--LAB 10
--Practical tasks (Part 3)
--Student:Zhanabergenova Dilnaz
--3.1
CREATE TABLE accounts (
id SERIAL PRIMARY KEY,
name VARCHAR(100) NOT NULL,
balance DECIMAL(10, 2) DEFAULT 0.00
);
DROP TABLE IF EXISTS products CASCADE;
CREATE TABLE products (
id SERIAL PRIMARY KEY,
shop VARCHAR(100) NOT NULL,
product VARCHAR(100) NOT NULL,
price DECIMAL(10, 2) NOT NULL
);
-- Insert test data
INSERT INTO accounts (name, balance) VALUES
('Alice', 1000.00),
('Bob', 500.00),
('Wally', 750.00);

INSERT INTO products (shop, product, price) VALUES
('Joe''s Shop', 'Coke', 2.50),
('Joe''s Shop', 'Pepsi', 3.00);

--3.2 Basic Transaction with COMMIT
--task 1
BEGIN;
UPDATE accounts SET balance = balance - 100.00
WHERE name = 'Alice';
UPDATE accounts SET balance = balance + 100.00
WHERE name = 'Bob';
COMMIT;

--Answers:
--a)Final balances:Alice: 900.00 Bob: 600.00
--b)Both updates must be atomic—money should not disappear.
--c) Alice’s deduction would occur but Bob would not be credited -> inconsistent state.

--3.3 Task 2:Using Rollback
BEGIN;
UPDATE accounts SET balance = balance - 500.00
WHERE name = 'Alice';
SELECT * FROM accounts WHERE name = 'Alice';
-- Oops! Wrong amount, let's undo
ROLLBACK;
SELECT * FROM accounts WHERE name = 'Alice';

--Answers
--a) After update: 500.00
--b) After rollback: 1000.00
--c) Use ROLLBACK when wrong values or incorrect operations are done.


--3.4  Task 3:Working with SAVEPOINTs
BEGIN;
UPDATE accounts SET balance = balance - 100.00
WHERE name = 'Alice';
SAVEPOINT my_savepoint;
UPDATE accounts SET balance = balance + 100.00
WHERE name = 'Bob';
-- Oops, should transfer to Wally instead
ROLLBACK TO my_savepoint;
UPDATE accounts SET balance = balance + 100.00
WHERE name = 'Wally';
COMMIT;

--Answers
--a) Final balances:Alice: 900.00 Bob: 500.00 Wally: 850.00
--b) Bob’s credit was undone due to SAVEPOINT rollback.
--c) SAVEPOINT allows partial rollback instead of restarting a transaction.


--3.5 Task 4:Isolation Levels Demonstration
--Terminal 1:
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT * FROM products WHERE shop = 'Joe''s Shop';
SELECT * FROM products WHERE shop = 'Joe''s Shop';
COMMIT;

--Terminal 2 (while Terminal 1 is still running):
BEGIN;
DELETE FROM products WHERE shop = 'Joe''s Shop';
INSERT INTO products VALUES (DEFAULT, 'Joe''s Shop', 'Fanta', 3.50);
COMMIT;

--Scenario B: SERIALIZABLE
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;

--Answers
--a)Before: Coke, Pepsi After: Fanta
--b)Terminal 1 does not see changes; may even get serialization failure.
--c)READ COMMITTED allows fresh committed data.SERIALIZABLE forces stable snapshot, preventing conflicts.


--3.6 Task 5: Phantom Read Demonstration
--Terminal 1:
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT MAX(price), MIN(price) FROM products
WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2
SELECT MAX(price), MIN(price) FROM products
WHERE shop = 'Joe''s Shop';
COMMIT;
--Terminal 2:
BEGIN;
INSERT INTO products (shop, product, price)
VALUES ('Joe''s Shop', 'Sprite', 4.00);
COMMIT;

--Answers
--a) Terminal 1 does not see Sprite.
--b) Phantom read = new rows appear.
--c) SERIALIZABLE prevents phantom reads.

--3.7 Task 6: Dirty Read Demonstration
--Terminal 1:
BEGIN TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT * FROM products WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2 to UPDATE but NOT commit
SELECT * FROM products WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2 to ROLLBACK
SELECT * FROM products WHERE shop = 'Joe''s Shop';
COMMIT;
--Terminal 2:
BEGIN;
UPDATE products SET price = 99.99
WHERE product = 'Fanta';
-- Wait here (don't commit yet)
-- Then:
ROLLBACK;

--Answers
--a) Yes, Terminal 1 sees uncommitted price 99.99.
--b) Dirty read = reading uncommitted data.
--c) READ UNCOMMITTED should not be used in real applications.

--Part 4. Independent Exercises
--exercise 1:Transfer $200 from Bob to Wally (only if enough funds)
DO $$
DECLARE
    bob_balance DECIMAL(10,2);
BEGIN
    SELECT balance INTO bob_balance
    FROM accounts WHERE name = 'Bob';

    IF bob_balance >= 200 THEN
        BEGIN
            UPDATE accounts SET balance = balance - 200 WHERE name = 'Bob';
            UPDATE accounts SET balance = balance + 200 WHERE name = 'Wally';
            COMMIT;
            RAISE NOTICE 'Transfer successful.';
        EXCEPTION WHEN OTHERS THEN
            ROLLBACK;
            RAISE NOTICE 'Error — transaction rolled back.';
        END;
    ELSE
        RAISE NOTICE 'Insufficient funds.';
    END IF;
END $$;

--exercise 2:Transaction with Multiple Savepoints
BEGIN;
INSERT INTO products (shop, product, price)
VALUES ('Joe''s Shop', 'Water', 1.50);
SAVEPOINT sp1;

UPDATE products SET price = 2.00
WHERE product = 'Water';

SAVEPOINT sp2;

DELETE FROM products WHERE product = 'Water';

ROLLBACK TO sp1;

COMMIT;

--exercise 3:Two Users Withdrawing Simultaneously
-- TERMINAL 1:
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
UPDATE accounts SET balance = balance - 300 WHERE name='Alice';
COMMIT;

-- TERMINAL 2:
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
UPDATE accounts SET balance = balance - 300 WHERE name='Alice';
COMMIT;
-- Under SERIALIZABLE, second transaction would fail.

--exercise 4:
--Demonstrate MAX < MIN problem without transactions
-- BAD SESSION 1:
SELECT MAX(price) FROM products WHERE shop='Joe''s Shop';
-- Meanwhile SESSION 2 deletes rows
-- BAD RESULT: MAX < MIN possible
-- GOOD (WITH TRANSACTION):
BEGIN;
SELECT MAX(price), MIN(price) FROM products WHERE shop='Joe''s Shop';
COMMIT;

--5. Answers to Self-Assessment Questions
--1)Atomicity — all or nothing.
--Consistency — constraints preserved.
--Isolation — no interference.
--Durability — committed data survives crash.
--2)COMMIT saves changes; ROLLBACK undoes them.
--3)SAVEPOINT is used when only part of a transaction needs to be undone.
--4)SERIALIZABLE > REPEATABLE READ > READ COMMITTED > READ UNCOMMITTED.
--5)Dirty read = reading uncommitted data; allowed in READ UNCOMMITTED.
--6)Non-repeatable read = same row returns different values between SELECTs.
--7)Phantom read = new rows appear; prevented only by SERIALIZABLE.
--8)READ COMMITTED is faster and suitable for high-load systems.
--9)Transactions maintain consistency by grouping operations.
--10)Uncommitted changes are lost.


