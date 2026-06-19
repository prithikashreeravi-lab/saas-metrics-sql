# 📊 GitHub & Business Analytics — PostgreSQL Project

A production-ready PostgreSQL analytics project combining **GitHub activity data** with **business KPIs** — repository health, developer productivity, sales pipeline, and cross-domain insights.

---

## 📁 Project Structure

```
github_biz_analytics/
├── schema/
│   ├── 01_github_schema.sql       # GitHub repos, users, commits, PRs, issues
│   ├── 02_business_schema.sql     # Customers, products, orders, revenue
│   └── 03_views.sql               # Pre-built analytical views
├── queries/
│   ├── github/
│   │   ├── repo_health.sql        # Star trends, fork ratios, issue velocity
│   │   ├── developer_activity.sql # Commit frequency, PR throughput, top contributors
│   │   └── code_quality.sql       # Review cycles, bug rates, merge times
│   ├── business/
│   │   ├── revenue_analysis.sql   # MRR, ARR, churn, cohort revenue
│   │   ├── customer_segments.sql  # RFM segmentation, LTV, retention
│   │   └── sales_funnel.sql       # Pipeline conversion, deal velocity
│   └── combined/
│       ├── dev_biz_correlation.sql # Release velocity vs revenue impact
│       └── team_roi.sql            # Engineering effort vs business outcomes
├── data/
│   └── sample/
│       ├── seed_github.sql        # Sample GitHub data (50 repos, 200 users)
│       └── seed_business.sql      # Sample business data (500 customers, 2000 orders)
└── docs/
    ├── erd.md                     # Entity-relationship diagram (text)
    └── query_guide.md             # How to use each query file
```

---

## 🚀 Quick Start

### 1. Prerequisites
- PostgreSQL 14+
- `psql` CLI or any PostgreSQL client (DBeaver, pgAdmin, TablePlus)

### 2. Setup Database

```bash
# Create database
psql -U postgres -c "CREATE DATABASE github_biz_analytics;"

# Run schema (in order)
psql -U postgres -d github_biz_analytics -f schema/01_github_schema.sql
psql -U postgres -d github_biz_analytics -f schema/02_business_schema.sql
psql -U postgres -d github_biz_analytics -f schema/03_views.sql

# Load sample data
psql -U postgres -d github_biz_analytics -f data/sample/seed_github.sql
psql -U postgres -d github_biz_analytics -f data/sample/seed_business.sql
```

### 3. Run Your First Query

```bash
psql -U postgres -d github_biz_analytics -f queries/github/repo_health.sql
```

---

## 📌 Key Analyses Available

| Category | Query File | What It Answers |
|---|---|---|
| GitHub | `repo_health.sql` | Which repos are thriving vs stagnant? |
| GitHub | `developer_activity.sql` | Who are the top contributors? PR cycle times? |
| GitHub | `code_quality.sql` | Bug rates, review depth, merge velocity |
| Business | `revenue_analysis.sql` | MRR/ARR trends, churn rate, cohort LTV |
| Business | `customer_segments.sql` | RFM scoring, high-value customer profiles |
| Business | `sales_funnel.sql` | Conversion rates, deal velocity, pipeline health |
| Combined | `dev_biz_correlation.sql` | Do releases drive revenue? |
| Combined | `team_roi.sql` | Engineering ROI per feature shipped |

---

## 🧩 Schema Overview

### GitHub Domain
- `gh_users` — GitHub user profiles
- `gh_repositories` — Repo metadata, stars, forks, language
- `gh_commits` — Commit history with author and timestamps
- `gh_pull_requests` — PR lifecycle (open → review → merged/closed)
- `gh_issues` — Issues with labels, assignees, resolution time
- `gh_releases` — Version tags and release notes

### Business Domain
- `customers` — Customer profiles with acquisition channel
- `products` — Product catalog with pricing tiers
- `orders` — Transactional order history
- `order_items` — Line-item detail per order
- `subscriptions` — SaaS subscription lifecycle
- `sales_pipeline` — CRM pipeline stages and deal values

---

## 💡 Example Insights

```sql
-- Top 5 most productive developers (PRs merged per week)
SELECT * FROM v_developer_leaderboard LIMIT 5;

-- Monthly recurring revenue trend
SELECT * FROM v_mrr_trend WHERE month >= NOW() - INTERVAL '12 months';

-- Repos with declining engagement (star growth < 0)
SELECT * FROM v_repo_health WHERE star_growth_30d < 0 ORDER BY star_growth_30d;
```

---

## 🛠 Tech Stack

- **Database**: PostgreSQL 14+
- **Features used**: CTEs, window functions, JSONB, materialized views, partial indexes
- **Compatible tools**: DBeaver, pgAdmin, Metabase, Grafana, Redash, Superset

---


## 🙋‍♀️ Connect with Me

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue?logo=linkedin)](https://www.linkedin.com/in/https://www.linkedin.com/in/prithikashree/)


## 📄 License

MIT — free to use, adapt, and share.
