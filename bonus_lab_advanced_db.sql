--Bonus lab tasks
-- Student:Zhanabergenova Dilnaz-24B031774-Practice:10:00-11:00
-- KazFinance Bank - Advanced Transaction System

-- Clean up existing objects
DROP MATERIALIZED VIEW IF EXISTS salary_batch_summary CASCADE;
DROP VIEW IF EXISTS suspicious_activity_view CASCADE;
DROP VIEW IF EXISTS daily_transaction_report CASCADE;
DROP VIEW IF EXISTS customer_balance_summary CASCADE;
DROP TABLE IF EXISTS audit_log CASCADE;
DROP TABLE IF EXISTS transactions CASCADE;
DROP TABLE IF EXISTS exchange_rates CASCADE;
DROP TABLE IF EXISTS accounts CASCADE;
DROP TABLE IF EXISTS customers CASCADE;

--DATABASE SCHEMA CREATION

-- Customers table with enhanced validation
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    iin VARCHAR(12) UNIQUE NOT NULL CHECK (iin ~ '^[0-9]{12}$'),
    full_name VARCHAR(200) NOT NULL,
    phone VARCHAR(20) NOT NULL CHECK (phone ~ '^\+?[0-9]{10,15}$'),
    email VARCHAR(150) UNIQUE NOT NULL,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'blocked', 'frozen')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    daily_limit_kzt NUMERIC(15,2) DEFAULT 10000000.00 CHECK (daily_limit_kzt > 0)
);

-- Accounts table with IBAN format support
CREATE TABLE accounts (
    account_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(customer_id) ON DELETE RESTRICT,
    account_number VARCHAR(34) UNIQUE NOT NULL CHECK (account_number ~ '^KZ[0-9]{2}[A-Z0-9]+$'),
    currency VARCHAR(3) NOT NULL CHECK (currency IN ('KZT', 'USD', 'EUR', 'RUB')),
    balance NUMERIC(18,2) DEFAULT 0.00 CHECK (balance >= 0),
    is_active BOOLEAN DEFAULT TRUE,
    opened_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    closed_at TIMESTAMP
);

-- Transactions table with comprehensive tracking
CREATE TABLE transactions (
    transaction_id SERIAL PRIMARY KEY,
    from_account_id INTEGER REFERENCES accounts(account_id),
    to_account_id INTEGER REFERENCES accounts(account_id),
    amount NUMERIC(18,2) NOT NULL CHECK (amount > 0),
    currency VARCHAR(3) NOT NULL,
    exchange_rate NUMERIC(10,6) DEFAULT 1.000000,
    amount_kzt NUMERIC(18,2) NOT NULL,
    type VARCHAR(20) NOT NULL CHECK (type IN ('transfer', 'deposit', 'withdrawal')),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed', 'reversed')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    description TEXT
);

-- Exchange rates table with temporal validity
CREATE TABLE exchange_rates (
    rate_id SERIAL PRIMARY KEY,
    from_currency VARCHAR(3) NOT NULL CHECK (from_currency IN ('KZT', 'USD', 'EUR', 'RUB')),
    to_currency VARCHAR(3) NOT NULL CHECK (to_currency IN ('KZT', 'USD', 'EUR', 'RUB')),
    rate NUMERIC(10,6) NOT NULL CHECK (rate > 0),
    valid_from TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valid_to TIMESTAMP DEFAULT '2099-12-31 23:59:59',
    UNIQUE(from_currency, to_currency, valid_from)
);

-- Audit log table with JSONB for flexible data storage
CREATE TABLE audit_log (
    log_id BIGSERIAL PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL,
    record_id INTEGER NOT NULL,
    action VARCHAR(20) NOT NULL CHECK (action IN ('INSERT', 'UPDATE', 'DELETE')),
    old_values JSONB,
    new_values JSONB,
    changed_by VARCHAR(100) DEFAULT CURRENT_USER,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address INET
);

-- SAMPLE DATA POPULATION

-- Insert customers with realistic Kazakh data
--Data about customers taken from Internet
INSERT INTO customers (iin, full_name, phone, email, status, daily_limit_kzt) VALUES
('950815401234', 'Жанабергенова Динара Булековна', '+77782660857', 'dinara.zh@gmail.com', 'active', 15000000.00),
('880523502145', 'Сарсенова Айгуль Канатовна', '+77023456789', 'aigul.sars@mail.ru', 'active', 8000000.00),
('920310603256', 'Оспанов Тимур Болатұлы', '+77034567890', 'timur.o@inbox.kz', 'active', 12000000.00),
('870925704367', 'Кадырова Айнур Серікқызы', '+77045678901', 'ainur.kad@yandex.kz', 'blocked', 5000000.00),
('990208805478', 'Касымов Алмас Болатович', '+77056789012', 'almas.kas@gmail.com', 'active', 20000000.00),
('931117906589', 'Ибрагимова Даяна Нурлановна', '+77067890123', 'dayana.ibr@mail.kz', 'active', 10000000.00),
('850630107690', 'Токтаров Ерлан Маратович', '+77078901234', 'erlan.tokt@inbox.ru', 'frozen', 6000000.00),
('960404208701', 'Айтжанова Мадина Асановна', '+77089012345', 'madina.ait@gmail.com', 'active', 18000000.00),
('890719309812', 'Сагындыков Арман Женисович', '+77090123456', 'arman.sag@yandex.com', 'active', 9000000.00),
('970822410923', 'Нуралиева Айым Куандыковна', '+77001234567', 'aiym.nur@mail.ru', 'active', 11000000.00),
('860505511034', 'Бекжанов Данияр Болатович', '+77012345679', 'daniyar.bek@inbox.kz', 'active', 14000000.00),
('940213612145', 'Сыздыкова Камила Нұрланқызы', '+77023456780', 'kamila.syzdyk@gmail.com', 'active', 7000000.00);

-- Insert accounts with IBAN format
INSERT INTO accounts (customer_id, account_number, currency, balance, is_active) VALUES
(1, 'KZ86125KZT0000004567', 'KZT', 5420000.00, TRUE),
(1, 'KZ12125USD0000004568', 'USD', 8500.00, TRUE),
(2, 'KZ34567KZT0000008901', 'KZT', 2340000.00, TRUE),
(3, 'KZ56789KZT0000012345', 'KZT', 9870000.00, TRUE),
(3, 'KZ78901EUR0000012346', 'EUR', 15200.00, TRUE),
(4, 'KZ90123KZT0000016789', 'KZT', 450000.00, TRUE),
(5, 'KZ11234KZT0000020123', 'KZT', 18500000.00, TRUE),
(5, 'KZ22345USD0000020124', 'USD', 42000.00, TRUE),
(6, 'KZ33456KZT0000024567', 'KZT', 3200000.00, TRUE),
(7, 'KZ44567KZT0000028901', 'KZT', 1800000.00, TRUE),
(8, 'KZ55678KZT0000032345', 'KZT', 7600000.00, TRUE),
(8, 'KZ66789RUB0000032346', 'RUB', 350000.00, TRUE),
(9, 'KZ77890KZT0000036789', 'KZT', 4100000.00, TRUE),
(10, 'KZ88901KZT0000040123', 'KZT', 5900000.00, TRUE),
(11, 'KZ99012KZT0000044567', 'KZT', 12300000.00, TRUE),
(12, 'KZ10123KZT0000048901', 'KZT', 2750000.00, TRUE);

-- Insert exchange rates (current market rates for Kazakhstan)
INSERT INTO exchange_rates (from_currency, to_currency, rate, valid_from) VALUES
('USD', 'KZT', 470.50, '2024-12-01 00:00:00'),
('KZT', 'USD', 0.002125, '2024-12-01 00:00:00'),
('EUR', 'KZT', 515.75, '2024-12-01 00:00:00'),
('KZT', 'EUR', 0.001939, '2024-12-01 00:00:00'),
('RUB', 'KZT', 4.85, '2024-12-01 00:00:00'),
('KZT', 'RUB', 0.206186, '2024-12-01 00:00:00'),
('USD', 'EUR', 0.912, '2024-12-01 00:00:00'),
('EUR', 'USD', 1.096, '2024-12-01 00:00:00'),
('USD', 'RUB', 97.00, '2024-12-01 00:00:00'),
('RUB', 'USD', 0.010309, '2024-12-01 00:00:00'),
('EUR', 'RUB', 106.35, '2024-12-01 00:00:00'),
('RUB', 'EUR', 0.009403, '2024-12-01 00:00:00');

-- Insert sample transactions for testing
INSERT INTO transactions (from_account_id, to_account_id, amount, currency, exchange_rate, amount_kzt, type, status, completed_at, description) VALUES
(1, 3, 250000.00, 'KZT', 1.000000, 250000.00, 'transfer', 'completed', CURRENT_TIMESTAMP - INTERVAL '2 days', 'Оплата за услуги'),
(4, 9, 450000.00, 'KZT', 1.000000, 450000.00, 'transfer', 'completed', CURRENT_TIMESTAMP - INTERVAL '1 day', 'Перевод родственнику'),
(7, 11, 1200000.00, 'KZT', 1.000000, 1200000.00, 'transfer', 'completed', CURRENT_TIMESTAMP - INTERVAL '5 hours', 'Оплата по договору'),
(2, 6, 3500.00, 'USD', 470.50, 1646750.00, 'transfer', 'completed', CURRENT_TIMESTAMP - INTERVAL '3 hours', 'International payment'),
(5, 1, 5000.00, 'EUR', 515.75, 2578750.00, 'transfer', 'completed', CURRENT_TIMESTAMP - INTERVAL '1 hour', 'Business transfer'),
(NULL, 1, 500000.00, 'KZT', 1.000000, 500000.00, 'deposit', 'completed', CURRENT_TIMESTAMP - INTERVAL '6 days', 'Пополнение счета'),
(NULL, 7, 800000.00, 'KZT', 1.000000, 800000.00, 'deposit', 'completed', CURRENT_TIMESTAMP - INTERVAL '4 days', 'Депозит'),
(9, NULL, 150000.00, 'KZT', 1.000000, 150000.00, 'withdrawal', 'completed', CURRENT_TIMESTAMP - INTERVAL '12 hours', 'Снятие наличных'),
(11, 14, 3200000.00, 'KZT', 1.000000, 3200000.00, 'transfer', 'completed', CURRENT_TIMESTAMP - INTERVAL '30 minutes', 'Крупный перевод'),
(1, 9, 850000.00, 'KZT', 1.000000, 850000.00, 'transfer', 'failed', NULL, 'Недостаточно средств'),
(13, 15, 2400000.00, 'KZT', 1.000000, 2400000.00, 'transfer', 'completed', CURRENT_TIMESTAMP - INTERVAL '15 minutes', 'Бизнес операция'),
(6, 10, 180000.00, 'KZT', 1.000000, 180000.00, 'transfer', 'completed', CURRENT_TIMESTAMP - INTERVAL '8 hours', 'Оплата счета');



-- TASK 1 - TRANSACTION MANAGEMENT

CREATE OR REPLACE FUNCTION process_transfer(
    p_from_account_number VARCHAR,
    p_to_account_number VARCHAR,
    p_amount NUMERIC,
    p_currency VARCHAR,
    p_description TEXT
) RETURNS TABLE(
    success BOOLEAN,
    transaction_id INTEGER,
    error_code VARCHAR,
    error_message TEXT
) AS $$
DECLARE
    v_from_account_id INTEGER;
    v_to_account_id INTEGER;
    v_from_customer_id INTEGER;
    v_from_balance NUMERIC;
    v_from_currency VARCHAR;
    v_to_currency VARCHAR;
    v_customer_status VARCHAR;
    v_exchange_rate NUMERIC;
    v_amount_kzt NUMERIC;
    v_daily_total NUMERIC;
    v_daily_limit NUMERIC;
    v_transaction_id INTEGER;
    v_savepoint_name VARCHAR := 'transfer_savepoint';
BEGIN
    -- Create savepoint for potential rollback
    EXECUTE format('SAVEPOINT %I', v_savepoint_name);

    -- Step 1: Validate and lock FROM account (prevent race conditions)
    BEGIN
        SELECT a.account_id, a.customer_id, a.balance, a.currency, a.is_active, c.status, c.daily_limit_kzt
        INTO STRICT v_from_account_id, v_from_customer_id, v_from_balance, v_from_currency, v_customer_status, v_customer_status, v_daily_limit
        FROM accounts a
        JOIN customers c ON a.customer_id = c.customer_id
        WHERE a.account_number = p_from_account_number
        FOR UPDATE;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            PERFORM log_audit_event('transactions', 0, 'INSERT', NULL,
                jsonb_build_object('error', 'Source account not found', 'account', p_from_account_number),
                inet_client_addr());
            RETURN QUERY SELECT FALSE, NULL::INTEGER, 'ERR_001'::VARCHAR, 'Source account does not exist'::TEXT;
            RETURN;
    END;

    -- Step 2: Validate TO account
    BEGIN
        SELECT a.account_id, a.currency, a.is_active
        INTO STRICT v_to_account_id, v_to_currency
        FROM accounts a
        WHERE a.account_number = p_to_account_number
        FOR UPDATE;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            EXECUTE format('ROLLBACK TO SAVEPOINT %I', v_savepoint_name);
            PERFORM log_audit_event('transactions', 0, 'INSERT', NULL,
                jsonb_build_object('error', 'Destination account not found', 'account', p_to_account_number),
                inet_client_addr());
            RETURN QUERY SELECT FALSE, NULL::INTEGER, 'ERR_002'::VARCHAR, 'Destination account does not exist'::TEXT;
            RETURN;
    END;

    -- Step 3: Validate accounts are active
    IF NOT EXISTS (SELECT 1 FROM accounts WHERE account_id = v_from_account_id AND is_active = TRUE) THEN
        EXECUTE format('ROLLBACK TO SAVEPOINT %I', v_savepoint_name);
        PERFORM log_audit_event('transactions', 0, 'INSERT', NULL,
            jsonb_build_object('error', 'Source account inactive', 'account_id', v_from_account_id),
            inet_client_addr());
        RETURN QUERY SELECT FALSE, NULL::INTEGER, 'ERR_003'::VARCHAR, 'Source account is not active'::TEXT;
        RETURN;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM accounts WHERE account_id = v_to_account_id AND is_active = TRUE) THEN
        EXECUTE format('ROLLBACK TO SAVEPOINT %I', v_savepoint_name);
        PERFORM log_audit_event('transactions', 0, 'INSERT', NULL,
            jsonb_build_object('error', 'Destination account inactive', 'account_id', v_to_account_id),
            inet_client_addr());
        RETURN QUERY SELECT FALSE, NULL::INTEGER, 'ERR_004'::VARCHAR, 'Destination account is not active'::TEXT;
        RETURN;
    END IF;

    -- Step 4: Check customer status
    SELECT c.status INTO v_customer_status
    FROM customers c
    JOIN accounts a ON a.customer_id = c.customer_id
    WHERE a.account_id = v_from_account_id;

    IF v_customer_status != 'active' THEN
        EXECUTE format('ROLLBACK TO SAVEPOINT %I', v_savepoint_name);
        PERFORM log_audit_event('transactions', 0, 'INSERT', NULL,
            jsonb_build_object('error', 'Customer not active', 'status', v_customer_status),
            inet_client_addr());
        RETURN QUERY SELECT FALSE, NULL::INTEGER, 'ERR_005'::VARCHAR,
            format('Customer status is %s. Only active customers can make transfers.', v_customer_status)::TEXT;
        RETURN;
    END IF;

    -- Step 5: Get exchange rate and calculate KZT amount
    IF p_currency = 'KZT' THEN
        v_amount_kzt := p_amount;
        v_exchange_rate := 1.000000;
    ELSE
        SELECT rate INTO v_exchange_rate
        FROM exchange_rates
        WHERE from_currency = p_currency
          AND to_currency = 'KZT'
          AND CURRENT_TIMESTAMP BETWEEN valid_from AND valid_to
        ORDER BY valid_from DESC
        LIMIT 1;

        IF v_exchange_rate IS NULL THEN
            EXECUTE format('ROLLBACK TO SAVEPOINT %I', v_savepoint_name);
            PERFORM log_audit_event('transactions', 0, 'INSERT', NULL,
                jsonb_build_object('error', 'Exchange rate not found', 'currency', p_currency),
                inet_client_addr());
            RETURN QUERY SELECT FALSE, NULL::INTEGER, 'ERR_006'::VARCHAR,
                format('Exchange rate not available for %s to KZT', p_currency)::TEXT;
            RETURN;
        END IF;

        v_amount_kzt := p_amount * v_exchange_rate;
    END IF;

    -- Step 6: Check sufficient balance (convert if needed)
    IF v_from_currency != p_currency THEN
        DECLARE
            v_conversion_rate NUMERIC;
        BEGIN
            SELECT rate INTO v_conversion_rate
            FROM exchange_rates
            WHERE from_currency = p_currency
              AND to_currency = v_from_currency
              AND CURRENT_TIMESTAMP BETWEEN valid_from AND valid_to
            ORDER BY valid_from DESC
            LIMIT 1;

            IF p_amount * v_conversion_rate > v_from_balance THEN
                EXECUTE format('ROLLBACK TO SAVEPOINT %I', v_savepoint_name);
                PERFORM log_audit_event('transactions', 0, 'INSERT', NULL,
                    jsonb_build_object('error', 'Insufficient balance', 'required', p_amount * v_conversion_rate, 'available', v_from_balance),
                    inet_client_addr());
                RETURN QUERY SELECT FALSE, NULL::INTEGER, 'ERR_007'::VARCHAR,
                    format('Insufficient balance. Required: %s %s, Available: %s %s',
                           p_amount * v_conversion_rate, v_from_currency, v_from_balance, v_from_currency)::TEXT;
                RETURN;
            END IF;
        END;
    ELSE
        IF p_amount > v_from_balance THEN
            EXECUTE format('ROLLBACK TO SAVEPOINT %I', v_savepoint_name);
            PERFORM log_audit_event('transactions', 0, 'INSERT', NULL,
                jsonb_build_object('error', 'Insufficient balance', 'required', p_amount, 'available', v_from_balance),
                inet_client_addr());
            RETURN QUERY SELECT FALSE, NULL::INTEGER, 'ERR_007'::VARCHAR,
                format('Insufficient balance. Required: %s %s, Available: %s %s',
                       p_amount, p_currency, v_from_balance, v_from_currency)::TEXT;
            RETURN;
        END IF;
    END IF;

    -- Step 7: Check daily transaction limit
    SELECT COALESCE(SUM(amount_kzt), 0) INTO v_daily_total
    FROM transactions
    WHERE from_account_id = v_from_account_id
      AND DATE(created_at) = CURRENT_DATE
      AND status = 'completed';

    SELECT c.daily_limit_kzt INTO v_daily_limit
    FROM customers c
    JOIN accounts a ON a.customer_id = c.customer_id
    WHERE a.account_id = v_from_account_id;

    IF (v_daily_total + v_amount_kzt) > v_daily_limit THEN
        EXECUTE format('ROLLBACK TO SAVEPOINT %I', v_savepoint_name);
        PERFORM log_audit_event('transactions', 0, 'INSERT', NULL,
            jsonb_build_object('error', 'Daily limit exceeded', 'limit', v_daily_limit, 'used', v_daily_total, 'attempted', v_amount_kzt),
            inet_client_addr());
        RETURN QUERY SELECT FALSE, NULL::INTEGER, 'ERR_008'::VARCHAR,
            format('Daily transaction limit exceeded. Limit: %s KZT, Used today: %s KZT, Attempted: %s KZT',
                   v_daily_limit, v_daily_total, v_amount_kzt)::TEXT;
        RETURN;
    END IF;

    -- Step 8: Create transaction record
    INSERT INTO transactions (from_account_id, to_account_id, amount, currency, exchange_rate, amount_kzt, type, status, description)
    VALUES (v_from_account_id, v_to_account_id, p_amount, p_currency, v_exchange_rate, v_amount_kzt, 'transfer', 'pending', p_description)
    RETURNING transactions.transaction_id INTO v_transaction_id;

    -- Step 9: Update account balances atomically
    BEGIN
        IF v_from_currency = p_currency THEN
            UPDATE accounts SET balance = balance - p_amount WHERE account_id = v_from_account_id;
        ELSE
            DECLARE
                v_deduct_rate NUMERIC;
            BEGIN
                SELECT rate INTO v_deduct_rate
                FROM exchange_rates
                WHERE from_currency = p_currency AND to_currency = v_from_currency
                  AND CURRENT_TIMESTAMP BETWEEN valid_from AND valid_to
                ORDER BY valid_from DESC LIMIT 1;

                UPDATE accounts SET balance = balance - (p_amount * v_deduct_rate) WHERE account_id = v_from_account_id;
            END;
        END IF;

        -- Add to destination account (with currency conversion)
        IF v_to_currency = p_currency THEN
            UPDATE accounts SET balance = balance + p_amount WHERE account_id = v_to_account_id;
        ELSE
            DECLARE
                v_add_rate NUMERIC;
            BEGIN
                SELECT rate INTO v_add_rate
                FROM exchange_rates
                WHERE from_currency = p_currency AND to_currency = v_to_currency
                  AND CURRENT_TIMESTAMP BETWEEN valid_from AND valid_to
                ORDER BY valid_from DESC LIMIT 1;

                UPDATE accounts SET balance = balance + (p_amount * v_add_rate) WHERE account_id = v_to_account_id;
            END;
        END IF;

        -- Update transaction status
        UPDATE transactions
        SET status = 'completed', completed_at = CURRENT_TIMESTAMP
        WHERE transaction_id = v_transaction_id;

        -- Log successful transaction
        PERFORM log_audit_event('transactions', v_transaction_id, 'INSERT', NULL,
            jsonb_build_object('from_account', v_from_account_id, 'to_account', v_to_account_id, 'amount', p_amount, 'currency', p_currency),
            inet_client_addr());

        -- Release savepoint
        EXECUTE format('RELEASE SAVEPOINT %I', v_savepoint_name);

        RETURN QUERY SELECT TRUE, v_transaction_id, 'SUCCESS'::VARCHAR, 'Transfer completed successfully'::TEXT;

    EXCEPTION
        WHEN OTHERS THEN
            EXECUTE format('ROLLBACK TO SAVEPOINT %I', v_savepoint_name);

            UPDATE transactions SET status = 'failed' WHERE transaction_id = v_transaction_id;

            PERFORM log_audit_event('transactions', v_transaction_id, 'UPDATE', NULL,
                jsonb_build_object('error', SQLERRM, 'sqlstate', SQLSTATE),
                inet_client_addr());

            RETURN QUERY SELECT FALSE, v_transaction_id, 'ERR_999'::VARCHAR,
                format('Transaction failed: %s', SQLERRM)::TEXT;
            RETURN;
    END;

END;
$$ LANGUAGE plpgsql;

-- Helper function for audit logging
CREATE OR REPLACE FUNCTION log_audit_event(
    p_table_name VARCHAR,
    p_record_id INTEGER,
    p_action VARCHAR,
    p_old_values JSONB,
    p_new_values JSONB,
    p_ip_address INET
) RETURNS VOID AS $$
BEGIN
    INSERT INTO audit_log (table_name, record_id, action, old_values, new_values, ip_address)
    VALUES (p_table_name, p_record_id, p_action, p_old_values, p_new_values, p_ip_address);
END;
$$ LANGUAGE plpgsql;


--TASK 2 - REPORTING VIEWS

-- View 1: Customer Balance Summary with rankings
CREATE OR REPLACE VIEW customer_balance_summary AS
WITH account_balances AS (
    SELECT
        a.customer_id,
        a.account_number,
        a.currency,
        a.balance,
        CASE
            WHEN a.currency = 'KZT' THEN a.balance
            ELSE a.balance * COALESCE(er.rate, 0)
        END AS balance_kzt
    FROM accounts a
    LEFT JOIN exchange_rates er ON er.from_currency = a.currency
        AND er.to_currency = 'KZT'
        AND CURRENT_TIMESTAMP BETWEEN er.valid_from AND er.valid_to
    WHERE a.is_active = TRUE
),
daily_usage AS (
    SELECT
        a.customer_id,
        COALESCE(SUM(t.amount_kzt), 0) AS daily_spent
    FROM accounts a
    LEFT JOIN transactions t ON t.from_account_id = a.account_id
        AND DATE(t.created_at) = CURRENT_DATE
        AND t.status = 'completed'
    GROUP BY a.customer_id
)
SELECT
    c.customer_id,
    c.full_name,
    c.iin,
    c.status,
    c.daily_limit_kzt,
    json_agg(
        json_build_object(
            'account_number', ab.account_number,
            'currency', ab.currency,
            'balance', ab.balance
        ) ORDER BY ab.balance_kzt DESC
    ) AS accounts,
    ROUND(SUM(ab.balance_kzt), 2) AS total_balance_kzt,
    ROUND((du.daily_spent / c.daily_limit_kzt) * 100, 2) AS daily_limit_utilization_percent,
    RANK() OVER (ORDER BY SUM(ab.balance_kzt) DESC) AS balance_rank,
    ROW_NUMBER() OVER (ORDER BY SUM(ab.balance_kzt) DESC) AS balance_position
FROM customers c
LEFT JOIN account_balances ab ON ab.customer_id = c.customer_id
LEFT JOIN daily_usage du ON du.customer_id = c.customer_id
GROUP BY c.customer_id, c.full_name, c.iin, c.status, c.daily_limit_kzt, du.daily_spent;

-- View 2: Daily Transaction Report with window functions
CREATE OR REPLACE VIEW daily_transaction_report AS
WITH daily_stats AS (
    SELECT
        DATE(created_at) AS transaction_date,
        type AS transaction_type,
        COUNT(*) AS transaction_count,
        SUM(amount_kzt) AS total_volume_kzt,
        AVG(amount_kzt) AS avg_amount_kzt
    FROM transactions
    WHERE status = 'completed'
    GROUP BY DATE(created_at), type
),
running_totals AS (
    SELECT
        transaction_date,
        transaction_type,
        transaction_count,
        total_volume_kzt,
        avg_amount_kzt,
        SUM(total_volume_kzt) OVER (
            PARTITION BY transaction_type
            ORDER BY transaction_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_volume_kzt,
        LAG(total_volume_kzt) OVER (
            PARTITION BY transaction_type
            ORDER BY transaction_date
        ) AS previous_day_volume_kzt
    FROM daily_stats
)
SELECT
    transaction_date,
    transaction_type,
    transaction_count,
    ROUND(total_volume_kzt, 2) AS total_volume_kzt,
    ROUND(avg_amount_kzt, 2) AS avg_amount_kzt,
    ROUND(cumulative_volume_kzt, 2) AS cumulative_volume_kzt,
    CASE
        WHEN previous_day_volume_kzt IS NULL OR previous_day_volume_kzt = 0 THEN NULL
        ELSE ROUND(((total_volume_kzt - previous_day_volume_kzt) / previous_day_volume_kzt) * 100, 2)
    END AS day_over_day_growth_percent
FROM running_totals
ORDER BY transaction_date DESC, transaction_type;

-- View 3: Suspicious Activity Detection with Security Barrier
CREATE VIEW suspicious_activity_view WITH (security_barrier = true) AS
WITH large_transactions AS (
    SELECT
        t.transaction_id,
        t.from_account_id,
        t.to_account_id,
        t.amount_kzt,
        t.created_at,
        'LARGE_TRANSACTION' AS flag_type,
        'Transaction exceeds 5,000,000 KZT threshold' AS flag_reason,
        c.full_name AS customer_name,
        c.iin
    FROM transactions t
    JOIN accounts a ON a.account_id = t.from_account_id
    JOIN customers c ON c.customer_id = a.customer_id
    WHERE t.amount_kzt > 5000000
      AND t.status = 'completed'
),
high_frequency_customers AS (
    SELECT
        t.transaction_id,
        t.from_account_id,
        t.created_at,
        'HIGH_FREQUENCY' AS flag_type,
        format('Customer made %s transactions within one hour', COUNT(*) OVER (PARTITION BY t.from_account_id, date_trunc('hour', t.created_at))) AS flag_reason,
        c.full_name AS customer_name,
        c.iin,
        COUNT(*) OVER (PARTITION BY t.from_account_id, date_trunc('hour', t.created_at)) AS hourly_count
    FROM transactions t
    JOIN accounts a ON a.account_id = t.from_account_id
    JOIN customers c ON c.customer_id = a.customer_id
    WHERE t.status = 'completed'
),
rapid_sequential AS (
    SELECT
        t1.transaction_id,
        t1.from_account_id,
        t1.created_at,
        'RAPID_SEQUENTIAL' AS flag_type,
        format('Sequential transfer within %s seconds of previous transaction',
               EXTRACT(EPOCH FROM (t1.created_at - t2.created_at))::INTEGER) AS flag_reason,
        c.full_name AS customer_name,
        c.iin
    FROM transactions t1
    JOIN transactions t2 ON t1.from_account_id = t2.from_account_id
        AND t1.transaction_id != t2.transaction_id
        AND t1.created_at > t2.created_at
        AND t1.created_at - t2.created_at < INTERVAL '1 minute'
    JOIN accounts a ON a.account_id = t1.from_account_id
    JOIN customers c ON c.customer_id = a.customer_id
    WHERE t1.status = 'completed'
      AND t2.status = 'completed'
)
SELECT DISTINCT
    COALESCE(lt.transaction_id, hf.transaction_id, rs.transaction_id) AS transaction_id,
    COALESCE(lt.customer_name, hf.customer_name, rs.customer_name) AS customer_name,
    COALESCE(lt.iin, hf.iin, rs.iin) AS customer_iin,
    COALESCE(lt.created_at, hf.created_at, rs.created_at) AS transaction_time,
    array_agg(DISTINCT COALESCE(lt.flag_type, hf.flag_type, rs.flag_type)) AS flags,
    array_agg(DISTINCT COALESCE(lt.flag_reason, hf.flag_reason, rs.flag_reason)) AS reasons
FROM large_transactions lt
FULL OUTER JOIN high_frequency_customers hf ON lt.transaction_id = hf.transaction_id
FULL OUTER JOIN rapid_sequential rs ON COALESCE(lt.transaction_id, hf.transaction_id) = rs.transaction_id
WHERE hf.hourly_count > 10 OR lt.transaction_id IS NOT NULL OR rs.transaction_id IS NOT NULL
GROUP BY
    COALESCE(lt.transaction_id, hf.transaction_id, rs.transaction_id),
    COALESCE(lt.customer_name, hf.customer_name, rs.customer_name),
    COALESCE(lt.iin, hf.iin, rs.iin),
    COALESCE(lt.created_at, hf.created_at, rs.created_at)
ORDER BY COALESCE(lt.created_at, hf.created_at, rs.created_at) DESC;



-- TASK 3 - PERFORMANCE OPTIMIZATION
-- Index 1: B-tree composite index for transaction lookups
CREATE INDEX idx_transactions_account_date_status
ON transactions(from_account_id, created_at DESC, status)
WHERE status = 'completed';

-- Index 2: Hash index for exact account number lookups
CREATE INDEX idx_accounts_number_hash
ON accounts USING HASH(account_number);

-- Index 3: GIN index for JSONB audit log search
CREATE INDEX idx_audit_log_values_gin
ON audit_log USING GIN(new_values, old_values);

-- Index 4: Partial index for active accounts only
CREATE INDEX idx_accounts_active_customer
ON accounts(customer_id, currency, balance)
WHERE is_active = TRUE;

-- Index 5: Expression index for case-insensitive email search
CREATE INDEX idx_customers_email_lower
ON customers(LOWER(email));

-- Index 6: Covering index for balance queries
CREATE INDEX idx_accounts_covering
ON accounts(customer_id, currency)
INCLUDE (balance, is_active, account_number);

-- Index 7: B-tree index for exchange rate temporal queries
CREATE INDEX idx_exchange_rates_temporal
ON exchange_rates(from_currency, to_currency, valid_from, valid_to);


-- TASK 4 - Batch Salary Processing

CREATE OR REPLACE FUNCTION process_salary_batch(
    p_company_account_number VARCHAR,
    p_payments JSONB
) RETURNS TABLE(
    success BOOLEAN,
    successful_count INTEGER,
    failed_count INTEGER,
    failed_details JSONB,
    batch_summary TEXT
) AS $$
DECLARE
    v_company_account_id INTEGER;
    v_company_balance NUMERIC;
    v_company_currency VARCHAR;
    v_total_amount_needed NUMERIC := 0;
    v_payment JSONB;
    v_employee_iin VARCHAR;
    v_payment_amount NUMERIC;
    v_description TEXT;
    v_employee_account_id INTEGER;
    v_success_count INTEGER := 0;
    v_fail_count INTEGER := 0;
    v_failed_payments JSONB := '[]'::JSONB;
    v_transaction_id INTEGER;
    v_lock_acquired BOOLEAN;
    v_advisory_key BIGINT;
BEGIN
    -- Generate advisory lock key from company account number
    v_advisory_key := ('x' || substring(md5(p_company_account_number), 1, 16))::bit(64)::bigint;

    -- Acquire advisory lock to prevent concurrent batch processing
    v_lock_acquired := pg_try_advisory_lock(v_advisory_key);

    IF NOT v_lock_acquired THEN
        RETURN QUERY SELECT FALSE, 0, 0,
            jsonb_build_array(jsonb_build_object('error', 'Another batch process is running for this company')),
            'Batch processing locked by concurrent operation'::TEXT;
        RETURN;
    END IF;

    BEGIN
        -- Validate company account
        SELECT a.account_id, a.balance, a.currency
        INTO STRICT v_company_account_id, v_company_balance, v_company_currency
        FROM accounts a
        WHERE a.account_number = p_company_account_number
          AND a.is_active = TRUE
        FOR UPDATE;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            PERFORM pg_advisory_unlock(v_advisory_key);
            RETURN QUERY SELECT FALSE, 0, 0,
                jsonb_build_array(jsonb_build_object('error', 'Company account not found or inactive')),
                'Invalid company account'::TEXT;
            RETURN;
    END;

    -- Calculate total batch amount
    FOR v_payment IN SELECT * FROM jsonb_array_elements(p_payments)
    LOOP
        v_total_amount_needed := v_total_amount_needed + (v_payment->>'amount')::NUMERIC;
    END LOOP;

    -- Validate sufficient balance
    IF v_company_balance < v_total_amount_needed THEN
        PERFORM pg_advisory_unlock(v_advisory_key);
        RETURN QUERY SELECT FALSE, 0, 0,
            jsonb_build_array(jsonb_build_object(
                'error', 'Insufficient company balance',
                'required', v_total_amount_needed,
                'available', v_company_balance
            )),
            format('Insufficient balance: need %s, have %s', v_total_amount_needed, v_company_balance)::TEXT;
        RETURN;
    END IF;

    -- Process each payment with SAVEPOINT for individual rollback
    FOR v_payment IN SELECT * FROM jsonb_array_elements(p_payments)
    LOOP
        BEGIN
            SAVEPOINT individual_payment;

            v_employee_iin := v_payment->>'iin';
            v_payment_amount := (v_payment->>'amount')::NUMERIC;
            v_description := COALESCE(v_payment->>'description', 'Salary payment');

            -- Find employee's KZT account
            SELECT a.account_id INTO v_employee_account_id
            FROM accounts a
            JOIN customers c ON c.customer_id = a.customer_id
            WHERE c.iin = v_employee_iin
              AND a.currency = 'KZT'
              AND a.is_active = TRUE
            LIMIT 1
            FOR UPDATE;

            IF v_employee_account_id IS NULL THEN
                RAISE EXCEPTION 'Employee account not found for IIN: %', v_employee_iin;
            END IF;

            -- Create transaction (bypass daily limit check for salary)
            INSERT INTO transactions (
                from_account_id,
                to_account_id,
                amount,
                currency,
                exchange_rate,
                amount_kzt,
                type,
                status,
                description
            ) VALUES (
                v_company_account_id,
                v_employee_account_id,
                v_payment_amount,
                'KZT',
                1.000000,
                v_payment_amount,
                'transfer',
                'pending',
                v_description || ' [SALARY_BATCH]'
            ) RETURNING transaction_id INTO v_transaction_id;

            -- Mark as completed
            UPDATE transactions
            SET status = 'completed', completed_at = CURRENT_TIMESTAMP
            WHERE transaction_id = v_transaction_id;

            v_success_count := v_success_count + 1;

            RELEASE SAVEPOINT individual_payment;

        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK TO SAVEPOINT individual_payment;
                v_fail_count := v_fail_count + 1;
                v_failed_payments := v_failed_payments || jsonb_build_object(
                    'iin', v_employee_iin,
                    'amount', v_payment_amount,
                    'error', SQLERRM
                );
        END;
    END LOOP;


    -- Update all balances atomically at the end
    IF v_success_count > 0 THEN
        -- Deduct total from company account
        DECLARE
            v_total_paid NUMERIC;
        BEGIN
            SELECT SUM(amount) INTO v_total_paid
            FROM transactions
            WHERE from_account_id = v_company_account_id
              AND status = 'completed'
              AND description LIKE '%[SALARY_BATCH]'
              AND completed_at >= CURRENT_TIMESTAMP - INTERVAL '1 minute';

            UPDATE accounts
            SET balance = balance - v_total_paid
            WHERE account_id = v_company_account_id;

            -- Add to employee accounts
            UPDATE accounts a
            SET balance = balance + t.amount
            FROM transactions t
            WHERE t.to_account_id = a.account_id
              AND t.from_account_id = v_company_account_id
              AND t.status = 'completed'
              AND t.description LIKE '%[SALARY_BATCH]'
              AND t.completed_at >= CURRENT_TIMESTAMP - INTERVAL '1 minute';
        END;
    END IF;

    -- Release advisory lock
    PERFORM pg_advisory_unlock(v_advisory_key);

    -- Return results
    RETURN QUERY SELECT
        TRUE,
        v_success_count,
        v_fail_count,
        v_failed_payments,
        format('Batch completed: %s successful, %s failed out of %s total payments',
               v_success_count, v_fail_count, v_success_count + v_fail_count)::TEXT;

EXCEPTION
    WHEN OTHERS THEN
        PERFORM pg_advisory_unlock(v_advisory_key);
        RETURN QUERY SELECT FALSE, 0, 0,
            jsonb_build_array(jsonb_build_object('error', SQLERRM)),
            format('Batch processing failed: %s', SQLERRM)::TEXT;
END;
$$ LANGUAGE plpgsql;

-- Materialized view for salary batch summaries
CREATE MATERIALIZED VIEW salary_batch_summary AS
SELECT
    DATE(t.completed_at) AS batch_date,
    a_from.account_number AS company_account,
    c_from.full_name AS company_name,
    COUNT(t.transaction_id) AS total_payments,
    SUM(t.amount_kzt) AS total_amount_kzt,
    AVG(t.amount_kzt) AS avg_salary_kzt,
    MIN(t.amount_kzt) AS min_salary_kzt,
    MAX(t.amount_kzt) AS max_salary_kzt,
    COUNT(DISTINCT t.to_account_id) AS unique_employees
FROM transactions t
JOIN accounts a_from ON a_from.account_id = t.from_account_id
JOIN customers c_from ON c_from.customer_id = a_from.customer_id
WHERE t.description LIKE '%[SALARY_BATCH]'
  AND t.status = 'completed'
GROUP BY DATE(t.completed_at), a_from.account_number, c_from.full_name
ORDER BY batch_date DESC;

-- Index for materialized view refresh performance
CREATE INDEX idx_salary_batch_summary_date ON salary_batch_summary(batch_date DESC);


-- Test cases & demonstrations
-- Test Case 1: Successful transfer
SELECT * FROM process_transfer(
    'KZ86125KZT0000004567',  -- from account
    'KZ34567KZT0000008901',  -- to account
    150000.00,                -- amount
    'KZT',                    -- currency
    'Тестовый перевод успешный'
);

-- Test Case 2: Failed transfer - insufficient balance
SELECT * FROM process_transfer(
    'KZ90123KZT0000016789',  --low balance
    'KZ55678KZT0000032345',  -- to account
    10000000.00,              -- too high
    'KZT',
    'Тест недостаточного баланса'
);

-- Test Case 3: Failed transfer - blocked customer
SELECT * FROM process_transfer(
    'KZ90123KZT0000016789',  -- from blocked customer
    'KZ55678KZT0000032345',
    50000.00,
    'KZT',
    'Тест заблокированного клиента'
);

-- Test Case 4: Cross-currency transfer
SELECT * FROM process_transfer(
    'KZ12125USD0000004568',  -- USD account
    'KZ34567KZT0000008901',  -- KZT account
    100.00,
    'USD',
    'Валютный перевод тест'
);

-- Test Case 5: Daily limit exceeded
DO $$
BEGIN
    FOR i IN 1..5 LOOP
        PERFORM process_transfer(
            'KZ86125KZT0000004567',
            'KZ34567KZT0000008901',
            3000000.00,
            'KZT',
            format('Тест лимита #%s', i)
        );
    END LOOP;
END $$;

-- Test Case 6: Batch salary processing
SELECT * FROM process_salary_batch(
    'KZ11234KZT0000020123',  -- company account with sufficient balance
    '[
        {"iin": "950815401234", "amount": 450000, "description": "Зарплата за декабрь"},
        {"iin": "880523502145", "amount": 380000, "description": "Зарплата за декабрь"},
        {"iin": "920310603256", "amount": 520000, "description": "Зарплата за декабрь"},
        {"iin": "990208805478", "amount": 680000, "description": "Зарплата за декабрь"},
        {"iin": "931117906589", "amount": 410000, "description": "Зарплата за декабрь"}
    ]'::JSONB
);

-- Refresh materialized view
REFRESH MATERIALIZED VIEW salary_batch_summary;


-- Query performance analysis

-- Performance test 1: Account lookup with hash index
EXPLAIN ANALYZE
SELECT * FROM accounts WHERE account_number = 'KZ86125KZT0000004567';

-- Performance test 2: Transaction history with composite index
EXPLAIN ANALYZE
SELECT * FROM transactions
WHERE from_account_id = 1
  AND created_at >= CURRENT_DATE - INTERVAL '30 days'
  AND status = 'completed'
ORDER BY created_at DESC;

-- Performance test 3: Case-insensitive email search
EXPLAIN ANALYZE
SELECT * FROM customers WHERE LOWER(email) = LOWER('nurlan.abdr@gmail.com');

-- Performance test 4: JSONB search in audit log
EXPLAIN ANALYZE
SELECT * FROM audit_log
WHERE new_values @> '{"status": "completed"}'::jsonb
LIMIT 100;

-- Performance test 5: Active accounts with covering index
EXPLAIN ANALYZE
SELECT customer_id, currency, balance, account_number
FROM accounts
WHERE is_active = TRUE
ORDER BY balance DESC;


-- Concurrency demonstration script

-- Session 1: Start transaction and lock account
-- BEGIN;
-- SELECT * FROM accounts WHERE account_number = 'KZ86125KZT0000004567' FOR UPDATE;
-- -- Wait here (don't commit)

-- Session 2: Try to transfer from same account (will wait for lock)
-- SELECT * FROM process_transfer(
--     'KZ86125KZT0000004567',
--     'KZ34567KZT0000008901',
--     100000.00,
--     'KZT',
--     'Concurrent transfer test'
-- );

-- Session 1: COMMIT; -- Session 2 will now proceed


-- Additional utility queries

-- View customer balance summary
SELECT * FROM customer_balance_summary ORDER BY total_balance_kzt DESC LIMIT 5;

-- View daily transaction report
SELECT * FROM daily_transaction_report WHERE transaction_date >= CURRENT_DATE - INTERVAL '7 days';

-- View suspicious activities
SELECT * FROM suspicious_activity_view LIMIT 10;

-- View salary batch summaries
SELECT * FROM salary_batch_summary;

-- Check audit log for recent activities
SELECT
    table_name,
    action,
    changed_by,
    changed_at,
    new_values->>'error' AS error_message
FROM audit_log
ORDER BY changed_at DESC
LIMIT 20;


-- Documentation:
/*
KEY DESIGN DECISIONS:

1. TRANSACTION MANAGEMENT:
   - Used SELECT FOR UPDATE to prevent race conditions
   - Implemented SAVEPOINT for partial rollback scenarios
   - All validations happen before any data modification
   - Atomic balance updates at the end of transaction
   - Comprehensive error codes for each failure type

2. VIEW DESIGN:
   - customer_balance_summary: Uses window functions (RANK, ROW_NUMBER) for customer ranking
   - daily_transaction_report: Implements LAG for day-over-day calculations
   - suspicious_activity_view: Uses SECURITY BARRIER to prevent data leakage

3. INDEX STRATEGY:
   - Hash index: Fast exact lookups for account numbers (O(1) average)
   - Composite B-tree: Optimized for filtered range queries
   - GIN index: Efficient JSONB containment queries
   - Partial index: Reduces index size by indexing only active accounts
   - Expression index: Enables case-insensitive searches
   - Covering index: Eliminates table lookups for common queries

4. BATCH PROCESSING:
   - Advisory locks prevent concurrent batch processing
   - SAVEPOINT allows individual payment failures without failing entire batch
   - Atomic balance updates at the end for consistency
   - Daily limit bypass for salary payments (business rule)
   - Detailed error reporting in JSONB format

5. PERFORMANCE OPTIMIZATIONS:
   - Strategic index placement based on query patterns
   - Materialized view for expensive aggregations
   - JSONB for flexible audit trail storage
   - Proper foreign key constraints for referential integrity

6. SECURITY CONSIDERATIONS:
   - Security barrier view prevents information leakage
   - Customer status validation before transfers
   - Comprehensive audit logging of all operations
   - IP address tracking in audit log
*/

-- END
