# Business Requirement Document (BRD)

**Project:** Banking Transaction Monitoring & Fraud Analytics Platform
**Client (fictional):** Meridian Retail Bank
**Document type:** Business Requirement Document
**Phase:** Phase 1 – Requirement Analysis

> *Meridian Retail Bank is a fictional bank created for this portfolio project. All data used is synthetic (generated with Faker); no real customer information is involved.*

---

## Document Control

| Field | Value |
|---|---|
| Document title | Business Requirement Document (BRD) |
| Version | 1.0 |
| Status | Approved for build |
| Author | Business Analyst (project owner) |
| Reviewers | Fraud Analytics Lead, Head of Retail Banking (simulated) |
| Last updated | Phase 1 |

**Version history**

| Version | Change |
|---|---|
| 1.0 | Initial requirements baseline |

---

## 1. Executive Summary

Meridian Retail Bank processes a high volume of everyday transactions across multiple branches and channels (ATM, POS, internet, and mobile/UPI). Leadership currently lacks a single, trusted view of business performance and fraud risk, and fraud is reviewed reactively rather than being flagged as it happens.

This project delivers a **local analytics platform** that simulates near-real-time transaction streaming, cleans and models the data, applies **explainable rule-based fraud detection**, and presents the results through **business KPIs and a Power BI dashboard**. The emphasis is on **solving business problems** — revenue, customer value, branch performance, and operational reliability — with fraud detection as one important component.

---

## 2. Business Background & Problem Statement

Today, information at Meridian is fragmented:

- Performance data lives in separate systems, so **executives cannot see the whole picture** (revenue, active customers, fraud, failures) in one place.
- Suspicious transactions are usually caught **after** losses occur, because there is no consistent, automated screening.
- The bank cannot easily answer basic strategic questions such as *which branches are most profitable*, *which customers are becoming inactive*, or *where transactions fail most often*.

**Problem statement:** Meridian needs a unified, auditable analytics capability that turns raw transaction data into timely business insight and flags likely fraud using transparent rules, so leadership can make faster, better-informed decisions and reduce avoidable losses.

---

## 3. Business Objectives

| ID | Objective | Success looks like |
|---|---|---|
| OBJ-1 | Give leadership one executive view of key banking KPIs | Single dashboard covering revenue, customers, fraud %, failures, trends |
| OBJ-2 | Detect potentially fraudulent transactions early using explainable rules | Seeded fraud scenarios are flagged with a clear reason |
| OBJ-3 | Identify high-value and at-risk (inactive) customers | Segmentation and inactivity outputs available to relationship teams |
| OBJ-4 | Compare branch performance objectively | Branch ranking by revenue and volume |
| OBJ-5 | Improve operational reliability | Failure rate measured by channel and city |
| OBJ-6 | Keep the pipeline auditable for compliance | Documented, rule-based, traceable data flow |

---

## 4. Project Scope

### 4.1 In scope

- Simulated near-real-time streaming of transactions from a CSV source into MySQL.
- Python ETL for data cleaning and validation.
- Rule-based fraud detection in SQL and Python.
- A star-schema data warehouse (fact and dimension tables) for analytics.
- Business KPIs via SQL views and stored procedures.
- A Power BI dashboard (executive, customer, branch, and fraud views).
- Business recommendations and full project documentation.

### 4.2 Out of scope

- Live integration with real production banking systems or real customer data.
- Machine-learning fraud models (noted as a future enhancement).
- Actual regulatory filing (e.g., real STR/SAR submission).
- Customer-facing applications or mobile apps.
- Cloud deployment, containers, or multi-currency handling.

*Clearly defining out-of-scope items prevents "scope creep," which is a leading cause of missed deadlines — a point worth making in interviews.*

---

## 5. Stakeholder Analysis

| Stakeholder (persona) | Interest in the project | Primary need |
|---|---|---|
| Head of Retail Banking (Sponsor) | Overall bank performance and growth | Executive KPI dashboard |
| Fraud Analytics Lead | Catching suspicious activity early | Fraud alerts with clear reasons |
| Branch Managers | How their branch is doing | Branch performance comparison |
| Operations Manager | Reducing failed transactions | Failure analysis by channel/city |
| Compliance Officer | Meeting AML/KYC obligations | Auditable, documented pipeline |
| Business Analyst (you) | Delivering the solution | Clear, testable requirements |

---

## 6. Business Requirements

| ID | Requirement | Priority | Linked objective |
|---|---|---|---|
| BR-01 | Provide a single executive view of key banking KPIs | Must have | OBJ-1 |
| BR-02 | Detect potentially fraudulent transactions using explainable rules | Must have | OBJ-2 |
| BR-03 | Identify high-value customers and customers becoming inactive | Should have | OBJ-3 |
| BR-04 | Compare performance across branches | Should have | OBJ-4 |
| BR-05 | Measure and report transaction failures | Should have | OBJ-5 |
| BR-06 | Simulate near-real-time transaction processing to mirror production systems | Must have | OBJ-1, OBJ-2 |
| BR-07 | Maintain an auditable, well-documented data pipeline | Must have | OBJ-6 |

*Priorities use the MoSCoW method (Must / Should / Could / Won't) — a standard BA prioritisation technique.*

---

## 7. Assumptions

- Live banking data is not publicly available, so transactions are **simulated** by streaming a CSV file.
- All data is **synthetic**; there is no real PII, so no privacy or regulatory exposure.
- A single bank, single currency (INR), and a bounded set of branches and customers are sufficient to demonstrate the solution.
- Both a historical dataset (for analytics) and a streamed feed (for real-time simulation) are available.

## 8. Constraints

- The solution must run **entirely locally** (MySQL, Python, Power BI). No cloud, Docker, or Kubernetes.
- The technology stack is fixed (see Section 11).
- The project is delivered by a single analyst who is still learning Power BI, so complexity must stay realistic.

## 9. Dependencies

- MySQL Workbench installed and running locally.
- Python environment with required libraries.
- Power BI Desktop for the dashboard.
- A prepared transaction dataset (built in Phase 4).

## 10. Risks

| Risk | Impact | Mitigation |
|---|---|---|
| Fraud rules produce too many false positives | Analysts waste time | Tune thresholds; document trade-offs |
| Dirty/invalid source data | Bad KPIs | Validate in ETL before loading |
| Scope creep | Missed timeline | Enforce the out-of-scope list |
| Streaming simulation too slow/fast to demo | Poor demo | Make streaming speed configurable |

---

## 11. Technology Stack (business view)

Database: MySQL Workbench · Programming: Python (pandas, numpy, mysql-connector-python, Faker, matplotlib, openpyxl) · Visualization: Power BI · Version control: GitHub · IDE: VS Code. All local, no cloud.

---

## 12. Success Criteria / Acceptance

The project is considered successful when:

1. The dashboard presents every KPI listed in the objectives.
2. Deliberately seeded fraud scenarios are correctly flagged with a stated reason.
3. The ETL process handles invalid data without failing and reports what it cleaned.
4. Branch, customer, and failure analyses answer the target business questions.
5. Complete documentation (BRD, FRS, data dictionary, diagrams, recommendations) is delivered.

---

## 13. Glossary

AML – Anti-Money Laundering · KYC – Know Your Customer · ETL – Extract, Transform, Load · KPI – Key Performance Indicator · MoSCoW – Must/Should/Could/Won't prioritisation · CLV – Customer Lifetime Value · OLTP – live operational database · Star schema – analytics data model with fact + dimension tables.
