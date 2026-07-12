# Phase 10 – Power BI Dashboard (Build Guide)

## Phase Objective
Build a four-page Power BI dashboard — Executive, Customer, Branch, and Fraud — on top of the Phase 9 KPI views, giving stakeholders a single interactive view of the bank.

## Business Objective
Turn the SQL KPIs into visuals non-technical stakeholders can explore themselves, so leadership, fraud, operations, and branch teams each find their answers without asking for a custom report.

> **You are still learning Power BI, so this guide is click-by-click. Take it one page at a time.** Because we computed the KPIs in SQL already, you will need almost no DAX — that is a deliberate, professional design choice worth mentioning in interviews.

---

## Step 1 — Get the data in (choose ONE option)

### Option A — Import CSVs (recommended for your first build)
1. Run the helper notebook `Phase-10-Export-KPIs-for-PowerBI.ipynb` (set your MySQL password first). It creates a `powerbi/` folder with one CSV per dataset.
2. In Power BI Desktop: **Home → Get data → Text/CSV**.
3. Select `powerbi/kpi_overview.csv` → **Load**.
4. Repeat **Get data → Text/CSV** for each of the other CSVs (branch_performance, monthly_trend, top_cities, customer_segmentation, customer_value, customer_risk, channel_popularity, fraud_by_rule, fraud_by_risk, fraud_by_branch, fraud_trend, alerts_detail).

### Option B — Connect live to MySQL (do this once comfortable)
1. **Home → Get data → More → Database → MySQL database**.
2. If prompted that a connector is missing, install **"MySQL Connector/NET"** (Power BI shows the download link), then restart Power BI.
3. Server: `localhost`  ·  Database: `federal_bank` → **OK**.
4. Choose **Database** auth, enter `root` and your password → **Connect**.
5. In the Navigator, tick the nine `v_*` views → **Load**.
   *(Advantage: click **Refresh** anytime to pull fresh numbers. For the Fraud page you'll also want the fraud queries — easiest is to still run the export notebook for those, or add them as views.)*

> **You do not need to create relationships** between these tables for a first build — each visual is powered by one self-contained table (that's the payoff of pre-aggregating in SQL). You can add relationships later if you want cross-page filtering.

---

## Step 2 — A quick orientation to the Power BI screen
- **Report view** (left icon): where you place visuals on the canvas.
- **Fields pane** (right): your tables and columns.
- **Visualizations pane** (right): the chart types. Click a chart icon, then drag fields into its wells (Axis, Values, Legend).
- **Pages** (bottom tabs): click the `+` to add a page. Rename by double-clicking the tab.

Create four pages named: `Executive`, `Customers`, `Branches`, `Fraud`.

---

## Step 3 — Page 1: Executive Dashboard
Data used: `kpi_overview`, `monthly_trend`, `branch_performance`, `top_cities`, `customer_segmentation`.

**Top row — KPI cards** (visual type: **Card**). Add one Card each and drag the field from `kpi_overview`:
- Total Customers → `total_customers`
- Active Customers → `active_customers_30d`
- Total Revenue → `total_revenue_est`
- Total Transactions → `total_transactions`
- Fraud % → `fraud_pct`
- Failed % → `failed_pct`

*(If a card shows "Sum of…", that's fine — it's a single row so the sum equals the value. To tidy the label, rename the field in the Values well or set it to "Don't summarize".)*

**Middle — trend line** (visual: **Line chart**), from `monthly_trend`:
- X-axis: `month_name` (or create a Year-Month sort) · Y-axis: `transactions` (add `total_amount` as a second line if you like).

**Bottom-left — branch bar** (visual: **Clustered bar chart**), from `branch_performance`:
- Y-axis: `branch_name` · X-axis: `total_amount`.

**Bottom-middle — top cities** (visual: **Clustered column chart** or **Map**), from `top_cities`:
- Column: Axis `city`, Value `transactions`. (Map: Location `city`, Size `transactions`.)

**Bottom-right — segmentation donut** (visual: **Donut chart**), from `customer_segmentation`:
- Legend: `segment` · Values: `Count of customer_id`.

---

## Step 4 — Page 2: Customer Analytics
Data: `customer_segmentation`, `customer_value`.

- **Donut / bar** — segment distribution: from `customer_segmentation`, Legend `segment`, Values `Count of customer_id`.
- **Cards** — count of At-Risk and Inactive: add a Card with `Count of customer_id` and use a **visual-level filter** on `segment` = "At-Risk" (repeat for "Inactive").
- **Table** — top customers by value: visual **Table**, from `customer_value`, columns `full_name`, `city`, `transactions`, `total_spend`, `est_clv_5yr`. Sort by `est_clv_5yr` descending.
- **Column chart** — spending by segment: needs both tables related on `customer_id` (optional). Simpler for now: bar of `total_spend` by `full_name` (top N via filter).
- **Slicer** — add a **Slicer** on `segment` so viewers can filter the page.

---

## Step 5 — Page 3: Branch Analytics
Data: `branch_performance`, `top_cities`.

- **Bar** — revenue by branch: `branch_name` vs `fee_revenue` (or `total_amount`).
- **Bar** — transaction volume by branch: `branch_name` vs `transactions`.
- **Table** — branch ranking: all `branch_performance` columns, sorted by `total_amount`.
- **Bar** — fraud rate by branch: `branch_name` vs `fraud_pct` (sort descending to spotlight risky branches).
- **Map / column** — activity by city: from `top_cities`.

---

## Step 6 — Page 4: Fraud Analytics
Data: `fraud_by_rule`, `fraud_by_risk`, `fraud_by_branch`, `fraud_trend`, `alerts_detail`.

- **Cards** — total alerts (`Count of alert_id` from `alerts_detail`); High-risk alerts (Card with filter `risk_level` = "High").
- **Donut / bar** — alerts by rule: from `fraud_by_rule`, Legend `rule_triggered`, Values `alerts`.
- **Bar** — fraud by branch/city: from `fraud_by_branch`.
- **Line** — fraud over time: from `fraud_trend`, Axis `month_name`, Values `alerts`.
- **Table** — alert detail: from `alerts_detail`, columns `transaction_id`, `rule_triggered`, `risk_level`, `alert_reason`, `alert_timestamp`.
- **Slicer** — on `rule_triggered` so analysts can focus on one fraud type.

---

## Step 7 — Make it look professional
- **View → Themes**: pick a clean theme (or a banking-blue one).
- Give every visual a clear **title** (Format pane → General → Title).
- Add a **page title** text box on each page (e.g., "Federal Bank — Executive Overview").
- Align visuals with the grid; keep the KPI cards in a neat top row.
- Format numbers: currency for revenue/amount, one decimal for percentages.
- Add a company-style header rectangle at the top for polish.

---

## Optional — a little DAX (only if you want)
Most KPIs are pre-computed, but two small measures are handy. Create via **Modeling → New measure**:
```DAX
Total Revenue (Lakhs) = DIVIDE(SUM(kpi_overview[total_revenue_est]), 100000)
```
```DAX
Fraud Alerts = COUNTROWS(alerts_detail)
```

---

## Deliverables & Screenshots
Save the file as `powerbi/Federal-Bank-Dashboard.pbix`. Capture a screenshot of each page into the repo's `images/` folder and reference them in the root README.

## Learning Outcomes
- You can connect Power BI to data (CSV and MySQL) and build multi-page reports.
- You can choose the right visual for a KPI (card, line, bar, donut, map, table).
- You can add slicers and filters for interactivity.
- You can explain why pushing KPI logic into SQL keeps the dashboard simple.

## Interview Questions
1. **How did you connect Power BI to your data?**
   Via CSV export from the KPI views (and optionally a live MySQL connection with MySQL Connector/NET).
2. **Why so little DAX?**
   The KPIs were computed once in SQL views, so the dashboard just displays them — a single source of truth and less duplicated logic.
3. **How do slicers and filters help stakeholders?**
   They let non-technical users explore (by segment, branch, fraud type) without new queries.
4. **What makes a good executive dashboard?**
   A few headline KPI cards, clear trends, and comparisons — answering the top questions at a glance, with detail a click away.
5. **How would you make this refresh automatically?**
   Use the live MySQL connection and scheduled refresh (via the Power BI service and a gateway).

## Troubleshooting Tips
- **MySQL connector error in Power BI:** install "MySQL Connector/NET", restart Power BI, reconnect.
- **A card shows "Sum of…":** it's a single-row view, so the sum is the value; rename the field or set "Don't summarize".
- **Months out of order on a line chart:** sort `month_name` by a month-number column (Column tools → Sort by column → `month`).
- **Percentages look like whole numbers:** set the column/measure format to a percentage or one-decimal number in the Format pane.
- **CSV imported as one column:** re-import with **Text/CSV** (not Excel) so the comma delimiter is detected.
