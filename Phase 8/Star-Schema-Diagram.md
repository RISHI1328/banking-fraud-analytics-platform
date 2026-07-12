# Star Schema Diagram – Data Warehouse

**Project:** Banking Transaction Monitoring & Fraud Analytics Platform
**Database:** `federal_bank`
**Phase:** Phase 8 – Data Warehouse

> A **star schema** places one central **fact** table (the numbers) in the middle,
> surrounded by **dimension** tables (the descriptive attributes). The shape looks like
> a star. Reporting tools like Power BI are built to consume exactly this shape.

```mermaid
erDiagram
    DIM_DATE     ||--o{ FACT_TRANSACTIONS : "when"
    DIM_CUSTOMER ||--o{ FACT_TRANSACTIONS : "who"
    DIM_BRANCH   ||--o{ FACT_TRANSACTIONS : "where"
    DIM_CHANNEL  ||--o{ FACT_TRANSACTIONS : "how"

    FACT_TRANSACTIONS {
        bigint  transaction_id PK
        int     date_key FK
        int     customer_key FK
        int     branch_key FK
        int     channel_key FK
        varchar transaction_type
        varchar status
        decimal amount
        boolean is_flagged
        tinyint is_success
        tinyint is_failed
    }
    DIM_DATE {
        int     date_key PK
        date    full_date
        int     year
        int     quarter
        int     month
        varchar month_name
        int     day_of_week
        varchar day_name
        boolean is_weekend
    }
    DIM_CUSTOMER {
        int     customer_key PK
        int     customer_id
        varchar full_name
        varchar gender
        varchar city
        varchar state
        varchar kyc_status
        date    customer_since
    }
    DIM_BRANCH {
        int     branch_key PK
        int     branch_id
        varchar branch_name
        varchar city
        varchar state
        varchar ifsc_code
    }
    DIM_CHANNEL {
        int     channel_key PK
        varchar channel_name
    }
```

## Fact vs. dimension — the quick mental model
- **Fact** (`fact_transactions`): *measurements*, one row per transaction — the amounts, flags, and counts you aggregate (SUM, COUNT, AVG).
- **Dimensions** (`dim_*`): *context* you slice and filter by — a date, a customer, a branch, a channel.
- A dashboard question is almost always: **"a fact measure, grouped by a dimension attribute"** — e.g., *SUM(amount) by dim_date.month*, or *fraud rate by dim_branch.branch_name*.

## Why this beats querying the OLTP tables directly
1. **Fewer joins.** "Revenue by branch by month" touches the fact plus two dimensions — versus chaining transaction → account → customer → branch on the normalized schema.
2. **A real date dimension.** `dim_date` pre-computes year, quarter, month, weekday and weekend flags, so time-based analysis is a simple `GROUP BY` with no date math.
3. **Surrogate keys.** Each dimension has its own `*_key`, insulating the warehouse from changes to operational ids and following standard warehouse practice.
4. **Power BI ready.** The star shape maps directly onto Power BI's model view, with the fact in the centre and dimensions around it.

## OLTP vs. OLAP (the interview soundbite)
- **OLTP** (Phase 3 schema): optimised for **writes** and integrity — normalized, many small tables. Runs the bank.
- **OLAP** (this star schema): optimised for **reads** and analysis — denormalized into fact + dimensions. Reports on the bank.
- We keep both and load the warehouse *from* the OLTP tables.
