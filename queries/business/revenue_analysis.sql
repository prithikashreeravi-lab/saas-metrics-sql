-- ============================================================
-- QUERIES: Revenue & SaaS Metrics
-- File:    queries/business/revenue_analysis.sql
-- ============================================================

-- 1. Monthly Recurring Revenue (MRR) — current snapshot
SELECT
    DATE_TRUNC('month', NOW())::DATE  AS month,
    SUM(mrr)                          AS total_mrr,
    SUM(mrr) * 12                     AS arr,
    COUNT(*)                          AS active_subscriptions,
    COUNT(DISTINCT customer_id)       AS paying_customers
FROM subscriptions
WHERE status = 'active';

-- ────────────────────────────────────────────────────────────
-- 2. MRR growth trend (last 12 months)
WITH monthly AS (
    SELECT
        DATE_TRUNC('month', current_period_start)::DATE AS month,
        SUM(mrr)                                        AS mrr
    FROM subscriptions
    WHERE status = 'active'
      AND current_period_start >= NOW() - INTERVAL '13 months'
    GROUP BY 1
)
SELECT
    month,
    mrr,
    LAG(mrr) OVER (ORDER BY month)                          AS prev_month_mrr,
    mrr - LAG(mrr) OVER (ORDER BY month)                    AS mrr_change,
    ROUND(
        100.0 * (mrr - LAG(mrr) OVER (ORDER BY month))
        / NULLIF(LAG(mrr) OVER (ORDER BY month), 0), 1
    )                                                        AS mom_growth_pct
FROM monthly
ORDER BY month;

-- ────────────────────────────────────────────────────────────
-- 3. Cohort revenue retention (monthly cohorts)
WITH cohorts AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', MIN(completed_at))::DATE AS cohort_month
    FROM orders
    WHERE status = 'completed'
    GROUP BY customer_id
),
cohort_revenue AS (
    SELECT
        c.cohort_month,
        DATE_TRUNC('month', o.completed_at)::DATE                             AS order_month,
        EXTRACT(MONTH FROM AGE(
            DATE_TRUNC('month', o.completed_at),
            c.cohort_month
        ))::INT                                                                AS months_since_first,
        SUM(o.total_amount)                                                    AS revenue,
        COUNT(DISTINCT o.customer_id)                                          AS customers
    FROM orders o
    JOIN cohorts c ON c.customer_id = o.customer_id
    WHERE o.status = 'completed'
    GROUP BY c.cohort_month, order_month, months_since_first
)
SELECT
    cohort_month,
    months_since_first,
    customers,
    revenue,
    ROUND(
        100.0 * revenue / FIRST_VALUE(revenue) OVER (
            PARTITION BY cohort_month ORDER BY months_since_first
        ), 1
    ) AS revenue_retention_pct
FROM cohort_revenue
ORDER BY cohort_month, months_since_first;

-- ────────────────────────────────────────────────────────────
-- 4. Revenue by acquisition channel
SELECT
    c.acquisition_channel,
    COUNT(DISTINCT c.id)              AS customers,
    COUNT(o.id)                       AS orders,
    SUM(o.total_amount)               AS total_revenue,
    ROUND(AVG(o.total_amount), 2)     AS avg_order_value,
    ROUND(SUM(o.total_amount) / COUNT(DISTINCT c.id), 2) AS revenue_per_customer
FROM customers c
JOIN orders o ON c.id = o.customer_id AND o.status = 'completed'
GROUP BY c.acquisition_channel
ORDER BY total_revenue DESC;

-- ────────────────────────────────────────────────────────────
-- 5. Churn analysis — subscriptions cancelled by month
SELECT
    DATE_TRUNC('month', cancelled_at)::DATE AS churn_month,
    COUNT(*)                                AS churned_subs,
    SUM(mrr)                                AS churned_mrr,
    ROUND(AVG(
        EXTRACT(DAY FROM cancelled_at - created_at)
    ), 0)                                   AS avg_days_before_churn
FROM subscriptions
WHERE status = 'cancelled'
  AND cancelled_at IS NOT NULL
  AND cancelled_at >= NOW() - INTERVAL '12 months'
GROUP BY 1
ORDER BY 1;

-- ────────────────────────────────────────────────────────────
-- 6. Top products by revenue and margin
SELECT
    p.name,
    p.category,
    p.price,
    COUNT(oi.id)                          AS units_sold,
    SUM(oi.line_total)                    AS gross_revenue,
    SUM(oi.line_total) - SUM(p.cost * oi.quantity) AS gross_profit,
    ROUND(
        100.0 * (SUM(oi.line_total) - SUM(p.cost * oi.quantity))
        / NULLIF(SUM(oi.line_total), 0), 1
    )                                     AS margin_pct
FROM products p
JOIN order_items oi ON p.id = oi.product_id
JOIN orders o       ON o.id = oi.order_id AND o.status = 'completed'
GROUP BY p.id, p.name, p.category, p.price
ORDER BY gross_revenue DESC;
