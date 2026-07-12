# Phase 3 – Database Design

## Phase Objective
Design and build the bank's operational (OLTP) database: eight normalized tables that store customers, accounts, branches, cards, loans, employees, transactions, and fraud alerts, with proper keys, constraints, and indexes.

## Business Objective
Give the project a reliable, consistent foundation of data. Good OLTP design prevents duplicate and invalid data, which means every KPI and fraud rule built later is computed from trustworthy records.

## Banking Context
Banks run on OLTP databases that must record transactions accurately and instantly. This schema mirrors a real retail bank's core entities and the relationships between them, and stores money as `DECIMAL` so figures are exact.

## Folder Structure (this phase)
```
Phase-03-Database-Design/
├── README.md              (this file)
├── schema.sql             (runnable MySQL DDL — creates all 8 tables)
├── Data-Dictionary.md     (every table & column explained)
└── ER-Diagram.md          (Mermaid entity-relationship diagram)
```
*(In the full repo, `schema.sql` also belongs under the top-level `sql/` folder.)*

## Files Created
| File | Purpose |
|---|---|
| schema.sql | MySQL script that creates the `federal_bank` database and all tables, keys, constraints, and indexes. Re-runnable. |
| Data-Dictionary.md | Column-level reference for all eight tables. |
| ER-Diagram.md | Visual ER diagram (renders on GitHub) plus interview talking points. |
| README.md | Overview and learning material for this phase. |

## Technologies Used
MySQL 8 (MySQL Workbench). The DDL was validated as syntactically correct MySQL.

## Prerequisites
- MySQL Server and MySQL Workbench installed and running locally.
- Phases 0–2 completed (so the tables match the agreed KPI needs).

## Installation / Execution Steps
1. Open MySQL Workbench and connect to your local server.
2. Open `schema.sql`.
3. Execute the whole script (lightning-bolt icon). It creates the `federal_bank` database and all tables.
4. Refresh the schema panel and confirm eight tables appear under `federal_bank`.

## Expected Output
A `federal_bank` database containing: `branches`, `employees`, `customers`, `accounts`, `cards`, `loans`, `transactions`, `fraud_alerts` — all empty, ready for data in Phase 4.

## Screenshots
_Placeholder — add a screenshot of the eight tables in the Workbench schema panel once created._

## Learning Outcomes
- You can explain OLTP vs OLAP and why we design OLTP first.
- You understand 1NF, 2NF, 3NF and can point to where this schema applies them.
- You can explain primary keys, foreign keys, and why `InnoDB` is required for FKs.
- You know why money uses `DECIMAL`, and why indexes are added on the columns fraud rules filter on.

## Interview Questions
1. **What is normalization and why do it?**
   Organizing tables so each fact is stored once, preventing redundancy and update anomalies. This schema is in 3NF.
2. **Difference between a primary key and a foreign key?**
   A primary key uniquely identifies a row; a foreign key references a primary key in another table to enforce valid relationships.
3. **Why store money as DECIMAL, not FLOAT?**
   FLOAT is approximate and causes rounding errors; DECIMAL stores exact values — essential for money.
4. **Why is the InnoDB engine used?**
   It supports foreign keys and transactions (ACID), unlike MyISAM.
5. **Why index `transaction_timestamp` and (account_id, transaction_timestamp)?**
   Fraud rules query transactions for one account within a time window; these indexes make those lookups fast.
6. **Why is `card_id` nullable on transactions?**
   Not every transaction uses a card (e.g., UPI or bank transfers), so the relationship is optional.
7. **What is OLTP vs OLAP?**
   OLTP is the live operational database optimized for writes/integrity; OLAP (the star schema in Phase 8) is optimized for analytical reads.

## Troubleshooting Tips
- **"Cannot add foreign key constraint":** ensure the parent table exists and the referenced column types match exactly (both `INT`, etc.).
- **Tables not appearing:** right-click the schema panel and choose Refresh.
- **Re-running the script:** it drops tables first, so re-running gives a clean rebuild (this also erases any data — expected in this phase).
- **CHECK constraints not enforced:** ensure you are on MySQL 8.0.16+ (older versions parse but ignore CHECK).
