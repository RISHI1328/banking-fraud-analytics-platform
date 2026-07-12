# Phase 6 – ETL Pipeline (Data Cleaning & Validation)

## Phase Objective
Build an ETL pipeline that extracts raw transactions from a permissive staging table, validates and cleans them, produces a data-quality report, and loads only the clean rows into the strict `transactions` table.

## Business Objective
Analytics and fraud detection are only as trustworthy as the underlying data. This phase proves the data is clean and documents exactly what was wrong with anything rejected — the "garbage in, garbage out" safeguard.

## Banking Context
Banks receive data from many systems and channels, so raw feeds contain errors. Real pipelines land raw data in a staging area, validate it, and promote only clean records to production — exactly what this notebook demonstrates.

## Folder Structure (this phase)
```
Phase-06-ETL-Pipeline/
├── README.md
└── Phase-06-ETL-Pipeline.ipynb
datasets/
└── etl_rejected_rows.csv        (audit log created when you run the notebook)
```

## Files Created
| File | Purpose |
|---|---|
| Phase-06-ETL-Pipeline.ipynb | Creates a staging table, injects clean + dirty rows, validates/cleans them, reports rejections, and loads clean rows into `transactions`. |
| datasets/etl_rejected_rows.csv | Audit log of every rejected row with the reason(s) it failed. |

## Technologies Used
Python, pandas, mysql-connector-python, Jupyter Notebook, MySQL.

## Prerequisites
- Phases 3–5 complete (schema built; `accounts` populated; `transactions` loaded).
- `pip install pandas mysql-connector-python jupyter`

## Execution Steps
1. Open `Phase-06-ETL-Pipeline.ipynb` and set your MySQL `password`.
2. Run all cells top to bottom.
3. Read the "Data-quality report" cell output — it lists how many rows were rejected and why.
4. The clean rows are loaded into `transactions`; the verification cell prints the new total.

## Expected Output
- A `transactions_staging` table containing 16 injected rows (6 clean, 10 dirty).
- A rejection report showing 10 rejected rows grouped by reason (missing/orphan account, non-positive/non-numeric amount, invalid status/channel, invalid/out-of-range timestamp, duplicate).
- 6 clean rows loaded into `transactions` (its total rises by 6).
- `datasets/etl_rejected_rows.csv` written for audit.

## Screenshots
_Placeholder — add a screenshot of the rejection report and the etl_rejected_rows.csv._

## Learning Outcomes
- You can explain ETL (Extract, Transform, Load) and why staging tables exist.
- You can write validation rules for required fields, controlled vocabularies, ranges, references, and duplicates.
- You understand transformation (trimming, case-standardizing, type-coercion) versus rejection.
- You can produce a data-quality report and an audit trail of rejected data.

## Interview Questions
1. **What is ETL and why is it important?**
   Extract, Transform, Load — the process of moving and cleaning data so analytics run on trustworthy inputs.
2. **Why use a staging table instead of loading straight into production?**
   Raw data can be dirty; staging is permissive so it can hold bad rows for inspection, while the strict production table only receives validated rows.
3. **What kinds of data-quality checks did you implement?**
   Missing required fields, invalid values (non-positive amounts, unknown status/channel), orphan foreign keys, invalid/out-of-range dates, and duplicates.
4. **What is the difference between cleaning and rejecting a row?**
   Cleaning fixes recoverable issues (trim spaces, standardize case, coerce types); rejecting removes rows with unrecoverable problems, logged with reasons.
5. **How do you prove data quality to stakeholders?**
   With a data-quality report (counts by issue) and an audit file of rejected rows and their reasons.

## Troubleshooting Tips
- **`Table 'transactions_staging' already exists`:** the notebook drops it first; re-run from the top.
- **Everything rejected as "orphan account_id":** `accounts` isn't populated — run Phase 4 first.
- **All timestamps "out of range":** the `transactions` table is empty, so the valid date range couldn't be computed — run Phase 5 (bulk) first.
- **Re-running adds clean rows again:** each run injects and loads its 6 clean rows; that's expected. To avoid slow growth, you can skip the load cell on repeat runs.
