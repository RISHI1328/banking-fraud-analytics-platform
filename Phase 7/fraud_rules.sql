-- =====================================================================
--  Banking Transaction Monitoring & Fraud Analytics Platform
--  Phase 7 : Fraud Detection Rules (SQL)
--
--  These VIEWs implement rule-based fraud detection directly in the
--  database using window functions. Each view returns the flagged
--  transactions and a human-readable reason. Rules are explainable and
--  auditable -- an analyst or regulator can see exactly why a row fired.
--
--  Run this whole file once in MySQL Workbench, then inspect any view,
--  e.g.  SELECT * FROM v_fraud_all;
-- =====================================================================
USE federal_bank;


-- ---------------------------------------------------------------------
-- RULE 1 - VELOCITY
-- Business meaning: a card being tested or an account taken over often
-- fires many transactions in seconds. We flag any transaction that is
-- the 6th-or-more within a trailing 2-minute window for its account.
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW v_fraud_velocity AS
SELECT transaction_id, account_id, transaction_timestamp,
       'Velocity' AS rule_triggered,
       CONCAT('More than 5 transactions in 2 minutes (', cnt, ' in window)') AS alert_reason
FROM (
    SELECT t.transaction_id, t.account_id, t.transaction_timestamp,
           COUNT(*) OVER (
               PARTITION BY t.account_id
               ORDER BY t.transaction_timestamp
               RANGE BETWEEN INTERVAL 2 MINUTE PRECEDING AND CURRENT ROW
           ) AS cnt
    FROM transactions t
) w
WHERE cnt > 5;


-- ---------------------------------------------------------------------
-- RULE 2 - AMOUNT ANOMALY
-- Business meaning: a charge far above a customer's normal spending is a
-- classic sign of a compromised account. We flag amounts more than 8x
-- the account's own average transaction amount.
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW v_fraud_amount_anomaly AS
SELECT transaction_id, account_id, transaction_timestamp,
       'Amount Anomaly' AS rule_triggered,
       CONCAT('Amount ', amount, ' exceeds 8x account average ', ROUND(acct_avg, 2)) AS alert_reason
FROM (
    SELECT t.transaction_id, t.account_id, t.transaction_timestamp, t.amount,
           AVG(t.amount) OVER (PARTITION BY t.account_id) AS acct_avg
    FROM transactions t
) w
WHERE amount > 8 * acct_avg;


-- ---------------------------------------------------------------------
-- RULE 3 - IMPOSSIBLE TRAVEL
-- Business meaning: the same account transacting in two different cities
-- within minutes suggests a cloned card. We compare each transaction to
-- the account's previous one (LAG) and flag a city change within 60 min.
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW v_fraud_impossible_travel AS
SELECT transaction_id, account_id, transaction_timestamp,
       'Impossible Travel' AS rule_triggered,
       CONCAT('Moved from ', prev_city, ' to ', transaction_city, ' in ', mins, ' min') AS alert_reason
FROM (
    SELECT t.transaction_id, t.account_id, t.transaction_timestamp, t.transaction_city,
           LAG(t.transaction_city)     OVER w AS prev_city,
           TIMESTAMPDIFF(MINUTE, LAG(t.transaction_timestamp) OVER w, t.transaction_timestamp) AS mins
    FROM transactions t
    WINDOW w AS (PARTITION BY t.account_id ORDER BY t.transaction_timestamp)
) x
WHERE prev_city IS NOT NULL
  AND transaction_city IS NOT NULL
  AND prev_city <> transaction_city
  AND mins BETWEEN 0 AND 60;


-- ---------------------------------------------------------------------
-- RULE 4 - MIDNIGHT HIGH VALUE
-- Business meaning: large transactions in the dead of night, when the
-- customer is likely asleep, often indicate unauthorised access. We flag
-- transactions between 00:00-04:59 that exceed 5x the account average.
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW v_fraud_midnight AS
SELECT transaction_id, account_id, transaction_timestamp,
       'Midnight High Value' AS rule_triggered,
       CONCAT('High-value ', amount, ' at ', HOUR(transaction_timestamp), ':00 hrs') AS alert_reason
FROM (
    SELECT t.transaction_id, t.account_id, t.transaction_timestamp, t.amount,
           AVG(t.amount) OVER (PARTITION BY t.account_id) AS acct_avg
    FROM transactions t
) w
WHERE HOUR(transaction_timestamp) BETWEEN 0 AND 4
  AND amount > 5 * acct_avg;


-- ---------------------------------------------------------------------
-- RULE 5 - CARD TESTING (multiple failures then a success)
-- Business meaning: fraudsters try a stolen card repeatedly until one
-- charge succeeds. We flag a successful transaction preceded by 3 or more
-- failed transactions on the same account within 5 minutes.
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW v_fraud_card_testing AS
SELECT transaction_id, account_id, transaction_timestamp,
       'Card Testing' AS rule_triggered,
       CONCAT(fails_before, ' failed attempts before this success') AS alert_reason
FROM (
    SELECT t.transaction_id, t.account_id, t.transaction_timestamp, t.status,
           SUM(CASE WHEN t.status = 'Failed' THEN 1 ELSE 0 END) OVER (
               PARTITION BY t.account_id
               ORDER BY t.transaction_timestamp
               RANGE BETWEEN INTERVAL 5 MINUTE PRECEDING AND CURRENT ROW
           ) AS fails_before
    FROM transactions t
) w
WHERE status = 'Success' AND fails_before >= 3;


-- ---------------------------------------------------------------------
-- COMBINED VIEW: all fraud flags in one place
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW v_fraud_all AS
SELECT * FROM v_fraud_velocity
UNION ALL SELECT * FROM v_fraud_amount_anomaly
UNION ALL SELECT * FROM v_fraud_impossible_travel
UNION ALL SELECT * FROM v_fraud_midnight
UNION ALL SELECT * FROM v_fraud_card_testing;


-- ---------------------------------------------------------------------
-- INSPECTION QUERIES (run these to see results)
-- ---------------------------------------------------------------------
-- How many alerts per rule?
--   SELECT rule_triggered, COUNT(*) AS alerts FROM v_fraud_all GROUP BY rule_triggered;
--
-- See the actual flagged transactions:
--   SELECT * FROM v_fraud_all ORDER BY account_id, transaction_timestamp;


-- ---------------------------------------------------------------------
-- OPTIONAL: populate fraud_alerts directly from SQL.
-- The Phase 7 Python notebook already does this (and also scores the
-- results against the ground truth), so run EITHER the notebook OR this
-- block -- not both -- to avoid duplicate alerts.
-- ---------------------------------------------------------------------
-- TRUNCATE TABLE fraud_alerts;
-- INSERT INTO fraud_alerts
--     (transaction_id, customer_id, rule_triggered, alert_reason, risk_level, status, alert_timestamp)
-- SELECT f.transaction_id, a.customer_id, f.rule_triggered, f.alert_reason,
--        'Medium', 'Open', f.transaction_timestamp
-- FROM v_fraud_all f
-- JOIN transactions t ON f.transaction_id = t.transaction_id
-- JOIN accounts     a ON t.account_id     = a.account_id;
