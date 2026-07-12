# ER Diagram – OLTP Schema

**Project:** Banking Transaction Monitoring & Fraud Analytics Platform
**Database:** `federal_bank`
**Phase:** Phase 3 – Database Design

> An Entity-Relationship (ER) diagram shows the tables (entities), their key columns, and how they connect. The crow's-foot notation reads as: `||` = "exactly one", `o{` = "zero or many". So `CUSTOMERS ||--o{ ACCOUNTS` means *one customer can have zero or many accounts*. This diagram renders visually on GitHub.

```mermaid
erDiagram
    BRANCHES ||--o{ EMPLOYEES : "employs"
    BRANCHES ||--o{ ACCOUNTS : "hosts"
    BRANCHES ||--o{ LOANS : "issues"
    CUSTOMERS ||--o{ ACCOUNTS : "owns"
    CUSTOMERS ||--o{ LOANS : "borrows"
    ACCOUNTS ||--o{ CARDS : "has"
    ACCOUNTS ||--o{ TRANSACTIONS : "records"
    CARDS ||--o{ TRANSACTIONS : "used in"
    TRANSACTIONS ||--o| FRAUD_ALERTS : "may raise"
    CUSTOMERS ||--o{ FRAUD_ALERTS : "concerns"
    EMPLOYEES ||--o{ FRAUD_ALERTS : "reviews"

    BRANCHES {
        int branch_id PK
        varchar branch_name
        varchar ifsc_code UK
        varchar city
        varchar state
        date opened_date
    }
    EMPLOYEES {
        int employee_id PK
        int branch_id FK
        varchar first_name
        varchar last_name
        enum role
        varchar email UK
        date hire_date
    }
    CUSTOMERS {
        int customer_id PK
        varchar first_name
        varchar last_name
        varchar email UK
        varchar city
        varchar state
        enum kyc_status
        date customer_since
    }
    ACCOUNTS {
        int account_id PK
        int customer_id FK
        int branch_id FK
        varchar account_number UK
        enum account_type
        decimal balance
        enum status
        date opened_date
    }
    CARDS {
        int card_id PK
        int account_id FK
        varchar card_number UK
        enum card_type
        enum network
        date expiry_date
        enum status
    }
    LOANS {
        int loan_id PK
        int customer_id FK
        int branch_id FK
        enum loan_type
        decimal principal_amount
        decimal interest_rate
        int tenure_months
        decimal outstanding_balance
        enum status
    }
    TRANSACTIONS {
        bigint transaction_id PK
        int account_id FK
        int card_id FK
        enum transaction_type
        enum channel
        decimal amount
        enum status
        varchar transaction_city
        boolean is_flagged
        datetime transaction_timestamp
    }
    FRAUD_ALERTS {
        int alert_id PK
        bigint transaction_id FK
        int customer_id FK
        int reviewed_by FK
        enum rule_triggered
        varchar alert_reason
        enum risk_level
        enum status
        datetime alert_timestamp
    }
```

## How to read this design in an interview

- The schema is **normalized to 3NF**: each fact is stored once (a branch's city lives only in `branches`; accounts just reference `branch_id`).
- **Foreign keys** enforce integrity: you cannot record a transaction for an account that doesn't exist.
- The **`transactions`** table is intentionally the busiest, so it uses a `BIGINT` key and targeted indexes for the time-window queries that fraud rules depend on.
- This OLTP design favors **safe, consistent writes**. In Phase 8 we will reshape this data into a **star schema** optimized for fast reporting reads — the classic OLTP-vs-OLAP split.
