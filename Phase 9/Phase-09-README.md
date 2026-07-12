# Phase 9 – Business KPIs (SQL Views & Stored Procedures)

## Phase Objective
Turn the Phase 2 KPI dictionary into reusable SQL on top of the star schema: views for standing KPIs and stored procedures for parameterized ones. These become the direct data source for the Power BI dashboard.

## Business Objective
Give every stakeholder consistent, single-definition metrics — revenue, active customers, fraud %, branch performance, customer value and segmentation — that the dashboard can read without re-deriving logic.

## Banking Context
Revenue is modeled as a documented proxy suitable for a portfolio project: a 0.5% fee on successful transactions plus a 3% annual net interest margin on active balances. Real banks use richer models, but this captures the two main retail revenue sources (fees and interest spread).

## Folder Structure (this phase)
```
Phase-09-Business-KPIs/
├── README.md
└── kpi_views.sql          (9 views + 2 stored procedures)
```

## Files Created
| File | Purpose |
|---|---|
| kpi_views.sql | Creates all KPI views and stored procedures. Re-runnable. |

## KPI objects
| Object | KPIs it provides |
|---|---|
| v_kpi_overview | total & active customers, total/avg transactions, failed %, fraud %, avg balance, fee revenue, interest margin, total revenue |
| v_monthly_trend | transactions, value, fee revenue, failures, fraud, active customers per month |
| v_monthly_growth | month-over-month % growth in volume and value |
| v_branch_performance | per-branch value, fee revenue, fraud %, failed %, active customers |
| v_top_cities | activity by city |
| v_channel_popularity | transaction share by channel |
| v_customer_value | simplified Customer Lifetime Value (5-year) |
| v_customer_segmentation | Premium / Standard / At-Risk / Inactive segments |
| v_customer_risk | fraud risk score per customer |
| sp_kpi_for_month(year, month) | KPIs for a chosen month |
| sp_top_customers(n) | top N customers by lifetime value |

## Technologies Used
MySQL 8: views, CTEs, window functions (LAG), and stored procedures with parameters.

## Prerequisites
- Phases 3–8 complete (the star schema and fraud_alerts are populated).
- MySQL Workbench.

## Execution Steps
1. Open `kpi_views.sql` and run the **whole file** (Execute SQL Script).
2. Query any view, e.g. `SELECT * FROM v_kpi_overview;`
3. Call a procedure, e.g. `CALL sp_kpi_for_month(2026, 1);` or `CALL sp_top_customers(10);`

## Expected Output
- Nine views and two stored procedures created.
- `v_kpi_overview` returns a single summary row.
- The other views return the per-month / per-branch / per-customer breakdowns used by the dashboard.

## Screenshots
_Placeholder — add screenshots of v_kpi_overview and v_branch_performance results._

## Learning Outcomes
- You can implement KPIs as SQL views and explain view vs stored procedure.
- You can model a simple revenue proxy and defend the assumptions.
- You can build segmentation and CLV logic in SQL.
- You understand why standing KPIs live in the database as a single source of truth.

## Interview Questions
1. **View vs stored procedure — when to use each?**
   A view is a saved query used like a table (great for standing KPIs); a stored procedure is a saved program that takes parameters and runs multi-step logic (great for per-month or top-N requests).
2. **How did you model revenue?**
   A 0.5% fee on successful transactions plus a 3% annual interest margin on active balances — a documented proxy for retail fee and interest income.
3. **How is a customer marked "active"?**
   At least one transaction in the last 30 days relative to the latest data date.
4. **How did you segment customers?**
   By recency and value: Inactive (90+ days), At-Risk (31–90 days), Premium (active and spending above 2x average), else Standard.
5. **How is the risk score computed?**
   Sum of a customer's fraud alerts weighted by severity (High=3, Medium=2, Low=1).
6. **Why put KPI logic in the database rather than in Power BI?**
   To keep one authoritative definition so every consumer reports the same number.

## Troubleshooting Tips
- **Procedure creation error around `$$`:** run the whole script so the `DELIMITER` commands are applied (Workbench handles them); don't run only the CREATE PROCEDURE lines.
- **A view returns nothing:** the star schema isn't populated — run Phase 8 first.
- **fraud_pct is 0 everywhere:** run Phase 7, then re-run Phase 8 so `is_flagged` is carried into the fact (or ensure the fact was built after fraud detection).
- **Re-running:** views use CREATE OR REPLACE and procedures are dropped first, so the script is safe to re-run.
