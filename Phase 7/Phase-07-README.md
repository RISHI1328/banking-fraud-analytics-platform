# Phase 7 – Fraud Detection

## Phase Objective
Detect suspicious transactions using explainable, rule-based logic — in both SQL and Python — write the results to the `fraud_alerts` table, and measure the detection rate against the seeded ground truth.

## Business Objective
Catch likely fraud early with transparent rules an analyst and a regulator can both audit, and quantify how well the detection works — turning "we monitor for fraud" into "we detect X% of known fraud with a stated reason for each alert."

## Banking Context
Regulated banks favour explainable rule-based detection because every alert must be justifiable. Machine learning is a valid future enhancement but harder to defend decision-by-decision.

## The five rules
| Rule | Fires when | Fraud it targets |
|---|---|---|
| Velocity | > 5 transactions on an account within 2 minutes | card testing, account takeover |
| Amount Anomaly | amount > 8x the account's average | compromised account |
| Impossible Travel | two different cities within 60 minutes | cloned card |
| Midnight High Value | large amount (> 5x avg) between 00:00–04:59 | unauthorised access |
| Card Testing | 3+ failed attempts before a success (within 5 min) | stolen card being validated |

## Folder Structure (this phase)
```
Phase-07-Fraud-Detection/
├── README.md
├── fraud_rules.sql                 (SQL detection views)
└── Phase-07-Fraud-Detection.ipynb  (Python detection + scoring)
```

## Files Created
| File | Purpose |
|---|---|
| fraud_rules.sql | Five window-function views (one per rule) plus a combined `v_fraud_all` view; run in Workbench to inspect flagged transactions. |
| Phase-07-Fraud-Detection.ipynb | Runs the same rules in Python, writes alerts to `fraud_alerts`, flags transactions, and scores against `fraud_ground_truth.csv`. |

## Technologies Used
MySQL 8 window functions, Python, pandas, numpy, mysql-connector-python.

## Prerequisites
- Phases 3–5 complete with the full ~20,000 transactions loaded.
- `datasets/fraud_ground_truth.csv` present (from Phase 4).
- `pip install pandas numpy mysql-connector-python jupyter`

## Execution Steps
**SQL (optional, to inspect in the database):**
1. Open `fraud_rules.sql` in MySQL Workbench and run it (creates the views).
2. Run `SELECT rule_triggered, COUNT(*) FROM v_fraud_all GROUP BY rule_triggered;`

**Python (writes alerts and scores):**
1. Open `Phase-07-Fraud-Detection.ipynb`, set your MySQL `password`.
2. Run all cells. It flags transactions, populates `fraud_alerts`, and prints the detection rate by fraud type.

> Run **either** the notebook **or** the SQL insert block in `fraud_rules.sql` — not both — so alerts aren't duplicated. The notebook is recommended because it also scores the results.

## Expected Output
- Each rule prints how many transactions it flagged.
- `fraud_alerts` is populated; matching transactions get `is_flagged = TRUE`.
- A detection-rate table showing each seeded fraud type caught (expect high rates — the rules are tuned to the seeded patterns).
- A note on alerts that don't match a seeded case (additional flags / possible false positives — a good false-positive discussion point).

## Screenshots
_Placeholder — add the detection-rate table and a `SELECT * FROM fraud_alerts LIMIT 10;` screenshot._

## Learning Outcomes
- You can implement fraud rules with SQL window functions (COUNT/SUM/LAG over partitioned, time-ordered frames).
- You can implement the same rules in Python/pandas and explain the trade-offs.
- You can measure detection against a labelled ground truth and reason about false positives vs false negatives.
- You can explain why rule-based detection is preferred in regulated banking.

## Interview Questions
1. **Why rule-based rather than machine learning?**
   Explainability and auditability — every alert has a clear, defensible reason, which regulators require.
2. **Explain the false positive vs false negative trade-off.**
   A false positive blocks a genuine customer (annoyance, lost business); a false negative lets real fraud through (loss + regulatory risk). Thresholds balance the two.
3. **How does the velocity rule work in SQL?**
   A COUNT over a window partitioned by account, ordered by time, with a `RANGE BETWEEN INTERVAL 2 MINUTE PRECEDING AND CURRENT ROW` frame; flag counts above the threshold.
4. **How did you measure detection?**
   By scoring alerts against a seeded ground-truth file and reporting the detection rate per fraud type.
5. **How would you reduce false positives?**
   Tune thresholds, combine signals (require two rules), add allow-lists for known behaviour, or add a review step before action.

## Troubleshooting Tips
- **Very few alerts:** confirm `transactions` has the full ~20,000 rows (re-run Phase 5 bulk if not) — the seeded fraud lives across the whole history.
- **`Unknown column` in a view:** ensure you ran the Phase 3 schema (column names must match).
- **Duplicate alerts:** you ran both the SQL insert and the notebook — re-run the notebook (it truncates `fraud_alerts` first) to reset.
- **Detection rate lower than expected:** thresholds are tunable at the top of the notebook; loosening them catches more (but raises false positives).
