# Phase 5 – Transaction Simulator

## Phase Objective
Load the `transactions.csv` feed (from Phase 4) into the MySQL `transactions` table, with a fast bulk mode for populating data and a slow "live" mode that streams one transaction every 2–5 seconds to imitate a real-time feed.

## Business Objective
Real banks process transactions as a continuous live stream. Simulating that stream lets us build and demonstrate a real-time fraud-monitoring pipeline — and populates the data every later phase (ETL, fraud, KPIs, dashboard) needs.

## Banking Context
Enterprise systems ingest transactions in real time, often through message queues (e.g., Kafka) feeding a database. Since live bank feeds aren't publicly available, we replay a CSV: bulk-load history, then stream recent transactions one at a time.

## Folder Structure (this phase)
```
Phase-05-Transaction-Simulator/
├── README.md
└── Phase-05-Transaction-Simulator.ipynb
```

## Files Created
| File | Purpose |
|---|---|
| Phase-05-Transaction-Simulator.ipynb | Reads transactions.csv and inserts rows into MySQL in bulk or live-stream mode. |

## Technologies Used
Python, pandas, mysql-connector-python, Jupyter Notebook.

## Prerequisites
- Phases 3 and 4 complete (schema built; `datasets/transactions.csv` exists; dimension tables populated).
- `pip install pandas mysql-connector-python jupyter`

## Execution Steps
1. Open `Phase-05-Transaction-Simulator.ipynb`.
2. In the Configuration cell, set your MySQL `password`.
3. Leave `MODE = "bulk"` and run all cells — this loads every transaction into MySQL. Run this first.
4. To see the real-time effect: set `MODE = "live"`, then run the imports, connect, load, and run cells again. It streams the most recent `LIVE_LIMIT` transactions, printing each with a 2–5 second gap.
5. Adjust `MIN_DELAY` / `MAX_DELAY` to speed up or slow down the stream, and `LIVE_LIMIT` for how many to stream.

## Expected Output
- After bulk mode: the `transactions` table holds all ~20,000+ rows, and the verification cell prints the total plus a Success/Failed/Reversed breakdown.
- In live mode: a line prints for each streamed transaction, a few seconds apart.

## Screenshots
_Placeholder — add a screenshot of the live-stream printout and of `SELECT COUNT(*) FROM transactions;` in Workbench._

## Learning Outcomes
- You can read a CSV in Python and insert it into MySQL safely using parameterised queries.
- You understand why blanks are converted to `NULL` and why numeric strings are read as text (to avoid float corruption).
- You can explain bulk loading (`executemany` in batches) versus row-by-row streaming.
- You can explain how this simulates a real-time enterprise ingestion pipeline.

## Interview Questions
1. **Why use parameterised queries (`%s`) instead of building SQL strings?**
   They are filled safely by the connector, preventing SQL injection and quoting bugs.
2. **What is the difference between `execute` and `executemany`?**
   `execute` runs one statement; `executemany` sends many rows in one call — far faster for bulk loads.
3. **Why commit in batches during a bulk load?**
   It balances speed and safety — you don't hold one giant transaction open, and progress is saved incrementally.
4. **How does this simulate a real-time system?**
   Live mode inserts one transaction at a time with a short delay, mimicking a continuous production feed.
5. **Why read long numeric fields as text?**
   Read as numbers, a 12-digit account number can lose precision or become scientific notation; as text it stays exact.

## Troubleshooting Tips
- **`FileNotFoundError: datasets/transactions.csv`:** run the Phase 4 notebook first, and run this notebook from the same project folder.
- **`Cannot add or update a child row` (FK error):** a transaction references an account that doesn't exist — make sure Phase 4 populated `accounts` (don't clear it between phases).
- **Live mode feels slow:** that's intentional; lower `MIN_DELAY`/`MAX_DELAY` (e.g., 0.5 and 1.0) for a quicker demo.
- **Duplicate rows after running live then bulk:** re-run bulk with `TRUNCATE_FIRST = True` for a clean load.
