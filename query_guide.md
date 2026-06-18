# Query Guide

## GitHub Queries

### `repo_health.sql`
Analyzes repository vitality — star growth, commit frequency, issue velocity.

**Key queries:**
- Top repos by 30-day star growth
- Stagnant repos (no commits in 60+ days)
- Issue open vs close velocity by month
- Fork-to-star ratio (quality signal)
- Language benchmarks

**Use when:** You want to identify your most and least active repos, or benchmark across languages.

---

### `developer_activity.sql`
Measures individual contributor productivity and team patterns.

**Key queries:**
- Top 20 contributors leaderboard
- Commit heatmap (day × hour) — when is your team most active?
- PR cycle time by author (median + average)
- Monthly commit trends per developer
- Bus factor analysis — single-contributor risk per repo
- Review load distribution

**Use when:** Engineering management wants velocity data, or you're identifying bottlenecks.

---

### `code_quality.sql`
*(Extend this file with queries like:)*
- PR size distribution (small vs large diffs)
- Bug-to-feature issue ratio over time
- Time-to-first-response on issues

---

## Business Queries

### `revenue_analysis.sql`
Core SaaS financial metrics.

**Key queries:**
- Current MRR snapshot
- 12-month MRR growth + month-over-month %
- Cohort revenue retention table
- Revenue breakdown by acquisition channel
- Monthly churn (cancelled subs + MRR lost)
- Product revenue and margin analysis

**Use when:** Monthly board reporting, investor updates, or pricing decisions.

---

### `customer_segments.sql`
RFM scoring and customer lifetime value.

**Key queries:**
- RFM segment summary (Champions, Loyal, At Risk, Lost)
- High-value customers at churn risk
- 12-month projected LTV by acquisition channel
- Monthly retention cohort (% of customers who return)
- New vs returning customer revenue split

**Use when:** Marketing wants to prioritize re-engagement campaigns or identify best-fit customer profiles.

---

### `sales_funnel.sql`
CRM pipeline health and conversion analysis.

**Key queries:**
- Funnel snapshot by stage (count + value)
- Weighted pipeline value (adjusted by probability)
- Win rate and average deal by source
- Deal velocity (days per stage)
- Lost deal reason analysis
- Deals forecast to close this month

**Use when:** Sales planning, pipeline reviews, or quarter forecasting.

---

## Combined Queries

### `dev_biz_correlation.sql`
Cross-domain analysis linking engineering activity to business outcomes.

**Key queries:**
- GitHub customers vs non-GitHub LTV comparison
- Release days → revenue spike analysis
- Top contributors who are also paying customers
- Bug backlog vs churn correlation
- Monthly commit volume vs order volume (rolling correlation)

**Use when:** You want to prove (or disprove) that engineering investment drives revenue, or that product quality affects retention.

---

## Tips

**Run all files in sequence:**
```bash
for f in schema/*.sql; do psql -d github_biz_analytics -f "$f"; done
for f in data/sample/*.sql; do psql -d github_biz_analytics -f "$f"; done
```

**Export results to CSV:**
```bash
psql -d github_biz_analytics -c "\COPY (SELECT * FROM v_repo_health) TO 'repo_health.csv' CSV HEADER"
```

**Connect a BI tool (Metabase example):**
- Host: `localhost`, Port: `5432`
- Database: `github_biz_analytics`
- All views (prefixed `v_`) are ready to use as data sources
