-- =====================================================================
--  Banking Transaction Monitoring & Fraud Analytics Platform
--  Phase 8 : Data Warehouse (Star Schema)  --  MySQL 8
--
--  We reshape the normalized OLTP data into a STAR SCHEMA built for fast
--  reporting. One central FACT table (fact_transactions) holds the numbers
--  (one row per transaction) and points to small DIMENSION tables that hold
--  descriptive attributes (who / where / when / how).
--
--  Why a star schema?
--    * Reporting needs fewer joins -> faster, simpler dashboard queries.
--    * A dedicated date dimension makes "by month / weekday / quarter" trivial.
--    * This is the standard analytics model Power BI is designed to consume.
--
--  Run this whole file once in MySQL Workbench (use "Execute SQL Script",
--  the plain lightning-bolt, to run everything, not just one statement).
-- =====================================================================
USE federal_bank;

-- Drop in child-first order so the script is re-runnable.
DROP TABLE IF EXISTS fact_transactions;
DROP TABLE IF EXISTS dim_date;
DROP TABLE IF EXISTS dim_customer;
DROP TABLE IF EXISTS dim_branch;
DROP TABLE IF EXISTS dim_channel;


-- ---------------------------------------------------------------------
-- DIMENSION: dim_date  (one row per calendar day in the data range)
-- date_key is a readable integer like 20260115 (YYYYMMDD).
-- ---------------------------------------------------------------------
CREATE TABLE dim_date (
    date_key    INT          PRIMARY KEY,   -- YYYYMMDD
    full_date   DATE         NOT NULL,
    year        INT          NOT NULL,
    quarter     INT          NOT NULL,
    month       INT          NOT NULL,
    month_name  VARCHAR(15)  NOT NULL,
    day         INT          NOT NULL,
    day_of_week INT          NOT NULL,       -- 1=Sunday ... 7=Saturday
    day_name    VARCHAR(15)  NOT NULL,
    is_weekend  BOOLEAN      NOT NULL
) ENGINE=InnoDB;

-- Generate every date between the first and last transaction using a
-- recursive CTE, then derive the calendar parts with date functions.
INSERT INTO dim_date
    (date_key, full_date, year, quarter, month, month_name, day, day_of_week, day_name, is_weekend)
WITH RECURSIVE date_range AS (
    SELECT MIN(DATE(transaction_timestamp)) AS d FROM transactions
    UNION ALL
    SELECT d + INTERVAL 1 DAY
    FROM date_range
    WHERE d + INTERVAL 1 DAY <= (SELECT MAX(DATE(transaction_timestamp)) FROM transactions)
)
SELECT CAST(DATE_FORMAT(d, '%Y%m%d') AS UNSIGNED),
       d, YEAR(d), QUARTER(d), MONTH(d), MONTHNAME(d),
       DAYOFMONTH(d), DAYOFWEEK(d), DAYNAME(d),
       (DAYOFWEEK(d) IN (1, 7))       -- Sunday or Saturday
FROM date_range;


-- ---------------------------------------------------------------------
-- DIMENSION: dim_customer
-- customer_key is a surrogate key; customer_id keeps the original id.
-- ---------------------------------------------------------------------
CREATE TABLE dim_customer (
    customer_key   INT AUTO_INCREMENT PRIMARY KEY,
    customer_id    INT          NOT NULL,
    full_name      VARCHAR(101),
    gender         VARCHAR(10),
    city           VARCHAR(50),
    state          VARCHAR(50),
    kyc_status     VARCHAR(10),
    customer_since DATE
) ENGINE=InnoDB;

INSERT INTO dim_customer (customer_id, full_name, gender, city, state, kyc_status, customer_since)
SELECT customer_id, CONCAT(first_name, ' ', last_name), gender, city, state, kyc_status, customer_since
FROM customers;


-- ---------------------------------------------------------------------
-- DIMENSION: dim_branch
-- ---------------------------------------------------------------------
CREATE TABLE dim_branch (
    branch_key  INT AUTO_INCREMENT PRIMARY KEY,
    branch_id   INT          NOT NULL,
    branch_name VARCHAR(100),
    city        VARCHAR(50),
    state       VARCHAR(50),
    ifsc_code   VARCHAR(11)
) ENGINE=InnoDB;

INSERT INTO dim_branch (branch_id, branch_name, city, state, ifsc_code)
SELECT branch_id, branch_name, city, state, ifsc_code
FROM branches;


-- ---------------------------------------------------------------------
-- DIMENSION: dim_channel  (small lookup: ATM, POS, UPI, ...)
-- ---------------------------------------------------------------------
CREATE TABLE dim_channel (
    channel_key  INT AUTO_INCREMENT PRIMARY KEY,
    channel_name VARCHAR(20) NOT NULL UNIQUE
) ENGINE=InnoDB;

INSERT INTO dim_channel (channel_name)
SELECT DISTINCT channel FROM transactions;


-- ---------------------------------------------------------------------
-- FACT: fact_transactions  (one row per transaction = the grain)
-- Holds the measures (amount, flags) and foreign keys to the dimensions.
-- transaction_id is kept as a "degenerate dimension" for traceability.
-- is_success / is_failed are 1/0 helper measures for easy SUMs.
-- ---------------------------------------------------------------------
CREATE TABLE fact_transactions (
    transaction_id   BIGINT       PRIMARY KEY,
    date_key         INT          NOT NULL,
    customer_key     INT          NOT NULL,
    branch_key       INT          NOT NULL,
    channel_key      INT          NOT NULL,
    transaction_type VARCHAR(20)  NOT NULL,
    status           VARCHAR(10)  NOT NULL,
    amount           DECIMAL(15,2) NOT NULL,
    is_flagged       BOOLEAN      NOT NULL,
    is_success       TINYINT      NOT NULL,
    is_failed        TINYINT      NOT NULL,
    CONSTRAINT fk_fact_date     FOREIGN KEY (date_key)     REFERENCES dim_date(date_key),
    CONSTRAINT fk_fact_customer FOREIGN KEY (customer_key) REFERENCES dim_customer(customer_key),
    CONSTRAINT fk_fact_branch   FOREIGN KEY (branch_key)   REFERENCES dim_branch(branch_key),
    CONSTRAINT fk_fact_channel  FOREIGN KEY (channel_key)  REFERENCES dim_channel(channel_key)
) ENGINE=InnoDB;

-- Populate the fact by joining OLTP transactions to the dimensions to
-- translate natural ids into the dimensions' surrogate keys.
INSERT INTO fact_transactions
    (transaction_id, date_key, customer_key, branch_key, channel_key,
     transaction_type, status, amount, is_flagged, is_success, is_failed)
SELECT t.transaction_id,
       CAST(DATE_FORMAT(t.transaction_timestamp, '%Y%m%d') AS UNSIGNED) AS date_key,
       dc.customer_key,
       db.branch_key,
       dch.channel_key,
       t.transaction_type,
       t.status,
       t.amount,
       t.is_flagged,
       (t.status = 'Success') AS is_success,
       (t.status = 'Failed')  AS is_failed
FROM transactions t
JOIN accounts     a   ON t.account_id     = a.account_id
JOIN dim_customer dc  ON dc.customer_id   = a.customer_id
JOIN dim_branch   db  ON db.branch_id     = a.branch_id
JOIN dim_channel  dch ON dch.channel_name = t.channel;

-- Indexes on the fact's foreign keys speed up dashboard joins/aggregations.
CREATE INDEX idx_fact_date     ON fact_transactions(date_key);
CREATE INDEX idx_fact_customer ON fact_transactions(customer_key);
CREATE INDEX idx_fact_branch   ON fact_transactions(branch_key);
CREATE INDEX idx_fact_channel  ON fact_transactions(channel_key);


-- ---------------------------------------------------------------------
-- SAMPLE ANALYTICAL QUERIES (the payoff — notice how few joins these need)
-- ---------------------------------------------------------------------
-- Monthly transaction volume and value:
--   SELECT d.year, d.month, d.month_name,
--          COUNT(*) AS txns, SUM(f.amount) AS total_value
--   FROM fact_transactions f JOIN dim_date d ON f.date_key = d.date_key
--   GROUP BY d.year, d.month, d.month_name ORDER BY d.year, d.month;
--
-- Fraud rate by branch:
--   SELECT b.branch_name,
--          ROUND(100 * SUM(f.is_flagged) / COUNT(*), 2) AS fraud_pct
--   FROM fact_transactions f JOIN dim_branch b ON f.branch_key = b.branch_key
--   GROUP BY b.branch_name ORDER BY fraud_pct DESC;
--
-- Most popular channels:
--   SELECT c.channel_name, COUNT(*) AS txns
--   FROM fact_transactions f JOIN dim_channel c ON f.channel_key = c.channel_key
--   GROUP BY c.channel_name ORDER BY txns DESC;
-- =====================================================================
