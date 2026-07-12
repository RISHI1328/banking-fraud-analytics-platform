# Phase 1 – Requirement Analysis

## Phase Objective
Define *what* the project will build and *why*, before any code is written. This phase produces the foundational Business Analyst documents that every later phase traces back to.

## Business Objective
Give Meridian Retail Bank a clear, agreed statement of the business problem (fragmented reporting and reactive fraud handling) and the requirements for solving it, so the build stays focused on business value rather than technology for its own sake.

## Banking Context
Retail banks operate under AML/KYC obligations and must be able to explain and audit how they monitor transactions. Requirement analysis captures those needs up front — including that fraud detection must be **explainable** (rule-based) so every alert can be justified to an analyst or regulator.

## Folder Structure (this phase)
```
Phase-01-Requirement-Analysis/
├── README.md                                   (this file)
├── Business-Requirement-Document-BRD.md
└── Functional-Requirement-Specification-FRS.md
```

## Files Created
| File | Purpose |
|---|---|
| Business-Requirement-Document-BRD.md | The business "why/what": problem, objectives, scope, stakeholders, business requirements, risks, success criteria. |
| Functional-Requirement-Specification-FRS.md | The system "what/how-detailed": functional + non-functional requirements, use cases, and a requirement traceability matrix. |
| README.md | Overview and learning material for this phase. |

## Technologies Used
None yet — this is a documentation phase. (The stack used from Phase 3 onward: MySQL, Python, Power BI, Git.)

## Prerequisites
- Understanding of the banking fundamentals from Phase 0.
- A Markdown viewer or GitHub to read the documents.

## Execution Steps
Read the BRD first (business context), then the FRS (system detail), then follow the traceability matrix to see how each business need maps to a functional requirement.

## Expected Output
A complete, baselined set of requirements that the rest of the project builds against.

## Screenshots
_Placeholder — not applicable to a documentation phase._

## Learning Outcomes
- You can explain the difference between a BRD and an FRS.
- You can write clear, testable requirements and prioritise them with MoSCoW.
- You understand why scope boundaries, assumptions, and a traceability matrix matter.
- You can connect each stakeholder to a requirement and a KPI.

## Interview Questions
1. **What is the difference between a BRD and an FRS?**
   BRD states the business need in business language; FRS states, in testable detail, what the system must do to meet it. BRD feeds the FRS.
2. **What makes a good requirement?**
   It is clear, testable, unambiguous, and traceable to a business need. "The system should be fast" is bad; "streaming shall run at a configurable 2–5 second interval" is good.
3. **What is a requirement traceability matrix and why use it?**
   A table mapping each business requirement to the functional requirement(s) that satisfy it, ensuring nothing is missed and no feature is built without a business reason.
4. **How did you prioritise requirements?**
   Using MoSCoW (Must / Should / Could / Won't).
5. **Why define out-of-scope items?**
   To prevent scope creep, a leading cause of delays and budget overruns.
6. **Who were your stakeholders and how did you handle differing needs?**
   Sponsor, fraud lead, branch managers, operations, compliance — each mapped to specific requirements and KPIs so every need was addressed.

## Troubleshooting Tips
- If a later phase feels unclear, return to the FRS acceptance criteria for that requirement.
- If scope starts expanding, check the BRD's out-of-scope list before agreeing to new work.
