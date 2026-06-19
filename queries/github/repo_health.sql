-- ============================================================
-- QUERIES: Repository Health Analysis
-- File:    queries/github/repo_health.sql
-- ============================================================

-- 1. Top repos by star growth (last 30 days)
SELECT full_name, language, stars_count, star_growth_30d, health_score
FROM v_repo_health
ORDER BY star_growth_30d DESC
LIMIT 20;

-- ────────────────────────────────────────────────────────────
-- 2. Stagnant repos (no commits in 60+ days, still public)
SELECT
    r.full_name,
    r.language,
    r.stars_count,
    r.open_issues_count,
    MAX(c.committed_at)  AS last_commit_at,
    NOW() - MAX(c.committed_at) AS dormant_for
FROM gh_repositories r
LEFT JOIN gh_commits c ON r.id = c.repo_id
WHERE r.is_archived = FALSE
  AND r.is_private   = FALSE
GROUP BY r.id, r.full_name, r.language, r.stars_count, r.open_issues_count
HAVING MAX(c.committed_at) < NOW() - INTERVAL '60 days'
    OR MAX(c.committed_at) IS NULL
ORDER BY r.stars_count DESC;

-- ────────────────────────────────────────────────────────────
-- 3. Issue velocity — are issues being closed as fast as they open?
WITH monthly_issues AS (
    SELECT
        repo_id,
        DATE_TRUNC('month', created_at)::DATE AS month,
        COUNT(*)                               AS opened,
        COUNT(*) FILTER (WHERE state = 'closed') AS closed
    FROM gh_issues
    WHERE created_at >= NOW() - INTERVAL '6 months'
    GROUP BY repo_id, 2
)
SELECT
    r.full_name,
    mi.month,
    mi.opened,
    mi.closed,
    mi.opened - mi.closed                     AS backlog_delta,
    SUM(mi.opened - mi.closed) OVER (
        PARTITION BY mi.repo_id ORDER BY mi.month
    )                                          AS running_backlog
FROM monthly_issues mi
JOIN gh_repositories r ON r.id = mi.repo_id
ORDER BY r.full_name, mi.month;

-- ────────────────────────────────────────────────────────────
-- 4. Fork-to-star ratio (engagement quality indicator)
SELECT
    full_name,
    language,
    stars_count,
    forks_count,
    ROUND(forks_count::NUMERIC / NULLIF(stars_count, 0), 3) AS fork_star_ratio,
    open_issues_count
FROM gh_repositories
WHERE stars_count > 50
ORDER BY fork_star_ratio DESC
LIMIT 30;

-- ────────────────────────────────────────────────────────────
-- 5. Repos by language — average stars and health
SELECT
    language,
    COUNT(*)                          AS repo_count,
    ROUND(AVG(stars_count), 0)        AS avg_stars,
    SUM(stars_count)                  AS total_stars,
    ROUND(AVG(health_score), 1)       AS avg_health_score,
    MAX(health_score)                 AS top_health_score
FROM v_repo_health
WHERE language IS NOT NULL
GROUP BY language
HAVING COUNT(*) >= 2
ORDER BY avg_health_score DESC;

-- ────────────────────────────────────────────────────────────
-- 6. Release cadence per repo
SELECT
    r.full_name,
    COUNT(rel.id)                                       AS total_releases,
    MAX(rel.published_at)                               AS latest_release,
    MIN(rel.published_at)                               AS first_release,
    ROUND(
        COUNT(rel.id)::NUMERIC /
        NULLIF(
            EXTRACT(MONTH FROM AGE(MAX(rel.published_at), MIN(rel.published_at))),
        0), 2
    )                                                   AS releases_per_month,
    SUM(rel.download_count)                             AS total_downloads
FROM gh_repositories r
JOIN gh_releases rel ON r.id = rel.repo_id
WHERE rel.is_draft = FALSE
GROUP BY r.id, r.full_name
ORDER BY releases_per_month DESC NULLS LAST;
