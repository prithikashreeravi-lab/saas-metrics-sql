-- ============================================================
-- QUERIES: Sales Funnel & Pipeline
-- File:    queries/business/sales_funnel.sql
-- ============================================================

-- 1. Current pipeline summary by stage
SELECT * FROM v_sales_funnel;

-- ────────────────────────────────────────────────────────────
-- 2. Weighted pipeline value (deal_value × probability)
SELECT
    stage,
    COUNT(*)                                         AS deals,
    SUM(deal_value)                                  AS total_value,
    ROUND(AVG(probability), 1)                       AS avg_probability,
    ROUND(SUM(deal_value * probability / 100.0), 2)  AS weighted_value
FROM sales_pipeline
WHERE stage NOT IN ('closed_won', 'closed_lost')
GROUP BY stage
ORDER BY weighted_value DESC;

-- ────────────────────────────────────────────────────────────
-- 3. Win rate and average deal size by source
SELECT
    source,
    COUNT(*)                                             AS total_deals,
    COUNT(*) FILTER (WHERE stage = 'closed_won')         AS won,
    COUNT(*) FILTER (WHERE stage = 'closed_lost')        AS lost,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE stage = 'closed_won') /
        NULLIF(COUNT(*) FILTER (WHERE stage IN ('closed_won','closed_lost')), 0),
    1)                                                   AS win_rate_pct,
    ROUND(AVG(deal_value) FILTER (WHERE stage = 'closed_won'), 2) AS avg_won_deal
FROM sales_pipeline
GROUP BY source
ORDER BY win_rate_pct DESC NULLS LAST;

-- ────────────────────────────────────────────────────────────
-- 4. Deal velocity — days in pipeline from prospect → close
SELECT
    stage,
    ROUND(AVG(
        EXTRACT(DAY FROM updated_at - created_at)
    ), 1)  AS avg_days_in_stage,
    COUNT(*) AS deals
FROM sales_pipeline
WHERE stage IN ('closed_won', 'closed_lost')
GROUP BY stage

UNION ALL

SELECT
    'All Active' AS stage,
    ROUND(AVG(
        EXTRACT(DAY FROM NOW() - created_at)
    ), 1),
    COUNT(*)
FROM sales_pipeline
WHERE stage NOT IN ('closed_won', 'closed_lost');

-- ────────────────────────────────────────────────────────────
-- 5. Lost deal analysis — top reasons
SELECT
    lost_reason,
    COUNT(*)                    AS occurrences,
    SUM(deal_value)             AS value_lost,
    ROUND(AVG(deal_value), 2)   AS avg_deal_lost
FROM sales_pipeline
WHERE stage = 'closed_lost'
  AND lost_reason IS NOT NULL
GROUP BY lost_reason
ORDER BY occurrences DESC;

-- ────────────────────────────────────────────────────────────
-- 6. Deals closing this month (forecast)
SELECT
    deal_name,
    company_name,
    stage,
    deal_value,
    probability,
    ROUND(deal_value * probability / 100.0, 2) AS expected_value,
    expected_close,
    owner_name
FROM sales_pipeline
WHERE expected_close BETWEEN DATE_TRUNC('month', NOW())::DATE
                         AND (DATE_TRUNC('month', NOW()) + INTERVAL '1 month - 1 day')::DATE
  AND stage NOT IN ('closed_won', 'closed_lost')
ORDER BY expected_value DESC;
