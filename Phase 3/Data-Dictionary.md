# Data Dictionary

**Project:** Banking Transaction Monitoring & Fraud Analytics Platform
**Database:** `federal_bank` (OLTP)
**Phase:** Phase 3 – Database Design

> A data dictionary is the reference that explains every table and column: its data type, rules (constraints), and meaning. Analysts, developers, and reviewers all rely on it so nobody has to guess what a column holds. Keys: **PK** = Primary Key, **FK** = Foreign Key, **U** = Unique.

---

## 1. branches
Physical bank locations. Parent of `accounts`, `employees`, and `loans`.

| Column | Type | Key / Constraint | Description |
|---|---|---|---|
| branch_id | INT | PK, auto-increment | Unique branch identifier |
| branch_name | VARCHAR(100) | NOT NULL | Branch display name |
| ifsc_code | VARCHAR(11) | U, NOT NULL | Indian branch routing code |
| city | VARCHAR(50) | NOT NULL | Branch city |
| state | VARCHAR(50) | NOT NULL | Branch state |
| opened_date | DATE | NOT NULL | Date the branch opened |
| created_at | TIMESTAMP | default now | Row insert time |

## 2. employees
Bank staff. Fraud analysts who review alerts are stored here.

| Column | Type | Key / Constraint | Description |
|---|---|---|---|
| employee_id | INT | PK, auto-increment | Unique employee id |
| branch_id | INT | FK → branches | Branch the employee works at |
| first_name | VARCHAR(50) | NOT NULL | Given name |
| last_name | VARCHAR(50) | NOT NULL | Family name |
| role | ENUM | NOT NULL | Teller / Branch Manager / Fraud Analyst / Operations |
| email | VARCHAR(100) | U, NOT NULL | Work email (unique) |
| hire_date | DATE | NOT NULL | Employment start date |
| created_at | TIMESTAMP | default now | Row insert time |

## 3. customers
People who bank with Meridian. Parent of `accounts` and `loans`.

| Column | Type | Key / Constraint | Description |
|---|---|---|---|
| customer_id | INT | PK, auto-increment | Unique customer id |
| first_name | VARCHAR(50) | NOT NULL | Given name |
| last_name | VARCHAR(50) | NOT NULL | Family name |
| gender | ENUM | nullable | Male / Female / Other |
| date_of_birth | DATE | nullable | Date of birth |
| email | VARCHAR(100) | U (nullable) | Email; unique when present |
| phone | VARCHAR(15) | nullable | Contact number |
| city | VARCHAR(50) | NOT NULL | Customer's home city |
| state | VARCHAR(50) | NOT NULL | Customer's home state |
| kyc_status | ENUM | NOT NULL, default Pending | Verified / Pending / Rejected |
| customer_since | DATE | NOT NULL | Relationship start date |
| created_at | TIMESTAMP | default now | Row insert time |

## 4. accounts
Money containers. Each belongs to one customer and one branch.

| Column | Type | Key / Constraint | Description |
|---|---|---|---|
| account_id | INT | PK, auto-increment | Unique account id |
| customer_id | INT | FK → customers | Account owner |
| branch_id | INT | FK → branches | Home branch |
| account_number | VARCHAR(20) | U, NOT NULL | Public account number |
| account_type | ENUM | NOT NULL | Savings / Current / Fixed Deposit |
| balance | DECIMAL(15,2) | NOT NULL, default 0 | Current balance (DECIMAL for accuracy) |
| status | ENUM | NOT NULL, default Active | Active / Dormant / Closed |
| opened_date | DATE | NOT NULL | Account open date |
| created_at | TIMESTAMP | default now | Row insert time |

## 5. cards
Debit/credit cards linked to an account. `card_number` is synthetic (never a real PAN).

| Column | Type | Key / Constraint | Description |
|---|---|---|---|
| card_id | INT | PK, auto-increment | Unique card id |
| account_id | INT | FK → accounts | Account the card draws from |
| card_number | VARCHAR(20) | U, NOT NULL | Synthetic/tokenised card number |
| card_type | ENUM | NOT NULL | Debit / Credit |
| network | ENUM | NOT NULL | Visa / Mastercard / RuPay |
| issued_date | DATE | NOT NULL | Issue date |
| expiry_date | DATE | NOT NULL | Expiry date |
| status | ENUM | NOT NULL, default Active | Active / Blocked / Expired |
| created_at | TIMESTAMP | default now | Row insert time |

## 6. loans
Money lent to customers, kept separate from deposit accounts.

| Column | Type | Key / Constraint | Description |
|---|---|---|---|
| loan_id | INT | PK, auto-increment | Unique loan id |
| customer_id | INT | FK → customers | Borrower |
| branch_id | INT | FK → branches | Issuing branch |
| loan_type | ENUM | NOT NULL | Home / Personal / Auto / Education |
| principal_amount | DECIMAL(15,2) | NOT NULL, CHECK > 0 | Original loan amount |
| interest_rate | DECIMAL(5,2) | NOT NULL | Annual interest rate (%) |
| tenure_months | INT | NOT NULL | Repayment period in months |
| outstanding_balance | DECIMAL(15,2) | NOT NULL | Amount still owed |
| start_date | DATE | NOT NULL | Loan start date |
| status | ENUM | NOT NULL, default Active | Active / Closed / Defaulted |
| created_at | TIMESTAMP | default now | Row insert time |

## 7. transactions
The core, high-volume table where fraud is detected. Uses BIGINT id.

| Column | Type | Key / Constraint | Description |
|---|---|---|---|
| transaction_id | BIGINT | PK, auto-increment | Unique transaction id |
| account_id | INT | FK → accounts | Account affected |
| card_id | INT | FK → cards, **nullable** | Card used, if any (UPI/bank transfers have none) |
| transaction_type | ENUM | NOT NULL | Deposit / Withdrawal / Transfer / Payment / Reversal |
| channel | ENUM | NOT NULL | ATM / POS / Internet / Mobile / Branch / UPI |
| amount | DECIMAL(15,2) | NOT NULL, CHECK > 0 | Transaction amount |
| currency | CHAR(3) | NOT NULL, default INR | Currency code |
| status | ENUM | NOT NULL | Success / Failed / Reversed |
| transaction_city | VARCHAR(50) | nullable | City where it occurred (impossible-travel rule) |
| counterparty_account | VARCHAR(20) | nullable | Destination account for transfers |
| description | VARCHAR(255) | nullable | Free-text note |
| is_flagged | BOOLEAN | NOT NULL, default FALSE | TRUE when a fraud rule fires |
| transaction_timestamp | DATETIME | NOT NULL | When it occurred (time-based rules) |
| created_at | TIMESTAMP | default now | Row insert time |

**Indexes:** `idx_txn_timestamp` (time filters), `idx_txn_status` (failed-txn KPIs), `idx_txn_account_time` on (account_id, transaction_timestamp) for velocity/impossible-travel rules.

## 8. fraud_alerts
One row per suspicious transaction flagged by a rule.

| Column | Type | Key / Constraint | Description |
|---|---|---|---|
| alert_id | INT | PK, auto-increment | Unique alert id |
| transaction_id | BIGINT | FK → transactions | The flagged transaction |
| customer_id | INT | FK → customers | Customer involved |
| rule_triggered | ENUM | NOT NULL | Velocity / Amount Anomaly / Impossible Travel / Midnight High Value / Card Testing |
| alert_reason | VARCHAR(255) | NOT NULL | Human-readable explanation |
| risk_level | ENUM | NOT NULL, default Medium | Low / Medium / High |
| status | ENUM | NOT NULL, default Open | Open / Investigating / Confirmed Fraud / False Positive |
| reviewed_by | INT | FK → employees, nullable | Fraud analyst who reviewed |
| alert_timestamp | DATETIME | NOT NULL | When the alert was raised |
| reviewed_at | DATETIME | nullable | When it was reviewed |
| created_at | TIMESTAMP | default now | Row insert time |

**Index:** `idx_alert_status` for filtering open alerts.

---

## Relationships summary
- A **branch** has many **employees**, **accounts**, and **loans**.
- A **customer** has many **accounts** and **loans**.
- An **account** has many **cards** and many **transactions**.
- A **card** may be used in many **transactions** (a transaction may have no card).
- A **transaction** may raise one **fraud alert**; each alert concerns one **customer** and may be reviewed by one **employee**.
