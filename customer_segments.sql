-- ============================================================
-- QUERIES: Customer Segmentation & LTV
-- File:    queries/business/customer_segments.sql
-- ============================================================

-- 1. RFM segments summary
SELECT
    rfm_label,
    COUNT(*)                        AS customers,
    ROUND(AVG(monetary), 2)         AS avg_lifetime_value,
    ROUND(AVG(frequency), 1)        AS avg_orders,
    ROUND(AVG(recency_days), 0)     AS avg_days_since_last_order
FROM v_customer_rfm
GROUP BY rfm_label
ORDER BY avg_lifetime_value DESC;

-- ────────────────────────────────────────────────────────────
-- 2. High-value customers at risk (Champions who haven't ordered recently)
SELECT
    email,
    name,
    company,
    segment,
    acquisition_channel,
    recency_days,
    frequency        AS total_orders,
    monetary         AS total_spent,
    rfm_label
FROM v_customer_rfm
WHERE rfm_label IN ('At Risk - High Value', 'Champions')
  AND recency_days > 45
ORDER BY monetary DESC;

-- ────────────────────────────────────────────────────────────
-- 3. Customer Lifetime Value by acquisition channel (12-month LTV)
WITH customer_orders AS (
    SELECT
        c.id,
        c.acquisition_channel,
        MIN(o.completed_at)    AS first_order,
        MAX(o.completed_at)    AS last_order,
        COUNT(o.id)            AS num_orders,
        SUM(o.total_amount)    AS total_revenue,
        EXTRACT(MONTH FROM AGE(MAX(o.completed_at), MIN(o.completed_at))) + 1 AS active_months
    FROM customers c
    JOIN orders o ON c.id = o.customer_id AND o.status = 'completed'
    GROUP BY c.id, c.acquisition_channel
)
SELECT
    acquisition_channel,
    COUNT(*)                                     AS customers,
    ROUND(AVG(total_revenue), 2)                 AS avg_ltv,
    ROUND(AVG(total_revenue / NULLIF(active_months, 0)) * 12, 2) AS projected_12m_ltv,
    ROUND(AVG(num_orders), 1)                    AS avg_orders,
    ROUND(AVG(active_months), 1)                 AS avg_active_months
FROM customer_orders
GROUP BY acquisition_channel
ORDER BY avg_ltv DESC;

-- ────────────────────────────────────────────────────────────
-- 4. Monthly customer retention (cohort)
WITH first_orders AS (
    SELECT customer_id, DATE_TRUNC('month', MIN(completed_at))::DATE AS cohort
    FROM orders WHERE status = 'completed'
    GROUP BY customer_id
),
activity AS (
    SELECT
        fo.cohort,
        fo.customer_id,
        DATE_TRUNC('month', o.completed_at)::DATE AS active_month
    FROM first_orders fo
    JOIN orders o ON o.customer_id = fo.customer_id AND o.status = 'completed'
    GROUP BY fo.cohort, fo.customer_id, 3
)
SELECT
    cohort,
    active_month,
    COUNT(DISTINCT customer_id) AS active_customers,
    FIRST_VALUE(COUNT(DISTINCT customer_id)) OVER (
        PARTITION BY cohort ORDER BY active_month
    ) AS cohort_size,
    ROUND(
        100.0 * COUNT(DISTINCT customer_id) /
        FIRST_VALUE(COUNT(DISTINCT customer_id)) OVER (
            PARTITION BY cohort ORDER BY active_month
        ), 1
    ) AS retention_pct
FROM activity
GROUP BY cohort, active_month
ORDER BY cohort, active_month;

-- ────────────────────────────────────────────────────────────
-- 5. New vs returning customer revenue split (monthly)
WITH tagged_orders AS (
    SELECT
        o.id,
        o.customer_id,
        o.total_amount,
        DATE_TRUNC('month', o.completed_at)::DATE AS month,
        ROW_NUMBER() OVER (PARTITION BY o.customer_id ORDER BY o.completed_at) AS order_rank
    FROM orders o
    WHERE o.status = 'completed'
)
SELECT
    month,
    SUM(total_amount) FILTER (WHERE order_rank = 1) AS new_customer_revenue,
    SUM(total_amount) FILTER (WHERE order_rank > 1) AS returning_customer_revenue,
    COUNT(DISTINCT customer_id) FILTER (WHERE order_rank = 1) AS new_customers,
    COUNT(DISTINCT customer_id) FILTER (WHERE order_rank > 1) AS returning_customers
FROM tagged_orders
GROUP BY month
ORDER BY month;
