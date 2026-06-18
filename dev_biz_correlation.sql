-- ============================================================
-- QUERIES: Developer Activity × Business Outcomes
-- File:    queries/combined/dev_biz_correlation.sql
--
-- NOTE: These queries require that customers.github_login is
--       populated, linking customers to gh_users.login.
-- ============================================================

-- 1. Do GitHub customers have higher LTV than non-GitHub customers?
SELECT
    CASE WHEN c.github_login IS NOT NULL THEN 'GitHub User' ELSE 'Non-GitHub' END AS customer_type,
    COUNT(DISTINCT c.id)              AS customers,
    ROUND(AVG(c.total_spent), 2)      AS avg_ltv,
    ROUND(SUM(c.total_spent), 2)      AS total_revenue,
    ROUND(AVG(
        (SELECT COUNT(*) FROM orders o WHERE o.customer_id = c.id AND o.status = 'completed')
    ), 1)                             AS avg_orders
FROM customers c
WHERE c.is_active = TRUE
GROUP BY 1
ORDER BY avg_ltv DESC;

-- ────────────────────────────────────────────────────────────
-- 2. Release impact on revenue — do releases drive spikes?
WITH releases AS (
    SELECT
        repo_id,
        published_at::DATE  AS release_date,
        tag_name
    FROM gh_releases
    WHERE is_draft = FALSE AND is_prerelease = FALSE
),
daily_revenue AS (
    SELECT
        completed_at::DATE  AS order_date,
        SUM(total_amount)   AS daily_revenue,
        COUNT(*)            AS orders
    FROM orders
    WHERE status = 'completed'
    GROUP BY 1
)
SELECT
    r.tag_name,
    r.release_date,
    dr_before.daily_revenue  AS revenue_day_before,
    dr_on.daily_revenue      AS revenue_on_release_day,
    dr_after.daily_revenue   AS revenue_day_after,
    ROUND(
        (COALESCE(dr_on.daily_revenue, 0) - COALESCE(dr_before.daily_revenue, 0))
        / NULLIF(dr_before.daily_revenue, 0) * 100, 1
    )                        AS pct_change_on_release
FROM releases r
LEFT JOIN daily_revenue dr_before ON dr_before.order_date = r.release_date - 1
LEFT JOIN daily_revenue dr_on     ON dr_on.order_date     = r.release_date
LEFT JOIN daily_revenue dr_after  ON dr_after.order_date  = r.release_date + 1
ORDER BY r.release_date DESC;

-- ────────────────────────────────────────────────────────────
-- 3. Top contributors who are also customers
SELECT
    u.login,
    u.name,
    dl.commits_30d,
    dl.prs_merged,
    c.company,
    c.segment,
    c.total_spent,
    c.acquisition_channel
FROM v_developer_leaderboard dl
JOIN gh_users u  ON u.id = dl.id
JOIN customers c ON c.github_login = u.login
ORDER BY dl.commits_30d DESC;

-- ────────────────────────────────────────────────────────────
-- 4. Bug issues filed vs revenue impact (correlate bug density with churn)
WITH monthly_bugs AS (
    SELECT
        DATE_TRUNC('month', i.created_at)::DATE AS month,
        COUNT(*) AS bugs_opened,
        COUNT(*) FILTER (WHERE i.state = 'closed') AS bugs_closed
    FROM gh_issues i
    WHERE i.is_bug = TRUE
    GROUP BY 1
),
monthly_churn AS (
    SELECT
        DATE_TRUNC('month', cancelled_at)::DATE AS month,
        COUNT(*) AS churned_subs,
        SUM(mrr) AS churned_mrr
    FROM subscriptions
    WHERE status = 'cancelled'
    GROUP BY 1
)
SELECT
    b.month,
    b.bugs_opened,
    b.bugs_closed,
    b.bugs_opened - b.bugs_closed     AS net_bug_backlog,
    COALESCE(ch.churned_subs, 0)      AS churned_subs,
    COALESCE(ch.churned_mrr, 0)       AS churned_mrr
FROM monthly_bugs b
LEFT JOIN monthly_churn ch ON ch.month = b.month
ORDER BY b.month;

-- ────────────────────────────────────────────────────────────
-- 5. Commit volume vs monthly order volume (are busy dev months good biz months?)
WITH monthly_commits AS (
    SELECT DATE_TRUNC('month', committed_at)::DATE AS month, COUNT(*) AS commits
    FROM gh_commits WHERE is_merge = FALSE
    GROUP BY 1
),
monthly_orders AS (
    SELECT DATE_TRUNC('month', completed_at)::DATE AS month,
           COUNT(*) AS orders, SUM(total_amount) AS revenue
    FROM orders WHERE status = 'completed'
    GROUP BY 1
)
SELECT
    mc.month,
    mc.commits,
    COALESCE(mo.orders, 0)                          AS orders,
    COALESCE(mo.revenue, 0)                         AS revenue,
    CORR(mc.commits, mo.revenue) OVER (
        ORDER BY mc.month
        ROWS BETWEEN 5 PRECEDING AND CURRENT ROW
    )                                               AS rolling_6m_correlation
FROM monthly_commits mc
LEFT JOIN monthly_orders mo ON mo.month = mc.month
ORDER BY mc.month;
