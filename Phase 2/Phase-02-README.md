# Phase 2 – Business Understanding

## Phase Objective
Develop a deep, shared understanding of the business before any modelling begins: how the bank works today, where the pain is, exactly what stakeholders want to know, and how each of those questions becomes something measurable.

## Business Objective
Ensure the solution is aimed at real business value by cataloguing the precise questions leadership and operations need answered, and by agreeing single, unambiguous definitions for every KPI so all teams report the same numbers.

## Banking Context
This phase applies the **CRISP-DM Business Understanding** step to a retail bank: it documents the as-is customer-onboarding, transaction-processing, and (currently reactive) fraud-handling processes, then translates business goals into analytical goals.

## Folder Structure (this phase)
```
Phase-02-Business-Understanding/
├── README.md                              (this file)
├── Business-Understanding-Document.md
└── KPI-Metric-Definition-Dictionary.md
```

## Files Created
| File | Purpose |
|---|---|
| Business-Understanding-Document.md | As-is processes, pain points, to-be vision, the business-question catalog, fraud scenarios, and a process flow diagram. |
| KPI-Metric-Definition-Dictionary.md | Precise definition, formula, grain, and stakeholder for every KPI in the project. |
| README.md | Overview and learning material for this phase. |

## Technologies Used
None yet — documentation phase. (A Mermaid process-flow diagram is embedded in the Business Understanding Document and renders on GitHub.)

## Prerequisites
- Phase 0 (domain fundamentals) and Phase 1 (requirements) completed.
- A Markdown viewer or GitHub (for the Mermaid diagram).

## Execution Steps
Read the Business Understanding Document first for context and the business-question catalog, then the KPI Definition Dictionary for exactly how each metric is measured.

## Expected Output
An agreed set of business questions and single-source-of-truth KPI definitions that the database, warehouse, KPIs, and dashboard must all follow.

## Learning Outcomes
- You can describe the CRISP-DM Business Understanding step and why it comes before modelling.
- You can turn a vague business question into a measurable analytical goal.
- You understand why every KPI needs a precise definition, formula, and grain.
- You can explain the current (reactive) fraud process and how the project improves it.

## Interview Questions
1. **What is CRISP-DM and what is its first phase?**
   A standard data-project methodology; the first phase is Business Understanding — defining objectives and translating them into analytical goals.
2. **How do you turn a business question into an analytical one?**
   Identify the stakeholder and decision, the data required, and the specific metric/output. Example: "Which branches do well?" → "rank branches by revenue and volume for the period."
3. **Why must a KPI have a single agreed definition?**
   So different teams don't produce different numbers for the same metric; e.g., "active customer" must specify the look-back window.
4. **What is the grain of a metric and why does it matter?**
   The level it is measured at (customer, branch, month); mixing grains produces incorrect totals.
5. **How did you improve the fraud process?**
   Moved from reactive, after-the-loss review to consistent, explainable rule-based screening as transactions arrive.

## Troubleshooting Tips
- If two reports disagree on a KPI, check they used the same definition and grain from the KPI dictionary.
- If a business question can't be answered later, confirm the required data (from Section 5 of the Business Understanding Document) is being captured in Phase 4.
