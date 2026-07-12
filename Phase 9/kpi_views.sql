-- =====================================================================
--  Banking Transaction Monitoring & Fraud Analytics Platform
--  Phase 9 : Business KPIs (SQL Views + Stored Procedures)  --  MySQL 8
--
--  These objects turn the Phase 2 KPI dictionary into reusable SQL on top
--  of the Phase 8 star schema. VIEWS provide always-on KPIs the dashboard
--  reads directly; STORED PROCEDURES provide parameterised KPIs (e.g. for a
--  chosen month).
--
--  REVENUE MODEL (a documented proxy for this portfolio project):
--    * Fee revenue     = 0.5%  (0.005) of each SUCCESSFUL transaction amount.
--    * Interest margin = 3%    (0.03)  annual, on ACTIVE account balances.
--    * Total revenue   = fee revenue (over loaded history) + annual interest margin.
--  Change the 0.005 / 0.03 literals below to re-tune the model.
--
--  Run the whole file once in MySQL Workbench (Execute SQL Script).
-- =====================================================================
USE federal_bank;


-- ---------------------------------------------------------------------
-- 1. v_kpi_overview  — one-row executive summary (dashboard KPI cards)
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW v_kpi_overview AS
SELECT
    (SELECT COUNT(*) FROM dim_customer)                                   AS total_customers,
    (SELECT COUNT(DISTINCT f2.customer_key)
       FROM fact_transactions f2
       JOIN dim_date d2 ON f2.date_key = d2.date_key
       WHERE d2.full_date >= DATE_SUB((SELECT MAX(full_date) FROM dim_date), INTERVAL 30 DAY)
    )                                                                     AS active_customers_30d,
    (SELECT COUNT(*) FROM accounts)                                       AS total_accounts,
    COUNT(*)                                                              AS total_transactions,
    ROUND(AVG(f.amount), 2)                                               AS avg_transaction_value,
    ROUND(SUM(f.amount), 2)                                               AS total_transaction_amount,
    SUM(f.is_failed)                                                      AS failed_transactions,
    ROUND(100 * SUM(f.is_failed) / COUNT(*), 2)                           AS failed_pct,
    SUM(f.is_flagged)                                                     AS flagged_transactions,
    ROUND(100 * SUM(f.is_flagged) / COUNT(*), 2)                          AS fraud_pct,
    (SELECT ROUND(AVG(balance), 2) FROM accounts)                        AS avg_account_balance,
    ROUND(SUM(CASE WHEN f.is_success = 1 THEN f.amount * 0.005 ELSE 0 END), 2) AS fee_revenue,
    (SELECT ROUND(SUM(balance) * 0.03, 2) FROM accounts WHERE status = 'Active') AS interest_margin_annual,
    ROUND(SUM(CASE WHEN f.is_success = 1 THEN f.amount * 0.005 ELSE 0 END)
          + (SELECT SUM(balance) * 0.03 FROM accounts WHERE status = 'Active'), 2) AS total_revenue_est
FROM fact_transactions f;


-- ---------------------------------------------------------------------
-- 2. v_monthly_trend  — volumes, value and fee revenue per month
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW v_monthly_trend AS
SELECT d.year, d.month, d.month_name,
       COUNT(*)                                                          AS transactions,
       ROUND(SUM(f.amount), 2)                                           AS total_amount,
       ROUND(SUM(CASE WHEN f.is_success = 1 THEN f.amount * 0.005 ELSE 0 END), 2) AS fee_revenue,
       SUM(f.is_failed)                                                  AS failed_transactions,
       SUM(f.is_flagged)                                                 AS flagged_transactions,
       COUNT(DISTINCT f.customer_key)                                    AS active_customers
FROM fact_transactions f
JOIN dim_date d ON f.date_key = d.date_key
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;


-- ---------------------------------------------------------------------
-- 3. v_monthly_growth  — month-over-month % change (uses LAG)
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW v_monthly_growth AS
SELECT year, month, month_name, transactions, total_amount,
       ROUND(100 * (transactions - LAG(transactions) OVER (ORDER BY year, month))
             / NULLIF(LAG(transactions) OVER (ORDER BY year, month), 0), 2) AS txn_growth_pct,
       ROUND(100 * (total_amount - LAG(total_amount) OVER (ORDER BY year, month))
             / NULLIF(LAG(total_amount) OVER (ORDER BY year, month), 0), 2) AS value_growth_pct
FROM v_monthly_trend;


-- ---------------------------------------------------------------------
-- 4. v_branch_performance  — compare branches (ranked by value)
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW v_branch_performance AS
SELECT b.branch_id, b.branch_name, b.city, b.state,
       COUNT(*)                                                          AS transactions,
       ROUND(SUM(f.amount), 2)                                           AS total_amount,
       ROUND(SUM(CASE WHEN f.is_success = 1 THEN f.amount * 0.005 ELSE 0 END), 2) AS fee_revenue,
       ROUND(100 * SUM(f.is_flagged) / COUNT(*), 2)                      AS fraud_pct,
       ROUND(100 * SUM(f.is_failed) / COUNT(*), 2)                       AS failed_pct,
       COUNT(DISTINCT f.customer_key)                                    AS active_customers
FROM fact_transactions f
JOIN dim_branch b ON f.branch_key = b.branch_key
GROUP BY b.branch_id, b.branch_name, b.city, b.state
ORDER BY total_amount DESC;


-- ---------------------------------------------------------------------
-- 5. v_top_cities  — which cities generate the most activity
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW v_top_cities AS
SELECT b.city,
       COUNT(*)                        AS transactions,
       ROUND(SUM(f.amount), 2)         AS total_amount,
       COUNT(DISTINCT f.customer_key)  AS customers
FROM fact_transactions f
JOIN dim_branch b ON f.branch_key = b.branch_key
GROUP BY b.city
ORDER BY transactions DESC;


-- ---------------------------------------------------------------------
-- 6. v_channel_popularity  — which channels customers use most
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW v_channel_popularity AS
SELECT c.channel_name,
       COUNT(*)                                                          AS transactions,
       ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM fact_transactions), 2) AS pct_of_total,
       ROUND(SUM(f.amount), 2)                                           AS total_amount
FROM fact_transactions f
JOIN dim_channel c ON f.channel_key = c.channel_key
GROUP BY c.channel_name
ORDER BY transactions DESC;


-- ---------------------------------------------------------------------
-- 7. v_customer_value  — simplified Customer Lifetime Value (CLV)
-- CLV = estimated annual fee revenue per customer x 5-year assumed tenure.
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW v_customer_value AS
WITH span AS (
    SELECT DATEDIFF(MAX(full_date), MIN(full_date)) + 1 AS days FROM dim_date
)
SELECT dc.customer_id, dc.full_name, dc.city,
       COUNT(*)                                                          AS transactions,
       ROUND(SUM(f.amount), 2)                                           AS total_spend,
       ROUND(SUM(CASE WHEN f.is_success = 1 THEN f.amount * 0.005 ELSE 0 END), 2) AS fee_revenue,
       ROUND(SUM(CASE WHEN f.is_success = 1 THEN f.amount * 0.005 ELSE 0 END)
             * (365.0 / (SELECT days FROM span)), 2)                     AS est_annual_revenue,
       ROUND(SUM(CASE WHEN f.is_success = 1 THEN f.amount * 0.005 ELSE 0 END)
             * (365.0 / (SELECT days FROM span)) * 5, 2)                 AS est_clv_5yr
FROM fact_transactions f
JOIN dim_customer dc ON f.customer_key = dc.customer_key
GROUP BY dc.customer_id, dc.full_name, dc.city
ORDER BY est_clv_5yr DESC;


-- ---------------------------------------------------------------------
-- 8. v_customer_segmentation  — group customers by activity + value
--   Inactive : no transaction in 90+ days
--   At-Risk  : last transaction 31-90 days ago
--   Premium  : active and spending > 2x the average customer
--   Standard : active, everyone else
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW v_customer_segmentation AS
WITH cust AS (
    SELECT dc.customer_id, dc.full_name,
           COUNT(*)          AS txns,
           SUM(f.amount)     AS total_spend,
           MAX(d.full_date)  AS last_txn_date
    FROM fact_transactions f
    JOIN dim_customer dc ON f.customer_key = dc.customer_key
    JOIN dim_date d      ON f.date_key     = d.date_key
    GROUP BY dc.customer_id, dc.full_name
),
params AS (
    SELECT (SELECT MAX(full_date) FROM dim_date) AS ref_date,
           (SELECT AVG(total_spend) FROM cust)   AS avg_spend
)
SELECT c.customer_id, c.full_name, c.txns,
       ROUND(c.total_spend, 2) AS total_spend,
       c.last_txn_date,
       DATEDIFF((SELECT ref_date FROM params), c.last_txn_date) AS days_since_last,
       CASE
           WHEN DATEDIFF((SELECT ref_date FROM params), c.last_txn_date) > 90 THEN 'Inactive'
           WHEN DATEDIFF((SELECT ref_date FROM params), c.last_txn_date) > 30 THEN 'At-Risk'
           WHEN c.total_spend > 2 * (SELECT avg_spend FROM params)            THEN 'Premium'
           ELSE 'Standard'
       END AS segment
FROM cust c;


-- ---------------------------------------------------------------------
-- 9. v_customer_risk  — a fraud risk score per customer
-- Weighted by alert severity: High=3, Medium=2, Low=1. 0 if no alerts.
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW v_customer_risk AS
SELECT dc.customer_id, dc.full_name,
       COUNT(fa.alert_id) AS alert_count,
       COALESCE(SUM(CASE fa.risk_level WHEN 'High' THEN 3
                                       WHEN 'Medium' THEN 2
                                       ELSE 1 END), 0) AS risk_score
FROM dim_customer dc
LEFT JOIN fraud_alerts fa ON fa.customer_id = dc.customer_id
GROUP BY dc.customer_id, dc.full_name
ORDER BY risk_score DESC;


-- =====================================================================
--  STORED PROCEDURES (parameterised KPIs)
-- =====================================================================
DROP PROCEDURE IF EXISTS sp_kpi_for_month;
DROP PROCEDURE IF EXISTS sp_top_customers;

DELIMITER $$

-- KPIs for one specific month, e.g.  CALL sp_kpi_for_month(2026, 1);
CREATE PROCEDURE sp_kpi_for_month(IN p_year INT, IN p_month INT)
BEGIN
    SELECT d.year, d.month_name,
           COUNT(*)                                                       AS transactions,
           ROUND(SUM(f.amount), 2)                                        AS total_amount,
           ROUND(SUM(CASE WHEN f.is_success = 1 THEN f.amount * 0.005 ELSE 0 END), 2) AS fee_revenue,
           SUM(f.is_failed)                                               AS failed_transactions,
           SUM(f.is_flagged)                                              AS flagged_transactions,
           ROUND(100 * SUM(f.is_flagged) / COUNT(*), 2)                   AS fraud_pct,
           COUNT(DISTINCT f.customer_key)                                 AS active_customers
    FROM fact_transactions f
    JOIN dim_date d ON f.date_key = d.date_key
    WHERE d.year = p_year AND d.month = p_month
    GROUP BY d.year, d.month_name;
END$$

-- The top N customers by lifetime value, e.g.  CALL sp_top_customers(10);
CREATE PROCEDURE sp_top_customers(IN p_limit INT)
BEGIN
    SELECT customer_id, full_name, city, transactions, total_spend, est_clv_5yr
    FROM v_customer_value
    ORDER BY est_clv_5yr DESC
    LIMIT p_limit;
END$$

DELIMITER ;


-- =====================================================================
--  HOW TO USE (examples)
-- =====================================================================
--   SELECT * FROM v_kpi_overview;
--   SELECT * FROM v_monthly_trend;
--   SELECT * FROM v_monthly_growth;
--   SELECT * FROM v_branch_performance;
--   SELECT * FROM v_top_cities;
--   SELECT * FROM v_channel_popularity;
--   SELECT * FROM v_customer_value LIMIT 20;
--   SELECT segment, COUNT(*) FROM v_customer_segmentation GROUP BY segment;
--   SELECT * FROM v_customer_risk WHERE risk_score > 0;
--   CALL sp_kpi_for_month(2026, 1);
--   CALL sp_top_customers(10);
-- =====================================================================
