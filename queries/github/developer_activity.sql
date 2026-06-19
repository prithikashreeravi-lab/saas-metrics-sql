-- ============================================================
-- QUERIES: Developer Activity & Productivity
-- File:    queries/github/developer_activity.sql
-- ============================================================

-- 1. Top 20 contributors (last 90 days)
SELECT
    login, name, company,
    commits_30d,
    prs_merged_30d,
    total_lines_added,
    repos_contributed
FROM v_developer_leaderboard
LIMIT 20;

-- ────────────────────────────────────────────────────────────
-- 2. Commit frequency heatmap (day-of-week × hour-of-day)
SELECT
    TO_CHAR(committed_at AT TIME ZONE 'UTC', 'Dy') AS day_of_week,
    EXTRACT(HOUR FROM committed_at AT TIME ZONE 'UTC')::INT AS hour_utc,
    COUNT(*) AS commit_count
FROM gh_commits
WHERE committed_at >= NOW() - INTERVAL '90 days'
  AND is_merge = FALSE
GROUP BY 1, 2
ORDER BY
    CASE TO_CHAR(committed_at AT TIME ZONE 'UTC', 'Dy')
        WHEN 'Mon' THEN 1 WHEN 'Tue' THEN 2 WHEN 'Wed' THEN 3
        WHEN 'Thu' THEN 4 WHEN 'Fri' THEN 5 WHEN 'Sat' THEN 6 ELSE 7
    END,
    hour_utc;

-- ────────────────────────────────────────────────────────────
-- 3. PR cycle time — time from open to merge by author
SELECT
    u.login,
    COUNT(pr.id)                                           AS prs_merged,
    ROUND(AVG(EXTRACT(EPOCH FROM (pr.merged_at - pr.created_at)) / 3600), 1)   AS avg_hours_to_merge,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (
        ORDER BY EXTRACT(EPOCH FROM (pr.merged_at - pr.created_at)) / 3600
    ), 1)                                                  AS median_hours_to_merge,
    ROUND(AVG(pr.reviews_count), 1)                        AS avg_reviews_per_pr,
    ROUND(AVG(pr.additions + pr.deletions), 0)             AS avg_pr_size_lines
FROM gh_pull_requests pr
JOIN gh_users u ON u.id = pr.author_id
WHERE pr.state = 'merged'
  AND pr.merged_at >= NOW() - INTERVAL '90 days'
GROUP BY u.id, u.login
HAVING COUNT(pr.id) >= 3
ORDER BY avg_hours_to_merge ASC;

-- ────────────────────────────────────────────────────────────
-- 4. Monthly commit trend per developer (last 6 months)
SELECT
    u.login,
    DATE_TRUNC('month', c.committed_at)::DATE AS month,
    COUNT(c.id)                               AS commits,
    SUM(c.additions)                          AS lines_added,
    SUM(c.deletions)                          AS lines_deleted
FROM gh_commits c
JOIN gh_users u ON u.id = c.author_id
WHERE c.committed_at >= NOW() - INTERVAL '6 months'
  AND c.is_merge = FALSE
GROUP BY u.login, 2
ORDER BY u.login, month;

-- ────────────────────────────────────────────────────────────
-- 5. Bus factor analysis — repos dependent on a single contributor
WITH repo_contrib AS (
    SELECT
        repo_id,
        author_id,
        COUNT(*) AS commits,
        ROUND(
            100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY repo_id),
        1) AS pct_of_commits
    FROM gh_commits
    WHERE committed_at >= NOW() - INTERVAL '180 days'
      AND is_merge = FALSE
    GROUP BY repo_id, author_id
)
SELECT
    r.full_name,
    u.login           AS top_contributor,
    rc.commits,
    rc.pct_of_commits AS dominance_pct,
    COUNT(rc2.author_id) OVER (PARTITION BY rc.repo_id) AS total_contributors,
    CASE WHEN rc.pct_of_commits > 60 THEN '⚠️ HIGH BUS FACTOR RISK'
         WHEN rc.pct_of_commits > 40 THEN '⚡ MODERATE RISK'
         ELSE '✅ HEALTHY'
    END AS risk_level
FROM repo_contrib rc
JOIN gh_repositories r ON r.id = rc.repo_id
JOIN gh_users        u ON u.id = rc.author_id
JOIN repo_contrib   rc2 ON rc2.repo_id = rc.repo_id
WHERE rc.pct_of_commits = (
    SELECT MAX(pct_of_commits) FROM repo_contrib WHERE repo_id = rc.repo_id
)
ORDER BY rc.pct_of_commits DESC;

-- ────────────────────────────────────────────────────────────
-- 6. Review load — who is reviewing the most PRs?
SELECT
    u.login                                               AS reviewer,
    COUNT(pr.id)                                          AS prs_reviewed,
    ROUND(AVG(pr.reviews_count), 1)                       AS avg_reviews_given,
    COUNT(DISTINCT pr.repo_id)                            AS repos_reviewed_in,
    MIN(pr.merged_at)::DATE                               AS first_review_date
FROM gh_pull_requests pr
JOIN gh_users u ON u.id = pr.merged_by_id   -- using merged_by as proxy for main reviewer
WHERE pr.state = 'merged'
GROUP BY u.id, u.login
ORDER BY prs_reviewed DESC
LIMIT 15;
