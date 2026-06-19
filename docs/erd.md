# Entity Relationship Diagram

## GitHub Domain

```
gh_users (1) ──────────────────────────────────────── (N) gh_repositories
    │                                                          │
    │ (author_id)                                              │ (repo_id)
    ├──────────── (N) gh_commits ──────────────────────────────┤
    │                                                          │
    ├──────────── (N) gh_pull_requests (merged_by_id) ─────────┤
    │                                                          │
    ├──────────── (N) gh_issues (assignee_id) ─────────────────┤
    │                                                          │
    ├──────────── (N) gh_releases ─────────────────────────────┤
    │                                                          │
    └──────────── (N) gh_stars ────────────────────────────────┘
```

## Business Domain

```
customers (1) ──────────────────── (N) orders (1) ──── (N) order_items (N) ── (1) products
    │                                                                 
    └──────────── (N) subscriptions (N) ──────────────────────────── (1) products
    │                                                                 
    └──────────── (N) sales_pipeline                                  
```

## Cross-Domain Link

```
customers.github_login ←── (optional FK) ──→ gh_users.login
```

## Key Cardinalities

| Relationship | Type |
|---|---|
| gh_users → gh_repositories | 1:N (owner) |
| gh_repositories → gh_commits | 1:N |
| gh_repositories → gh_pull_requests | 1:N |
| gh_repositories → gh_issues | 1:N |
| gh_users → gh_commits | 1:N (author) |
| customers → orders | 1:N |
| orders → order_items | 1:N |
| products → order_items | 1:N |
| customers → subscriptions | 1:N |
| products → subscriptions | 1:N |
| customers → sales_pipeline | 1:N (optional) |
| gh_users ↔ gh_repositories | M:N (via gh_stars) |
