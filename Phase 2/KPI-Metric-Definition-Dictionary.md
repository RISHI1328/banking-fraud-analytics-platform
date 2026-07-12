# KPI & Metric Definition Dictionary

**Project:** Banking Transaction Monitoring & Fraud Analytics Platform
**Phase:** Phase 2 – Business Understanding
**Status:** Definitions agreed; SQL implementation follows in Phase 9

> **Why this document exists:** A KPI is only useful if everyone computes it the same way. This dictionary gives each metric a single, precise business definition, a conceptual formula, its **grain** (the level it is measured at), the stakeholder who cares about it, and whether higher or lower is better. Later phases must implement these definitions exactly.

**How to read the "conceptual formula" column:** these are plain-English formulas, not final SQL. The SQL versions are built in Phase 9 and must match these definitions.

---

## Core KPIs

| KPI | Business definition | Conceptual formula | Grain | Primary stakeholder | Better when |
|---|---|---|---|---|---|
| Total Customers | Number of unique customers on the books | count of distinct customers | Bank / branch | Executive | Higher |
| Active Customers | Customers who transacted recently | distinct customers with ≥1 transaction in the **last 30 days** | Bank / branch | Executive, Relationship | Higher |
| Total Revenue | Money the bank earned in the period | sum of revenue components (fees + interchange + modelled interest margin) | Bank / branch / month | Executive | Higher |
| Average Account Balance | Typical balance held | total balance ÷ number of accounts | Bank / branch | Executive | Context-dependent |
| Total Transactions | Volume of transactions in the period | count of transactions | Bank / branch / month | Operations | Higher (with low failure) |
| Average Transaction Value | Typical transaction size | total transaction amount ÷ number of transactions | Bank / channel | Operations | Context-dependent |
| Monthly Growth | Change vs the previous month | (this month − last month) ÷ last month × 100 | Month | Executive | Higher |

## Risk & Reliability KPIs

| KPI | Business definition | Conceptual formula | Grain | Primary stakeholder | Better when |
|---|---|---|---|---|---|
| Fraud Percentage | Share of transactions flagged/confirmed as fraud | fraud-flagged transactions ÷ total transactions × 100 | Bank / branch / city | Fraud lead | Lower |
| Failed Transactions | Volume and share of failed transactions | count (and %) where status = failed | Bank / channel / city | Operations | Lower |
| Risk Score | A per-customer score reflecting suspicious behaviour | weighted count of fraud signals/rules triggered by that customer | Customer | Fraud lead | Lower |

## Customer-Value KPIs

| KPI | Business definition | Conceptual formula | Grain | Primary stakeholder | Better when |
|---|---|---|---|---|---|
| Customer Lifetime Value (simplified) | Estimated total profit a customer brings | average annual revenue per customer × expected tenure (years) | Customer | Marketing | Higher |
| Customer Segmentation | Grouping customers by value and activity | classify into segments (e.g., Premium / Standard / At-risk / Inactive) using value + recent activity | Customer | Marketing, Relationship | — |

## Location & Branch KPIs

| KPI | Business definition | Conceptual formula | Grain | Primary stakeholder | Better when |
|---|---|---|---|---|---|
| Branch Performance | How a branch compares overall | ranking of branches by revenue and transaction volume (and active customers) | Branch | Head of Retail | Higher rank |
| Top Cities | Cities driving the most activity | cities ranked by transaction count and/or value | City | Executive | — |

---

## Definitions of Key Terms Used Above

- **Active window:** the fixed look-back period that defines "active." We use **30 days** unless a specific report states otherwise. Documenting this prevents inconsistent numbers.
- **Grain:** the level of detail at which a metric is measured (e.g., per customer, per branch, per month). Mixing grains is a common source of wrong totals.
- **Revenue proxy:** because this is a portfolio project on synthetic data, revenue is modelled from transaction fees, interchange, and a simple interest margin. The exact model is fixed during dataset preparation (Phase 4) and then implemented consistently.
- **Fraud-flagged:** a transaction for which at least one fraud rule fired (Phase 7).

---

## Notes for Later Phases

1. Phase 4 (dataset) must generate the fields these KPIs depend on: transaction amount, status, channel, timestamp, city, branch, customer, and balances.
2. Phase 8 (warehouse) must expose these at the right grain via the star schema.
3. Phase 9 (KPIs) must implement each formula above **exactly** as a SQL view or stored procedure.
4. Phase 10 (Power BI) must display the KPIs using these same definitions, so the dashboard and the database always agree.
