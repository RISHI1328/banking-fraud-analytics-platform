-- =====================================================================
--  Banking Transaction Monitoring & Fraud Analytics Platform
--  Phase 3 : OLTP Database Schema  (MySQL 8)
--  Client (fictional) : Meridian Retail Bank
--
--  This script creates the operational (OLTP) database: the tables that
--  store day-to-day banking data. It is written to be RE-RUNNABLE -- it
--  drops existing tables first, so running it again gives a clean schema.
--
--  Design notes:
--    * Engine InnoDB is used everywhere so FOREIGN KEYs are enforced.
--    * Money is stored as DECIMAL (never FLOAT) to avoid rounding errors.
--    * ENUMs restrict columns to valid values (e.g. status, channel).
--    * Indexes are added on columns the fraud/analytics queries filter on.
-- =====================================================================

-- Create and select the database.
CREATE DATABASE IF NOT EXISTS federal_bank
    CHARACTER SET utf8mb4;
USE federal_bank;

-- Drop existing tables (children first) so the script can be re-run safely.
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS fraud_alerts, transactions, loans, cards,
                     accounts, customers, employees, branches;
SET FOREIGN_KEY_CHECKS = 1;


-- ---------------------------------------------------------------------
-- 1. BRANCHES : physical bank locations. Parent of accounts/employees.
-- ---------------------------------------------------------------------
CREATE TABLE branches (
    branch_id    INT AUTO_INCREMENT PRIMARY KEY,          -- unique branch id
    branch_name  VARCHAR(100) NOT NULL,                   -- branch display name
    ifsc_code    VARCHAR(11)  NOT NULL UNIQUE,            -- Indian branch code (unique)
    city         VARCHAR(50)  NOT NULL,                   -- branch city
    state        VARCHAR(50)  NOT NULL,                   -- branch state
    opened_date  DATE         NOT NULL,                   -- when the branch opened
    created_at   TIMESTAMP    DEFAULT CURRENT_TIMESTAMP   -- row insert time
) ENGINE=InnoDB;


-- ---------------------------------------------------------------------
-- 2. EMPLOYEES : bank staff. Fraud analysts (who review alerts) live here.
-- ---------------------------------------------------------------------
CREATE TABLE employees (
    employee_id  INT AUTO_INCREMENT PRIMARY KEY,
    branch_id    INT          NOT NULL,                   -- which branch they work at
    first_name   VARCHAR(50)  NOT NULL,
    last_name    VARCHAR(50)  NOT NULL,
    role         ENUM('Teller','Branch Manager','Fraud Analyst','Operations') NOT NULL,
    email        VARCHAR(100) NOT NULL UNIQUE,
    hire_date    DATE         NOT NULL,
    created_at   TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_employee_branch
        FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
) ENGINE=InnoDB;


-- ---------------------------------------------------------------------
-- 3. CUSTOMERS : people who bank with Meridian. Parent of accounts/loans.
-- ---------------------------------------------------------------------
CREATE TABLE customers (
    customer_id    INT AUTO_INCREMENT PRIMARY KEY,
    first_name     VARCHAR(50)  NOT NULL,
    last_name      VARCHAR(50)  NOT NULL,
    gender         ENUM('Male','Female','Other'),
    date_of_birth  DATE,
    email          VARCHAR(100) UNIQUE,                   -- may be null, but unique when present
    phone          VARCHAR(15),
    city           VARCHAR(50)  NOT NULL,                 -- customer's home city
    state          VARCHAR(50)  NOT NULL,
    kyc_status     ENUM('Verified','Pending','Rejected') NOT NULL DEFAULT 'Pending',
    customer_since DATE         NOT NULL,                 -- relationship start date
    created_at     TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;


-- ---------------------------------------------------------------------
-- 4. ACCOUNTS : money containers. Each belongs to one customer + branch.
-- ---------------------------------------------------------------------
CREATE TABLE accounts (
    account_id     INT AUTO_INCREMENT PRIMARY KEY,
    customer_id    INT           NOT NULL,                -- owner
    branch_id      INT           NOT NULL,                -- home branch
    account_number VARCHAR(20)   NOT NULL UNIQUE,         -- public account number
    account_type   ENUM('Savings','Current','Fixed Deposit') NOT NULL,
    balance        DECIMAL(15,2) NOT NULL DEFAULT 0.00,   -- current balance (money = DECIMAL)
    status         ENUM('Active','Dormant','Closed') NOT NULL DEFAULT 'Active',
    opened_date    DATE          NOT NULL,
    created_at     TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_account_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT fk_account_branch
        FOREIGN KEY (branch_id)   REFERENCES branches(branch_id)
) ENGINE=InnoDB;


-- ---------------------------------------------------------------------
-- 5. CARDS : debit/credit cards linked to an account.
--    NOTE: card_number here is synthetic/tokenised -- never store real PANs.
-- ---------------------------------------------------------------------
CREATE TABLE cards (
    card_id      INT AUTO_INCREMENT PRIMARY KEY,
    account_id   INT          NOT NULL,                   -- account the card draws from
    card_number  VARCHAR(20)  NOT NULL UNIQUE,            -- synthetic card number
    card_type    ENUM('Debit','Credit') NOT NULL,
    network      ENUM('Visa','Mastercard','RuPay') NOT NULL,
    issued_date  DATE         NOT NULL,
    expiry_date  DATE         NOT NULL,
    status       ENUM('Active','Blocked','Expired') NOT NULL DEFAULT 'Active',
    created_at   TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_card_account
        FOREIGN KEY (account_id) REFERENCES accounts(account_id)
) ENGINE=InnoDB;


-- ---------------------------------------------------------------------
-- 6. LOANS : money lent to customers. Kept separate from deposit accounts.
-- ---------------------------------------------------------------------
CREATE TABLE loans (
    loan_id             INT AUTO_INCREMENT PRIMARY KEY,
    customer_id         INT           NOT NULL,
    branch_id           INT           NOT NULL,
    loan_type           ENUM('Home','Personal','Auto','Education') NOT NULL,
    principal_amount    DECIMAL(15,2) NOT NULL,           -- original loan amount
    interest_rate       DECIMAL(5,2)  NOT NULL,           -- annual interest rate (%)
    tenure_months       INT           NOT NULL,           -- repayment period
    outstanding_balance DECIMAL(15,2) NOT NULL,           -- amount still owed
    start_date          DATE          NOT NULL,
    status              ENUM('Active','Closed','Defaulted') NOT NULL DEFAULT 'Active',
    created_at          TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_loan_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT fk_loan_branch
        FOREIGN KEY (branch_id)   REFERENCES branches(branch_id),
    CONSTRAINT chk_principal CHECK (principal_amount > 0)
) ENGINE=InnoDB;


-- ---------------------------------------------------------------------
-- 7. TRANSACTIONS : the core, high-volume table. Fraud lives here.
--    BIGINT id because this table grows the fastest.
--    card_id is NULLABLE -- not every transaction uses a card (e.g. UPI).
-- ---------------------------------------------------------------------
CREATE TABLE transactions (
    transaction_id        BIGINT AUTO_INCREMENT PRIMARY KEY,
    account_id            INT           NOT NULL,         -- account affected
    card_id               INT           NULL,             -- card used, if any
    transaction_type      ENUM('Deposit','Withdrawal','Transfer','Payment','Reversal') NOT NULL,
    channel               ENUM('ATM','POS','Internet','Mobile','Branch','UPI') NOT NULL,
    amount                DECIMAL(15,2) NOT NULL,
    currency              CHAR(3)       NOT NULL DEFAULT 'INR',
    status                ENUM('Success','Failed','Reversed') NOT NULL,
    transaction_city      VARCHAR(50),                    -- where it happened (impossible-travel rule)
    counterparty_account  VARCHAR(20),                    -- destination account for transfers
    description           VARCHAR(255),
    is_flagged            BOOLEAN       NOT NULL DEFAULT FALSE,  -- set TRUE if a fraud rule fires
    transaction_timestamp DATETIME      NOT NULL,         -- when it occurred (used by time-based rules)
    created_at            TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_txn_account
        FOREIGN KEY (account_id) REFERENCES accounts(account_id),
    CONSTRAINT fk_txn_card
        FOREIGN KEY (card_id)    REFERENCES cards(card_id),
    CONSTRAINT chk_amount CHECK (amount > 0)
) ENGINE=InnoDB;

-- Indexes that make fraud/analytics queries fast:
CREATE INDEX idx_txn_timestamp    ON transactions(transaction_timestamp);          -- time filters
CREATE INDEX idx_txn_status       ON transactions(status);                         -- failed-txn KPIs
-- Composite index: fast "transactions for one account within a time window"
-- (this is exactly what the velocity / impossible-travel rules need).
CREATE INDEX idx_txn_account_time ON transactions(account_id, transaction_timestamp);


-- ---------------------------------------------------------------------
-- 8. FRAUD_ALERTS : one row per suspicious transaction a rule flags.
-- ---------------------------------------------------------------------
CREATE TABLE fraud_alerts (
    alert_id        INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id  BIGINT       NOT NULL,                -- the flagged transaction
    customer_id     INT          NOT NULL,                -- customer involved
    rule_triggered  ENUM('Velocity','Amount Anomaly','Impossible Travel',
                         'Midnight High Value','Card Testing') NOT NULL,
    alert_reason    VARCHAR(255) NOT NULL,                -- human-readable explanation
    risk_level      ENUM('Low','Medium','High') NOT NULL DEFAULT 'Medium',
    status          ENUM('Open','Investigating','Confirmed Fraud','False Positive')
                         NOT NULL DEFAULT 'Open',
    reviewed_by     INT          NULL,                    -- fraud analyst (employee) who reviewed
    alert_timestamp DATETIME     NOT NULL,
    reviewed_at     DATETIME     NULL,
    created_at      TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_alert_txn
        FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id),
    CONSTRAINT fk_alert_customer
        FOREIGN KEY (customer_id)    REFERENCES customers(customer_id),
    CONSTRAINT fk_alert_reviewer
        FOREIGN KEY (reviewed_by)    REFERENCES employees(employee_id)
) ENGINE=InnoDB;

-- Index for "show me all open alerts" style queries.
CREATE INDEX idx_alert_status ON fraud_alerts(status);

-- =====================================================================
--  End of schema. Run this once in MySQL Workbench to build the database.
-- =====================================================================
