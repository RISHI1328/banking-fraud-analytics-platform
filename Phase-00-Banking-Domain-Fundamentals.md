# Phase 0 – Banking Domain Fundamentals

**Project:** Banking Transaction Monitoring & Fraud Analytics Platform
**Phase type:** Learning & documentation only (no code)
**Goal of this phase:** Build enough banking domain knowledge that you can confidently *explain* every table, KPI, and fraud rule in this project during a Business Analyst interview.

> **Why this phase exists:** In consulting firms like EXL, the technical skills (SQL, Python, Power BI) get you shortlisted, but *domain understanding* is what gets you hired for a banking/financial-services client. An analyst who can say "this rule flags a possible account takeover, which matters because the bank is liable for the loss" is far more valuable than one who can only say "this query counts rows." This document gives you that vocabulary.

---

## How to use this document

Read it once end-to-end now. Then, at the start of each later phase, come back and re-read the section it relates to (e.g., re-read *Transactions* before building the transaction simulator). Every concept here maps to something you will actually build later, and I've flagged those links with **→ Used later in**.

---

## 1. The Big Picture: What a Retail Bank Does

Banks broadly fall into three types:

| Bank type | Who it serves | Example activity |
|---|---|---|
| **Retail bank** | Individuals & small businesses | Savings accounts, debit cards, personal loans |
| **Commercial bank** | Mid-to-large businesses | Business loans, cash management, trade finance |
| **Investment bank** | Corporations & institutions | Mergers, IPOs, trading |

**We model a retail bank** in this project because retail banking produces huge volumes of small, everyday transactions (ATM withdrawals, UPI payments, card swipes). That high volume is exactly what makes transaction monitoring and fraud analytics realistic and interesting.

### How a retail bank makes money (you must know this)

When a KPI in this project says "revenue," it helps to know where a bank's money actually comes from:

1. **Net interest income** – the bank pays you ~3% on your savings but lends that money out at ~10%. The gap ("the spread") is its biggest profit source.
2. **Fees** – account maintenance fees, late-payment fees, ATM fees, failed-transaction penalties.
3. **Interchange** – every time you swipe a card, the merchant's bank pays a small fee that is partly shared with your bank.

**→ Used later in:** the *Total Revenue*, *Branch Performance*, and *Customer Lifetime Value* KPIs. When an executive asks "why is Branch A more profitable?", the answer is usually a mix of higher balances (more interest income) and more card/transaction activity (more fees and interchange).

---

## 2. The Core Entities (the "nouns" of banking)

Everything in this project revolves around a small set of core entities and the relationships between them. This directly becomes your database design in Phase 3.

| Entity | Plain-English meaning | Key relationships |
|---|---|---|
| **Customer** | A person who banks with you | Owns one or more accounts |
| **Account** | A container that holds money and a balance | Belongs to one customer, held at one branch |
| **Branch** | A physical bank location (with a city) | Holds many accounts; employs staff |
| **Card** | A debit/credit card linked to an account | Linked to one account |
| **Loan** | Money lent to a customer, repaid over time | Belongs to one customer |
| **Transaction** | A single movement of money | Hits one (or two) accounts |
| **Employee** | Bank staff (teller, manager, analyst) | Works at a branch |
| **Fraud Alert** | A flag raised when a transaction looks suspicious | Linked to a transaction/customer |

The mental model to memorize:

> **A *customer* opens an *account* at a *branch*. A *card* is linked to that account. When money moves, a *transaction* is recorded. If that transaction looks suspicious, a *fraud alert* is raised for a *fraud analyst* (an *employee*) to review.**

If you can say that sentence smoothly in an interview, you've demonstrated domain understanding.

---

## 3. Account Types

Not all accounts behave the same, and this affects how you interpret balances and transactions.

| Account type | Purpose | Typical behaviour |
|---|---|---|
| **Savings account** | Everyday personal saving | Earns interest; limited withdrawals |
| **Current / Checking account** | Business or high-activity use | Little/no interest; unlimited transactions |
| **Fixed / Term Deposit (FD)** | Lock money for a fixed period | Higher interest; penalty for early withdrawal |
| **Loan account** | Tracks money owed to the bank | Balance goes *down* as customer repays |

**Common confusion to avoid:** a high account *balance* is not automatically "good revenue." A large savings balance is actually a *liability* to the bank (it owes that money to the customer) — but it's a good sign because the bank can lend that money out. This nuance impresses interviewers.

**→ Used later in:** *Average Account Balance* and *Customer Segmentation* KPIs.

---

## 4. Transactions (the heart of this project)

A **transaction** is a single recorded movement of money. This is the most important entity in the whole project because fraud lives in transaction patterns.

### Transaction types

- **Deposit** – money added to an account.
- **Withdrawal** – money taken out.
- **Transfer** – money moved from one account to another.
- **Payment** – money sent to a merchant or biller.
- **Reversal / Refund** – a previous transaction undone.

### Debit vs Credit (the classic beginner trap)

From the **customer's** point of view: a *debit* removes money, a *credit* adds money.
From the **bank's accounting** point of view, the meaning flips, because your deposit is money the bank *owes* you.
For this project, always reason from the **customer's** perspective unless told otherwise — it keeps things simple and matches how business stakeholders think.

### Transaction channels (how the money moved)

| Channel | What it is | Why it matters for fraud |
|---|---|---|
| **Branch / Teller** | In-person at a branch | Low fraud risk (identity checked in person) |
| **ATM** | Cash machine | Skimming, stolen-card fraud |
| **POS** | Card swipe at a shop | Cloned/stolen card fraud |
| **Internet banking** | Web browser | Account takeover, phishing |
| **Mobile / UPI** | Phone app | Social-engineering scams, fast money movement |

**→ Used later in:** the "Which channels are most popular?" business question and several fraud rules. Fraud analysts care about channel because online/mobile channels carry far more fraud risk than an in-person teller.

### Transaction status / lifecycle

A transaction is not just "done." It moves through states:

```
Initiated  →  Authorized  →  Posted / Settled
                   │
                   └──→  Failed   (e.g., insufficient funds, timeout)
                   └──→  Reversed (transaction undone after posting)
```

- **Success / Posted** – completed normally.
- **Failed** – did not complete (insufficient funds, wrong PIN, network timeout, blocked card).
- **Reversed** – completed then undone.

**Why this matters:** the *Failed Transactions* KPI and the "multiple failed transactions before a successful one" fraud rule both depend entirely on this status field. A burst of failures followed by a success is a classic sign of someone guessing a PIN or testing a stolen card.

---

## 5. Payment Rails (how money actually travels)

Behind every transfer is a "rail." You don't need deep technical detail, but you should recognize the names — especially the Indian ones, since EXL serves Indian and global banks.

**India:**

| Rail | Speed | Typical use | Note |
|---|---|---|---|
| **UPI** | Instant, 24×7 | Everyday small payments via phone | Most common retail rail today |
| **IMPS** | Instant, 24×7 | Instant transfers | Older instant rail |
| **NEFT** | Near-instant, 24×7 | General transfers | No minimum amount |
| **RTGS** | Real-time, 24×7 | Large-value transfers | Minimum ₹2 lakh |

**International (good to name for global clients):** ACH (bulk US transfers), Wire / SWIFT (cross-border), card networks (Visa, Mastercard, RuPay).

**→ Used later in:** understanding transaction channels and the "impossible travel" and "high-value midnight transaction" rules. Instant, 24×7 rails are convenient for customers *and* for fraudsters, which is exactly why real-time monitoring exists.

---

## 6. Compliance: Why Fraud Monitoring Is *Required*, Not Optional

This is the section that separates a "college project" from a "business project." Banks don't monitor transactions just to save money — they are **legally required** to.

- **KYC (Know Your Customer)** – banks must verify who their customers are before opening accounts. Prevents fake identities.
- **AML (Anti-Money Laundering)** – laws requiring banks to detect and report money laundering (making "dirty" money look legitimate).
- **CFT (Combating the Financing of Terrorism)** – related rules to stop money reaching terrorist groups.
- **Transaction Monitoring** – the ongoing screening of transactions for suspicious patterns. **This is exactly what your project simulates.**
- **STR / SAR (Suspicious Transaction / Activity Report)** – when a bank spots something suspicious, it must file a report with the regulator.

In India, the regulator is the **Reserve Bank of India (RBI)**, supported by the Financial Intelligence Unit (FIU-IND). Globally, similar bodies exist (e.g., FinCEN in the US).

**Interview gold:** if asked "why does this project matter?", say:
> "Transaction monitoring isn't just cost-saving — it's a regulatory obligation under AML/KYC rules. A missed suspicious pattern can mean regulatory fines and reputational damage, not just a single fraud loss."

---

## 7. Fraud Fundamentals

**Fraud** here means someone obtaining money or access dishonestly. The typologies (patterns) below map directly to the fraud rules you'll build.

| Fraud type | What happens | Matching project rule |
|---|---|---|
| **Stolen / cloned card** | Fraudster uses a card that isn't theirs | Impossible travel; midnight high-value |
| **Account takeover (ATO)** | Fraudster gains login access to a real account | Sudden change in spending pattern |
| **Card testing** | Fraudster tries many small transactions to check if a stolen card works | 5+ transactions in 2 minutes; repeated failures |
| **Structuring / smurfing** | Breaking one large transaction into many small ones to stay under reporting limits | Velocity + amount rules |
| **Social-engineering scam** | Victim is tricked into sending money themselves | High-value transfer far above their average |

**First-party vs third-party fraud (bonus term):**
- *Third-party fraud* – a criminal impersonates or steals from a real customer (most of what we detect).
- *First-party fraud* – the actual customer lies (e.g., claims a legitimate purchase was fraudulent to get a refund).

---

## 8. How Fraud Detection Actually Works

### Rule-based vs anomaly/ML detection

- **Rule-based** (what this project uses): explicit "if-then" logic, e.g., *if more than 5 transactions in 2 minutes, flag it.*
- **Machine-learning / anomaly-based**: a model learns "normal" behaviour and flags outliers.

**Why we deliberately choose rule-based here:** rules are **explainable and auditable** — a fraud analyst and a regulator can both see exactly *why* a transaction was flagged. That transparency is required in banking, and it's easier to defend in an interview. (You can mention ML as a "future enhancement" to sound forward-looking.)

### The single most important concept: False Positives vs False Negatives

| Term | Meaning | Business cost |
|---|---|---|
| **False Positive** | A *legitimate* transaction wrongly flagged as fraud | Annoyed customer, blocked genuine purchase, wasted analyst time |
| **False Negative** | A *real fraud* that slipped through undetected | Direct financial loss + regulatory risk |

The whole art of fraud analytics is **balancing** these. Too-strict rules block real customers; too-loose rules let fraud through. If an interviewer asks *one* conceptual question about fraud, it will almost certainly be this trade-off. Memorize it.

### The alert workflow (what happens after a flag)

```
Transaction  →  Rule fires  →  Fraud Alert created  →  Analyst investigates  →  Disposition
                                                                                 ├─ Genuine fraud → block card, file report
                                                                                 └─ False alarm  → clear the alert
```

**→ Used later in:** your *Fraud Alerts* table and *Fraud %* KPI.

---

## 9. Banking Metrics & KPIs (preview)

These are the numbers stakeholders live by. You'll build them in Phase 9, but here's what they *mean* in business terms:

- **Active Customers** – customers who transacted recently. Declining activity is an early warning of customers leaving ("churn").
- **Total Revenue** – interest + fees + interchange, as explained in Section 1.
- **Customer Lifetime Value (CLV)** – estimated total profit a customer brings over time; helps decide who gets premium offers.
- **Fraud %** – share of transactions flagged/confirmed as fraud; a health and risk metric.
- **Failure Rate** – share of failed transactions; high rates may signal technical problems *or* fraud attempts.

---

## 10. Stakeholders: Who Cares About What

A Business Analyst's core skill is connecting each stakeholder to the questions they ask and the metric that answers them. Memorize this table — it's the backbone of your interview story.

| Stakeholder | What keeps them up at night | Metric / output that helps them |
|---|---|---|
| **Branch Manager** | Is my branch performing? | Branch revenue, transaction volume, branch ranking |
| **Fraud Analyst** | Which transactions are suspicious right now? | Fraud alerts, suspicious-transaction list |
| **Operations Team** | Why are transactions failing? | Failure rate by channel/city |
| **Executive / CXO** | Is the whole bank healthy and growing? | Executive dashboard: revenue, active customers, fraud %, trends |
| **Compliance Officer** | Are we meeting regulatory obligations? | Fraud monitoring coverage, reports filed |

---

## 11. Glossary (quick reference)

- **AML** – Anti-Money Laundering.
- **ATO** – Account Takeover.
- **CFT** – Combating the Financing of Terrorism.
- **Churn** – customers leaving the bank.
- **CLV** – Customer Lifetime Value.
- **ETL** – Extract, Transform, Load (moving and cleaning data — Phase 6).
- **Interchange** – fee earned by the bank when a customer's card is used.
- **KYC** – Know Your Customer.
- **OLTP** – Online Transaction Processing (the live operational database).
- **POS** – Point of Sale (card machine at a shop).
- **RTGS / NEFT / IMPS / UPI** – Indian payment rails (see Section 5).
- **STR / SAR** – Suspicious Transaction / Activity Report.
- **Star Schema** – analytics-friendly data model with fact + dimension tables (Phase 8).
- **Velocity** – how fast/often transactions occur (a key fraud signal).

---

## 12. Likely Interview Questions for This Phase (with short answers)

**Q: Walk me through what happens from a customer opening an account to a fraud alert.**
A: A customer completes KYC and opens an account at a branch; a card may be linked to it. Each money movement is recorded as a transaction with a channel and status. Monitoring rules screen these transactions, and suspicious ones raise a fraud alert that an analyst investigates.

**Q: Why does a bank monitor transactions?**
A: Partly to reduce fraud losses, but critically because AML/KYC regulations legally require it. Missing suspicious activity risks fines and reputational damage, not just money.

**Q: What's the difference between a false positive and a false negative, and why does it matter?**
A: A false positive blocks a genuine customer (annoyance, lost business, wasted analyst effort); a false negative lets real fraud through (direct loss + regulatory risk). Fraud analytics is about balancing the two by tuning rule thresholds.

**Q: Why rule-based detection instead of machine learning?**
A: Rules are explainable and auditable, which regulators and analysts require. ML is a strong future enhancement but harder to justify decision-by-decision.

**Q: Why is a high account balance not simply "good"?**
A: To the bank a customer's deposit is a liability (money it owes), though a useful one because it can be lent out to earn interest income.

---

## 13. Common Beginner Mistakes to Avoid

1. **Treating fraud detection as the whole project.** The real value is *solving business problems* — revenue, churn, branch performance — with fraud as one part.
2. **Confusing debit/credit direction.** Reason from the customer's perspective for consistency.
3. **Ignoring transaction status.** Failed and reversed transactions carry huge analytical meaning; don't filter them out blindly.
4. **Explaining code, not value.** In interviews, always add the "so what for the business" sentence.
5. **Forgetting the regulator.** Mentioning AML/KYC instantly signals real domain awareness.

---

## Phase 0 Complete — Learning Outcomes

You can now explain: what a retail bank does and how it earns money; the core entities and how they relate; account and transaction types, channels, and statuses; Indian payment rails; why monitoring is a regulatory requirement; the main fraud typologies; rule-based detection and the false-positive/false-negative trade-off; the key KPIs; and which stakeholder cares about what.

This vocabulary underpins every remaining phase.
