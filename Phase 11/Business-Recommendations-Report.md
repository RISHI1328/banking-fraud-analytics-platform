# Business Recommendations Report

**Project:** Banking Transaction Monitoring & Fraud Analytics Platform
**Client (fictional):** Meridian Retail Bank ("Federal Bank" database)
**Prepared by:** Rishabh — Business Analyst
**Phase:** 11 — Business Recommendations

---

## 1. Executive Summary

Meridian Retail Bank engaged this analysis to move from **reactive, complaint-driven fraud handling** to **proactive, data-driven monitoring**, and to give leadership a single, consistent view of business performance. Over eleven phases we built an end-to-end analytics platform: a normalized transaction database, an ETL pipeline with data-quality controls, an explainable rule-based fraud detection engine, a star-schema data warehouse, a governed KPI layer, and a four-page Power BI dashboard.

The platform now monitors **500 customers**, **~650 accounts across 8 branches**, and **~20,000 transactions**, detecting suspicious activity with **five explainable fraud rules** whose performance is measured against seeded ground truth. This report presents the key findings and the actions we recommend.

---

## 2. Key Findings

### Finding 1 — Fraud is detectable with simple, explainable rules
The five rules (velocity, amount anomaly, impossible travel, midnight high-value, card testing) successfully identified the seeded fraud patterns in the transaction history, each alert carrying a human-readable reason. Alert volume is concentrated in a small number of accounts — consistent with real-world fraud, where a few compromised accounts generate most alerts.

### Finding 2 — Fraud exposure varies meaningfully by branch
Flagged-transaction rates are not uniform: some branches (e.g., Ahmedabad and Hyderabad in this dataset) show noticeably higher fraud percentages than others (Delhi lowest). Whether driven by customer mix, channel mix, or local patterns, branch-level variation means a one-size-fits-all control posture is inefficient.

### Finding 3 — Transaction failures are a silent revenue and experience leak
Roughly **6% of transactions fail**. Every failed transaction is a frustrated customer and, for fee-bearing transactions, lost revenue. Failure rates differ by branch and channel, suggesting addressable technical or process causes rather than uniform background noise.

### Finding 4 — The customer base is heavily concentrated in one segment
Segmentation shows ~90% "Standard" customers, ~7% "Premium," and a small but important "At-Risk" group (**13 customers** with no activity in 31–90 days). The Premium segment is small relative to its revenue contribution, and the Standard majority represents a large upsell surface.

### Finding 5 — A governed KPI layer removes reporting ambiguity
Before this project, metrics like "active customer" or "fraud rate" had no single definition. With KPIs defined once in SQL views and consumed by the dashboard, every stakeholder now reads the same number — eliminating a class of cross-team disputes.

---

## 3. Recommendations

### R1 — Operationalize the fraud rules with a tiered response (Priority: High)
Move the five rules from batch analysis toward near-real-time scoring. Route **High-risk alerts** (amount anomaly, impossible travel, midnight high-value) to immediate analyst review with a target response SLA; queue **Medium-risk alerts** (velocity, card testing) for same-day review. Track false-positive rates per rule and tune thresholds quarterly.
**Expected impact:** earlier interdiction of fraud-in-progress; reduced fraud losses; documented, regulator-friendly decisions.

### R2 — Pilot branch-differentiated fraud thresholds (Priority: High)
Use the branch fraud-rate variation to pilot tighter thresholds at the two highest-fraud branches and monitor the false-positive/false-negative balance for one quarter before wider rollout.
**Expected impact:** concentrates analyst attention where risk is highest without penalizing low-risk branches.

### R3 — Launch a failed-transaction root-cause program (Priority: Medium)
Break down the ~6% failure rate by channel, branch, and time; classify causes (insufficient funds, technical decline, timeout); fix the top two addressable causes.
**Expected impact:** even a 1–2 point reduction in failures directly improves customer experience and recovers fee revenue.

### R4 — Retention outreach for the At-Risk segment (Priority: Medium)
The 13 At-Risk customers are identifiable by name today. A low-cost outreach campaign (relationship-manager call, re-activation offer) is cheap relative to acquisition cost of replacing them.
**Expected impact:** retaining even a handful protects recurring revenue at minimal cost; the segmentation view makes the campaign measurable month over month.

### R5 — Grow the Premium segment deliberately (Priority: Medium)
Use the CLV view to identify high-value Standard customers just below the Premium threshold and target them with product offers (cards, deposits).
**Expected impact:** shifts the customer mix toward the highest-revenue segment using criteria that are already computed and auditable.

### R6 — Extend the platform's data foundations (Priority: Low / roadmap)
Three natural next steps: (a) schedule the ETL and detection as automated daily jobs; (b) add device/IP signals to strengthen impossible-travel detection; (c) trial a machine-learning scoring model **alongside** (not replacing) the explainable rules, using the rules as the auditable baseline.
**Expected impact:** improves detection coverage while preserving the explainability regulators require.

---

## 4. Measuring Success

| Recommendation | KPI to track | Data source |
|---|---|---|
| R1 Tiered response | Alert response time; fraud loss amount | fraud_alerts (status, timestamps) |
| R2 Branch thresholds | Fraud % by branch; false-positive rate | v_branch_performance; analyst dispositions |
| R3 Failure program | Failed % overall and by channel | v_kpi_overview; v_channel_popularity |
| R4 Retention | At-Risk count; reactivation rate | v_customer_segmentation |
| R5 Premium growth | Premium segment share; CLV distribution | v_customer_segmentation; v_customer_value |
| R6 Roadmap | Detection rate vs ground truth | Phase 7 scoring framework |

All six recommendations are measurable with KPIs the platform already computes — no new instrumentation is required to hold the plan accountable.

---

## 5. Limitations & Honest Caveats

- **Synthetic data.** All customers, transactions, and fraud are generated (Faker, seeded scenarios). Findings demonstrate the *method*; magnitudes would differ on production data.
- **Revenue is a modeled proxy** (0.5% transaction fee + 3% annual interest margin), documented in the KPI dictionary.
- **Rules are tuned to the seeded patterns.** Real-world tuning would use analyst feedback loops and champion/challenger threshold testing.
- **The final month of history is partial**, which appears as a dip in trend charts and should not be read as a business decline.

---

## 6. Conclusion

The platform delivers the core outcomes the BRD asked for: proactive fraud detection with explainable alerts, a single source of truth for KPIs, and self-service dashboards for four stakeholder groups. The recommendations above sequence the next quarter of work — operationalizing detection, plugging the failure leak, and acting on segmentation — each measurable with the KPIs the platform already provides.
