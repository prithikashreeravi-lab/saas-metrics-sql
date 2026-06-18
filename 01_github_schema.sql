-- ============================================================
-- SCHEMA: GitHub Analytics
-- File:   01_github_schema.sql
-- ============================================================

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pg_trgm;  -- for text search on repo names

-- ------------------------------------------------------------
-- USERS
-- ------------------------------------------------------------
CREATE TABLE gh_users (
    id              BIGSERIAL PRIMARY KEY,
    login           VARCHAR(100) NOT NULL UNIQUE,
    name            VARCHAR(200),
    email           VARCHAR(255),
    company         VARCHAR(200),
    location        VARCHAR(200),
    bio             TEXT,
    public_repos    INT DEFAULT 0,
    followers       INT DEFAULT 0,
    following       INT DEFAULT 0,
    is_organization BOOLEAN DEFAULT FALSE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ------------------------------------------------------------
-- REPOSITORIES
-- ------------------------------------------------------------
CREATE TABLE gh_repositories (
    id               BIGSERIAL PRIMARY KEY,
    owner_id         BIGINT NOT NULL REFERENCES gh_users(id) ON DELETE CASCADE,
    name             VARCHAR(200) NOT NULL,
    full_name        VARCHAR(400) NOT NULL UNIQUE,   -- owner/repo
    description      TEXT,
    language         VARCHAR(100),
    topics           TEXT[],                          -- e.g. ARRAY['python','ml','data']
    is_fork          BOOLEAN DEFAULT FALSE,
    is_archived      BOOLEAN DEFAULT FALSE,
    is_private       BOOLEAN DEFAULT FALSE,
    default_branch   VARCHAR(100) DEFAULT 'main',
    stars_count      INT DEFAULT 0,
    forks_count      INT DEFAULT 0,
    watchers_count   INT DEFAULT 0,
    open_issues_count INT DEFAULT 0,
    size_kb          INT DEFAULT 0,                  -- repo size in KB
    license          VARCHAR(100),
    homepage         VARCHAR(500),
    created_at       TIMESTAMPTZ NOT NULL,
    updated_at       TIMESTAMPTZ NOT NULL,
    pushed_at        TIMESTAMPTZ                     -- last commit push
);

CREATE INDEX idx_repos_owner     ON gh_repositories(owner_id);
CREATE INDEX idx_repos_language  ON gh_repositories(language);
CREATE INDEX idx_repos_stars     ON gh_repositories(stars_count DESC);
CREATE INDEX idx_repos_name_trgm ON gh_repositories USING gin(name gin_trgm_ops);

-- ------------------------------------------------------------
-- COMMITS
-- ------------------------------------------------------------
CREATE TABLE gh_commits (
    id            BIGSERIAL PRIMARY KEY,
    repo_id       BIGINT NOT NULL REFERENCES gh_repositories(id) ON DELETE CASCADE,
    author_id     BIGINT REFERENCES gh_users(id) ON DELETE SET NULL,
    sha           CHAR(40) NOT NULL,
    message       TEXT NOT NULL,
    additions     INT DEFAULT 0,
    deletions     INT DEFAULT 0,
    files_changed INT DEFAULT 0,
    branch        VARCHAR(200),
    is_merge      BOOLEAN DEFAULT FALSE,
    committed_at  TIMESTAMPTZ NOT NULL,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(repo_id, sha)
);

CREATE INDEX idx_commits_repo       ON gh_commits(repo_id);
CREATE INDEX idx_commits_author     ON gh_commits(author_id);
CREATE INDEX idx_commits_time       ON gh_commits(committed_at DESC);
CREATE INDEX idx_commits_repo_time  ON gh_commits(repo_id, committed_at DESC);

-- ------------------------------------------------------------
-- PULL REQUESTS
-- ------------------------------------------------------------
CREATE TABLE gh_pull_requests (
    id              BIGSERIAL PRIMARY KEY,
    repo_id         BIGINT NOT NULL REFERENCES gh_repositories(id) ON DELETE CASCADE,
    author_id       BIGINT REFERENCES gh_users(id) ON DELETE SET NULL,
    number          INT NOT NULL,
    title           VARCHAR(500) NOT NULL,
    body            TEXT,
    state           VARCHAR(20) NOT NULL CHECK (state IN ('open', 'closed', 'merged')),
    is_draft        BOOLEAN DEFAULT FALSE,
    base_branch     VARCHAR(200),
    head_branch     VARCHAR(200),
    additions       INT DEFAULT 0,
    deletions       INT DEFAULT 0,
    commits_count   INT DEFAULT 0,
    comments_count  INT DEFAULT 0,
    reviews_count   INT DEFAULT 0,
    labels          TEXT[],
    merged_by_id    BIGINT REFERENCES gh_users(id) ON DELETE SET NULL,
    created_at      TIMESTAMPTZ NOT NULL,
    updated_at      TIMESTAMPTZ NOT NULL,
    merged_at       TIMESTAMPTZ,
    closed_at       TIMESTAMPTZ,
    UNIQUE(repo_id, number)
);

CREATE INDEX idx_prs_repo         ON gh_pull_requests(repo_id);
CREATE INDEX idx_prs_author       ON gh_pull_requests(author_id);
CREATE INDEX idx_prs_state        ON gh_pull_requests(state);
CREATE INDEX idx_prs_merged_at    ON gh_pull_requests(merged_at DESC) WHERE state = 'merged';

-- ------------------------------------------------------------
-- ISSUES
-- ------------------------------------------------------------
CREATE TABLE gh_issues (
    id              BIGSERIAL PRIMARY KEY,
    repo_id         BIGINT NOT NULL REFERENCES gh_repositories(id) ON DELETE CASCADE,
    author_id       BIGINT REFERENCES gh_users(id) ON DELETE SET NULL,
    assignee_id     BIGINT REFERENCES gh_users(id) ON DELETE SET NULL,
    number          INT NOT NULL,
    title           VARCHAR(500) NOT NULL,
    body            TEXT,
    state           VARCHAR(20) NOT NULL CHECK (state IN ('open', 'closed')),
    labels          TEXT[],
    comments_count  INT DEFAULT 0,
    is_bug          BOOLEAN GENERATED ALWAYS AS ('bug' = ANY(labels)) STORED,
    is_feature      BOOLEAN GENERATED ALWAYS AS ('enhancement' = ANY(labels) OR 'feature' = ANY(labels)) STORED,
    created_at      TIMESTAMPTZ NOT NULL,
    updated_at      TIMESTAMPTZ NOT NULL,
    closed_at       TIMESTAMPTZ,
    UNIQUE(repo_id, number)
);

CREATE INDEX idx_issues_repo      ON gh_issues(repo_id);
CREATE INDEX idx_issues_author    ON gh_issues(author_id);
CREATE INDEX idx_issues_state     ON gh_issues(state);
CREATE INDEX idx_issues_bugs      ON gh_issues(repo_id, created_at) WHERE is_bug = TRUE;

-- ------------------------------------------------------------
-- RELEASES
-- ------------------------------------------------------------
CREATE TABLE gh_releases (
    id            BIGSERIAL PRIMARY KEY,
    repo_id       BIGINT NOT NULL REFERENCES gh_repositories(id) ON DELETE CASCADE,
    author_id     BIGINT REFERENCES gh_users(id) ON DELETE SET NULL,
    tag_name      VARCHAR(200) NOT NULL,
    name          VARCHAR(500),
    body          TEXT,
    is_prerelease BOOLEAN DEFAULT FALSE,
    is_draft      BOOLEAN DEFAULT FALSE,
    download_count INT DEFAULT 0,
    created_at    TIMESTAMPTZ NOT NULL,
    published_at  TIMESTAMPTZ,
    UNIQUE(repo_id, tag_name)
);

CREATE INDEX idx_releases_repo  ON gh_releases(repo_id);
CREATE INDEX idx_releases_time  ON gh_releases(published_at DESC);

-- ------------------------------------------------------------
-- STARS (time-series for growth tracking)
-- ------------------------------------------------------------
CREATE TABLE gh_stars (
    repo_id    BIGINT NOT NULL REFERENCES gh_repositories(id) ON DELETE CASCADE,
    user_id    BIGINT NOT NULL REFERENCES gh_users(id) ON DELETE CASCADE,
    starred_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (repo_id, user_id)
);

CREATE INDEX idx_stars_repo_time ON gh_stars(repo_id, starred_at DESC);
