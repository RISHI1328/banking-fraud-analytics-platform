# Phase 4 – Dataset Preparation

## Phase Objective
Fill the Phase 3 database with realistic **synthetic** data using Python and the `Faker` library, and produce the transaction feed (`transactions.csv`) plus a labelled set of seeded fraud cases (`fraud_ground_truth.csv`).

## Business Objective
Realistic data lets us build and demonstrate every later feature — KPIs, fraud rules, dashboards — without needing real (and privacy-sensitive) banking data. Seeding **known** fraud cases means we can later prove our detection rules actually work.

## Banking Context
Real banks cannot share live customer data, so analytics teams routinely build with synthetic data. Generating a labelled fraud set mirrors how fraud teams evaluate detection systems against known cases.

## Folder Structure (this phase)
```
Phase-04-Dataset-Preparation/
├── README.md
└── Phase-04-Generate-Data.ipynb      (the notebook)
datasets/
├── transactions.csv                  (created when you run the notebook)
└── fraud_ground_truth.csv            (created when you run the notebook)
```

## Files Created
| File | Purpose |
|---|---|
| Phase-04-Generate-Data.ipynb | Connects to MySQL, generates & inserts branches/employees/customers/accounts/cards/loans, then builds transactions + seeded fraud and saves them to CSV. |
| datasets/transactions.csv | The transaction feed streamed into MySQL in Phase 5. |
| datasets/fraud_ground_truth.csv | Labels of every seeded fraud row, used to measure detection accuracy in Phase 7. |

## Technologies Used
Python, Faker, pandas, numpy, mysql-connector-python, Jupyter Notebook.

## Prerequisites
- Phase 3 schema already run (the 8 tables exist in `federal_bank`).
- Python with: `pip install faker mysql-connector-python pandas numpy jupyter`

## Execution Steps
1. Open `Phase-04-Generate-Data.ipynb` in Jupyter (or VS Code).
2. In the **Configuration** cell, set your MySQL `password`.
3. Run all cells top to bottom.
4. Watch the printouts confirm rows inserted, then check MySQL Workbench — `branches`, `employees`, `customers`, `accounts`, `cards`, `loans` are now populated.
5. Confirm `datasets/transactions.csv` and `datasets/fraud_ground_truth.csv` were created.

## Expected Output
- Six MySQL tables populated (roughly: 8 branches, 40 employees, 500 customers, ~650 accounts, ~450 cards, ~100 loans — exact counts vary).
- `transactions.csv` with ~20,000+ rows (normal + seeded fraud).
- `fraud_ground_truth.csv` with the seeded fraud labels (velocity, amount_anomaly, impossible_travel, midnight_high_value, card_testing).
- The `transactions` and `fraud_alerts` tables stay **empty** — that is expected. Transactions are loaded in Phase 5; alerts are created in Phase 7.

## Screenshots
_Placeholder — add a screenshot of the populated tables in MySQL Workbench and of the notebook's sanity-check output._

## Learning Outcomes
- You can generate realistic synthetic data with Faker and insert it into MySQL from Python.
- You understand why a fixed random seed makes a dataset reproducible.
- You can explain why we read auto-generated ids back before inserting child rows (foreign keys).
- You understand the value of a labelled "ground truth" set for evaluating fraud detection.

## Interview Questions
1. **Why use synthetic data?**
   Real banking data is private and regulated; synthetic data lets you build and demo safely with no PII risk.
2. **Why set a random seed?**
   So the exact same dataset is produced every run — important for reproducible testing and debugging.
3. **Why insert parents (branches, customers) before children (accounts, transactions)?**
   Foreign keys require the referenced row to exist first; we also read back the generated ids to link children correctly.
4. **What is a "ground truth" fraud set and why create one?**
   A labelled list of known fraud cases; it lets you measure how many your rules catch (detection rate) and how many false positives they raise.
5. **Why generate transactions with realistic distributions and per-account spend profiles?**
   So KPIs and fraud rules behave like they would on real, varied data — e.g. the amount-anomaly rule only makes sense if each account has a believable "normal".

## Troubleshooting Tips
- **Access denied for user:** check the `password` in the Configuration cell.
- **Unknown database 'federal_bank':** run the Phase 3 `schema.sql` first.
- **`No module named 'faker'`:** `pip install faker mysql-connector-python`.
- **Duplicate entry error (very rare):** an account/card number randomly collided — just re-run the notebook.
- **Re-running:** the notebook truncates all tables first, so re-running rebuilds cleanly (this erases prior generated data, which is expected here).
