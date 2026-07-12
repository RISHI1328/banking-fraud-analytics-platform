# Functional Requirement Specification (FRS)

**Project:** Banking Transaction Monitoring & Fraud Analytics Platform
**Client (fictional):** Meridian Retail Bank
**Document type:** Functional Requirement Specification
**Phase:** Phase 1 – Requirement Analysis

> This FRS translates the business needs in the BRD into precise, testable statements of *what the system must do*. Each functional requirement traces back to a business requirement (see Section 5).

---

## Document Control

| Field | Value |
|---|---|
| Version | 1.0 |
| Status | Approved for build |
| Author | Business Analyst (project owner) |
| Related document | Business Requirement Document (BRD) v1.0 |

---

## 1. Purpose & Scope

This document specifies the functional and non-functional requirements for the analytics platform described in the BRD. It is the reference used to build and later test each component. A requirement is written so that its outcome can be **verified** (tested), not just described.

---

## 2. Functional Requirements

Each requirement follows the same structure: description, input, processing, output, and priority.

### FR-01 – Transaction Streaming Simulator  *(→ BR-06)*
- **Description:** The system shall read transactions from a CSV file and insert them into the MySQL database one at a time to simulate a live feed.
- **Input:** Prepared transaction CSV; a configurable delay (2–5 seconds default).
- **Processing:** Read the next row, insert it into the transactions table, wait the configured delay, repeat.
- **Output:** Rows continuously appearing in the database; console log of each insert.
- **Priority:** Must have.

### FR-02 – Data Cleaning & Validation (ETL)  *(→ BR-07)*
- **Description:** The system shall validate and clean incoming transaction data before it is used for analytics.
- **Input:** Raw transaction records from the database/CSV.
- **Processing:** Handle missing values, correct data types, remove duplicates, and reject or repair invalid values (e.g., negative amounts, unknown status codes).
- **Output:** A cleaned dataset plus a summary of what was corrected or rejected.
- **Priority:** Must have.

### FR-03 – Rule-Based Fraud Detection  *(→ BR-02)*
- **Description:** The system shall evaluate transactions against defined fraud rules and raise a fraud alert with a reason when a rule fires.
- **Rules (initial set):**
  - R1: More than 5 transactions from one account within 2 minutes (velocity).
  - R2: A transaction amount far above the customer's usual average (amount anomaly).
  - R3: Transactions in two distant cities within an impossibly short time (impossible travel).
  - R4: High-value transactions during midnight hours.
  - R5: Multiple failed transactions immediately followed by a successful one (card testing).
- **Input:** Cleaned transaction data and each customer's transaction history.
- **Processing:** Apply each rule; on a match, create a fraud alert record referencing the transaction, customer, and the rule that fired.
- **Output:** Fraud alert records; a flag/reason on the transaction.
- **Priority:** Must have.

### FR-04 – Data Warehouse (Star Schema)  *(→ BR-01)*
- **Description:** The system shall organise cleaned data into a star schema optimised for reporting.
- **Input:** Cleaned transactional data.
- **Processing:** Load a central `fact_transactions` table linked to dimension tables (customer, account, branch, date, channel).
- **Output:** A query-friendly analytical model.
- **Priority:** Must have.

### FR-05 – Business KPIs  *(→ BR-01, BR-03, BR-04, BR-05)*
- **Description:** The system shall compute business KPIs using SQL views and stored procedures.
- **KPIs:** total customers, active customers, total revenue, average balance, total transactions, monthly growth, fraud %, failed transactions, average transaction value, simplified CLV, branch performance, top cities, customer segmentation, risk score.
- **Input:** Star-schema data.
- **Processing:** Aggregate and calculate each KPI.
- **Output:** Reusable views/procedures returning KPI values.
- **Priority:** Must have.

### FR-06 – Customer Segmentation & Inactivity  *(→ BR-03)*
- **Description:** The system shall classify customers by value and flag those becoming inactive.
- **Input:** Customer and transaction data.
- **Processing:** Segment by activity/value; flag customers with no recent transactions.
- **Output:** Segment labels and an inactivity flag per customer.
- **Priority:** Should have.

### FR-07 – Power BI Dashboard  *(→ BR-01 to BR-05)*
- **Description:** The system shall present results in a Power BI dashboard with executive, customer, branch, and fraud views.
- **Input:** KPI views and warehouse tables.
- **Processing:** Visualise KPIs, trends, comparisons, and fraud analytics.
- **Output:** An interactive dashboard readable by non-technical stakeholders.
- **Priority:** Must have.

---

## 3. Non-Functional Requirements

| ID | Requirement | Description |
|---|---|---|
| NFR-01 | Performance | Streaming shall run at a configurable 2–5 second interval to mirror near-real-time systems. |
| NFR-02 | Reliability | The ETL shall process invalid data without crashing and report on it. |
| NFR-03 | Explainability | Fraud detection shall be rule-based so every alert has a stated, auditable reason. |
| NFR-04 | Usability | The dashboard shall be understandable by non-technical executives. |
| NFR-05 | Portability | The solution shall run entirely on a local machine (no cloud/containers). |
| NFR-06 | Maintainability | Code shall be modular and commented; SQL shall be professionally formatted. |

---

## 4. Use Cases (illustrative)

**UC-1: Fraud analyst reviews an alert**
1. A streamed transaction triggers rule R2 (amount anomaly).
2. The system creates a fraud alert with the reason "amount far above customer average."
3. The analyst opens the fraud view in Power BI and sees the flagged transaction.
4. The analyst dispositions it as genuine fraud or a false alarm.

**UC-2: Executive checks bank health**
1. The executive opens the dashboard.
2. They view revenue, active customers, fraud %, and failure rate for the period.
3. They drill into branch comparison to see the top and bottom performers.

---

## 5. Requirement Traceability Matrix

*This matrix proves every business need is covered by a functional requirement — a classic BA artifact interviewers ask about.*

| Business Requirement | Met by Functional Requirement(s) |
|---|---|
| BR-01 – Executive KPI view | FR-04, FR-05, FR-07 |
| BR-02 – Fraud detection | FR-03 |
| BR-03 – Customer value & inactivity | FR-05, FR-06 |
| BR-04 – Branch comparison | FR-05, FR-07 |
| BR-05 – Transaction failures | FR-02, FR-05, FR-07 |
| BR-06 – Real-time simulation | FR-01 |
| BR-07 – Auditable pipeline | FR-02, FR-03, NFR-03, NFR-06 |

---

## 6. Acceptance Criteria (per requirement, summary)

- FR-01: Transactions appear in the database at the configured interval.
- FR-02: Known dirty records are cleaned or rejected and reported.
- FR-03: Each seeded fraud scenario raises the correct alert with a reason.
- FR-04: KPI queries run against the star schema without complex joins on raw tables.
- FR-05: Every listed KPI returns a value.
- FR-06: Customers receive a segment label and inactivity flag.
- FR-07: The dashboard displays all four views and updates from the data.
