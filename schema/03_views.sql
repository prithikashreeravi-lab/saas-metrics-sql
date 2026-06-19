-- ============================================================
-- VIEWS: Pre-built Analytical Views
-- File:  03_views.sql
-- ============================================================

-- ------------------------------------------------------------
-- GitHub: Repository Health Score
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW v_repo_health AS
WITH recent_commits AS (
    SELECT repo_id,
           COUNT(*) FILTER (WHERE committed_at >= NOW() - INTERVAL '30 days')  AS commits_30d,
           COUNT(*) FILTER (WHERE committed_at >= NOW() - INTERVAL '90 days')  AS commits_90d,
           MAX(committed_at) AS last_commit_at
    FROM gh_commits
    GROUP BY repo_id
),
recent_stars AS (
    SELECT repo_id,
           COUNT(*) FILTER (WHERE starred_at >= NOW() - INTERVAL '30 days') AS stars_30d
    FROM gh_stars
    GROUP BY repo_id
),
pr_stats AS (
    SELECT repo_id,
           COUNT(*) FILTER (WHERE state = 'merged' AND merged_at >= NOW() - INTERVAL '30 days') AS prs_merged_30d,
           AVG(EXTRACT(EPOCH FROM (merged_at - created_at))/3600)
               FILTER (WHERE state = 'merged') AS avg_merge_hours
    FROM gh_pull_requests
    GROUP BY repo_id
)
SELECT
    r.id,
    r.full_name,
    r.language,
    r.stars_count,
    r.forks_count,
    r.open_issues_count,
    COALESCE(rc.commits_30d, 0)       AS commits_last_30d,
    COALESCE(rs.stars_30d, 0)         AS star_growth_30d,
    COALESCE(pr.prs_merged_30d, 0)    AS prs_merged_30d,
    ROUND(pr.avg_merge_hours::NUMERIC, 1) AS avg_pr_merge_hours,
    rc.last_commit_at,
    -- Health score 0–100
    LEAST(100, (
        COALESCE(rc.commits_30d, 0) * 2 +
        COALESCE(rs.stars_30d,   0) * 3 +
        COALESCE(pr.prs_merged_30d, 0) * 5 +
        CASE WHEN rc.last_commit_at > NOW() - INTERVAL '7 days' THEN 20 ELSE 0 END +
        CASE WHEN r.open_issues_count < 10 THEN 10 ELSE 0 END
    )) AS health_score
FROM gh_repositories r
LEFT JOIN recent_commits rc ON r.id = rc.repo_id
LEFT JOIN recent_stars   rs ON r.id = rs.repo_id
LEFT JOIN pr_stats        pr ON r.id = pr.repo_id
WHERE r.is_archived = FALSE;

-- ------------------------------------------------------------
-- GitHub: Developer Leaderboard
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW v_developer_leaderboard AS
SELECT
    u.id,
    u.login,
    u.name,
    u.company,
    COUNT(DISTINCT c.id)                                                          AS total_commits,
    COUNT(DISTINCT c.id) FILTER (WHERE c.committed_at >= NOW() - INTERVAL '30 days') AS commits_30d,
    COALESCE(SUM(c.additions), 0)                                                 AS total_lines_added,
    COALESCE(SUM(c.deletions), 0)                                                 AS total_lines_deleted,
    COUNT(DISTINCT pr.id)                                                         AS total_prs,
    COUNT(DISTINCT pr.id) FILTER (WHERE pr.state = 'merged')                      AS prs_merged,
    COUNT(DISTINCT pr.id) FILTER (WHERE pr.merged_at >= NOW() - INTERVAL '30 days') AS prs_merged_30d,
    COUNT(DISTINCT i.id)  FILTER (WHERE i.state = 'closed')                       AS issues_closed,
    COUNT(DISTINCT pr.repo_id)                                                    AS repos_contributed
FROM gh_users u
LEFT JOIN gh_commits       c  ON u.id = c.author_id
LEFT JOIN gh_pull_requests pr ON u.id = pr.author_id
LEFT JOIN gh_issues        i  ON u.id = i.assignee_id
WHERE u.is_organization = FALSE
GROUP BY u.id, u.login, u.name, u.company
ORDER BY commits_30d DESC;

-- ------------------------------------------------------------
-- Business: MRR Trend (last 24 months)
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW v_mrr_trend AS
SELECT
    DATE_TRUNC('month', s.current_period_start)::DATE AS month,
    SUM(s.mrr)                                        AS total_mrr,
    COUNT(*)                                          AS active_subscriptions,
    COUNT(DISTINCT s.customer_id)                     AS paying_customers,
    ROUND(AVG(s.mrr), 2)                              AS avg_mrr_per_sub
FROM subscriptions s
WHERE s.status = 'active'
  AND s.current_period_start >= NOW() - INTERVAL '24 months'
GROUP BY 1
ORDER BY 1;

-- ------------------------------------------------------------
-- Business: Customer RFM Segments
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW v_customer_rfm AS
WITH rfm_raw AS (
    SELECT
        c.id,
        c.email,
        c.name,
        c.segment,
        c.acquisition_channel,
        EXTRACT(DAY FROM NOW() - MAX(o.completed_at))   AS recency_days,
        COUNT(o.id)                                      AS frequency,
        SUM(o.total_amount)                              AS monetary
    FROM customers c
    JOIN orders o ON c.id = o.customer_id AND o.status = 'completed'
    GROUP BY c.id, c.email, c.name, c.segment, c.acquisition_channel
),
rfm_scored AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY recency_days ASC)  AS r_score,   -- 5 = most recent
        NTILE(5) OVER (ORDER BY frequency DESC)     AS f_score,
        NTILE(5) OVER (ORDER BY monetary DESC)      AS m_score
    FROM rfm_raw
)
SELECT *,
    (r_score + f_score + m_score)                     AS rfm_total,
    CASE
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
        WHEN r_score >= 3 AND f_score >= 3                  THEN 'Loyal Customers'
        WHEN r_score >= 4                                    THEN 'Recent Customers'
        WHEN f_score >= 4 AND m_score >= 4                  THEN 'At Risk - High Value'
        WHEN r_score <= 2 AND f_score <= 2                  THEN 'Lost Customers'
        ELSE 'Needs Attention'
    END AS rfm_label
FROM rfm_scored;

-- ------------------------------------------------------------
-- Business: Sales Funnel Conversion
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW v_sales_funnel AS
WITH stage_order AS (
    SELECT stage, deal_value, created_at,
           CASE stage
               WHEN 'prospect'    THEN 1
               WHEN 'qualified'   THEN 2
               WHEN 'demo'        THEN 3
               WHEN 'proposal'    THEN 4
               WHEN 'negotiation' THEN 5
               WHEN 'closed_won'  THEN 6
               WHEN 'closed_lost' THEN 7
           END AS stage_rank
    FROM sales_pipeline
)
SELECT
    stage,
    COUNT(*)                          AS deals_count,
    SUM(deal_value)                   AS pipeline_value,
    ROUND(AVG(deal_value), 2)         AS avg_deal_value,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_total
FROM stage_order
GROUP BY stage, stage_rank
ORDER BY stage_rank;
