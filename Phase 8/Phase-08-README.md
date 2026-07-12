# Phase 8 – Data Warehouse (Star Schema)

## Phase Objective
Reshape the normalized OLTP data into a star schema — one `fact_transactions` table surrounded by `dim_date`, `dim_customer`, `dim_branch`, and `dim_channel` — optimized for fast analytical reporting.

## Business Objective
Give the dashboard and KPIs a data model that answers business questions with simple, fast queries, so leadership gets consistent numbers without complex multi-table joins.

## Banking Context
Banks separate the systems that *run* the bank (OLTP) from the systems that *report* on it (OLAP). Loading a star-schema warehouse from operational data is the standard way analytics teams prepare data for BI tools.

## Folder Structure (this phase)
```
Phase-08-Data-Warehouse/
├── README.md
├── star_schema.sql            (build + populate the warehouse)
└── Star-Schema-Diagram.md     (visual diagram + explanation)
```

## Files Created
| File | Purpose |
|---|---|
| star_schema.sql | Creates and populates the fact and dimension tables from the OLTP tables. Re-runnable. |
| Star-Schema-Diagram.md | Mermaid star-schema diagram (renders on GitHub) and OLTP-vs-OLAP notes. |

## Technologies Used
MySQL 8 (recursive CTE for the date dimension, window-free aggregate loads, surrogate keys).

## Prerequisites
- Phases 3–5 complete (the `transactions`, `accounts`, `customers`, `branches` tables are populated).
- MySQL Workbench.

## Execution Steps
1. Open `star_schema.sql` in MySQL Workbench.
2. Run the **whole file** ("Execute SQL Script" — the plain lightning bolt, not the one with a cursor).
3. Refresh the schema panel; you should see `dim_date`, `dim_customer`, `dim_branch`, `dim_channel`, and `fact_transactions`.
4. Try a sample query from the bottom of the script (they are commented out).

## Expected Output
- Four dimension tables populated (dim_date ~270 rows, dim_customer 500, dim_branch 8, dim_channel 6).
- `fact_transactions` with one row per transaction (~20,000+), each linked to its dimensions.
- Sample queries like "monthly volume" or "fraud rate by branch" run with only one or two joins.

## Screenshots
_Placeholder — add a screenshot of the five warehouse tables and one sample analytical query result._

## Learning Outcomes
- You can explain OLTP vs OLAP and why a star schema suits reporting.
- You understand fact vs dimension tables and the "grain" of a fact table (one row per transaction here).
- You can build a date dimension and use surrogate keys.
- You can load a warehouse from operational tables with INSERT ... SELECT joins.

## Interview Questions
1. **What is a star schema and why use it for analytics?**
   A central fact table surrounded by dimension tables; it needs fewer joins and is what BI tools are optimised for.
2. **Fact vs dimension table?**
   Facts hold measurements (amount, counts) at a defined grain; dimensions hold descriptive attributes you filter/group by.
3. **What is the grain of your fact table?**
   One row per transaction.
4. **What is a surrogate key and why use one?**
   A warehouse-generated key (e.g., customer_key) independent of the operational id, which insulates the model from source changes.
5. **Why build a separate date dimension?**
   It pre-computes calendar attributes (month, quarter, weekday, weekend) so time analysis is a simple GROUP BY.
6. **OLTP vs OLAP?**
   OLTP is write-optimised and normalized (runs the bank); OLAP is read-optimised and denormalized (reports on the bank).

## Troubleshooting Tips
- **`Unknown column 'transaction_id'`-style errors:** run the whole script, not a partial selection (the fact insert depends on the dimensions existing first).
- **`Cannot add or update a child row` on the fact insert:** a dimension wasn't populated — run the script top to bottom so dimensions load before the fact.
- **dim_date is empty:** the `transactions` table is empty — load it in Phase 5 first.
- **Re-running:** the script drops the warehouse tables first, so it rebuilds cleanly each time.
