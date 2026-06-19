-- ============================================================
-- SEED DATA: GitHub (sample data for testing)
-- File:      data/sample/seed_github.sql
-- ============================================================

-- Users (mix of individuals and orgs)
INSERT INTO gh_users (login, name, email, company, location, public_repos, followers, is_organization, created_at, updated_at) VALUES
('torvalds',      'Linus Torvalds',   'torvalds@example.com',  'Linux Foundation',    'Portland, OR',    5,    200000, FALSE, '2010-01-01', NOW()),
('gvanrossum',    'Guido van Rossum', 'guido@example.com',     'Microsoft',           'Bellevue, WA',    12,   80000,  FALSE, '2010-03-15', NOW()),
('antirez',       'Salvatore S.',     'antirez@example.com',   'Redis Labs',          'Sicily, IT',      8,    45000,  FALSE, '2011-06-01', NOW()),
('defunkt',       'Chris Wanstrath',  'defunkt@example.com',   'GitHub',              'San Francisco',   25,   30000,  FALSE, '2009-07-01', NOW()),
('mdo',           'Mark Otto',        'mdo@example.com',       'GitHub',              'San Francisco',   30,   25000,  FALSE, '2010-02-10', NOW()),
('addyosmani',    'Addy Osmani',      'addy@example.com',      'Google',              'Mountain View',   40,   60000,  FALSE, '2010-05-20', NOW()),
('sindresorhus',  'Sindre Sorhus',    'sindre@example.com',    NULL,                  'Tromsø, Norway',  200,  90000,  FALSE, '2011-08-12', NOW()),
('tj',            'TJ Holowaychuk',   'tj@example.com',        NULL,                  'Victoria, BC',    150,  40000,  FALSE, '2010-09-01', NOW()),
('substack',      'James Halliday',   'substack@example.com',  NULL,                  'Oakland, CA',     120,  20000,  FALSE, '2011-01-05', NOW()),
('nicowillis',    'Nico Willis',      'nico@example.com',      'Acme Corp',           'Austin, TX',      15,   1200,   FALSE, '2018-04-20', NOW()),
('sarah_dev',     'Sarah Chen',       'sarah@example.com',     'StartupXYZ',          'Singapore',       22,   3400,   FALSE, '2019-07-11', NOW()),
('carlos_m',      'Carlos Mendes',    'carlos@example.com',    'TechBR',              'São Paulo, BR',   18,   2100,   FALSE, '2020-01-15', NOW()),
('priya_k',       'Priya Kumar',      'priya@example.com',     'Infosys',             'Bangalore, IN',   35,   4800,   FALSE, '2017-09-03', NOW()),
('lars_dev',      'Lars Eriksson',    'lars@example.com',      'Spotify',             'Stockholm, SE',   28,   3900,   FALSE, '2016-11-22', NOW()),
('amelia_w',      'Amelia Wong',      'amelia@example.com',    'Shopify',             'Ottawa, CA',      41,   5600,   FALSE, '2015-06-08', NOW()),
-- Organizations
('vercel',        'Vercel',           NULL,                    NULL,                  NULL,              0,    50000,  TRUE,  '2015-01-01', NOW()),
('facebook',      'Meta Open Source',  NULL,                   NULL,                  NULL,              0,    120000, TRUE,  '2009-01-01', NOW()),
('google',        'Google',           NULL,                    NULL,                  NULL,              0,    200000, TRUE,  '2009-01-01', NOW()),
('microsoft',     'Microsoft',        NULL,                    NULL,                  NULL,              0,    180000, TRUE,  '2009-01-01', NOW()),
('stripe',        'Stripe',           NULL,                    NULL,                  NULL,              0,    30000,  TRUE,  '2012-01-01', NOW());

-- Repositories
INSERT INTO gh_repositories (owner_id, name, full_name, description, language, topics, stars_count, forks_count, open_issues_count, size_kb, license, created_at, updated_at, pushed_at) VALUES
(1,  'linux',        'torvalds/linux',       'Linux kernel source tree',            'C',          ARRAY['kernel','linux','os'],             180000, 55000, 450, 4000000, 'GPL-2.0',  '2011-09-04', NOW(), NOW() - INTERVAL '2 hours'),
(2,  'cpython',      'gvanrossum/cpython',   'The Python programming language',     'Python',     ARRAY['python','programming-language'],    58000,  28000, 8500,2500000, 'PSF-2.0',  '2017-02-10', NOW(), NOW() - INTERVAL '5 hours'),
(3,  'redis',        'antirez/redis',        'Redis is an in-memory database',      'C',          ARRAY['database','cache','redis'],         65000,  23000, 1800, 800000, 'BSD-3',    '2013-03-17', NOW(), NOW() - INTERVAL '3 days'),
(6,  'tools',        'addyosmani/tools',     'Front-end tools and utilities',       'JavaScript', ARRAY['frontend','tooling','web'],          8000,   900,  45,   12000, 'MIT',      '2013-07-22', NOW(), NOW() - INTERVAL '14 days'),
(7,  'awesome',      'sindresorhus/awesome', 'Curated list of awesome lists',       NULL,         ARRAY['awesome-list','lists','resources'], 310000, 27000, 120,   3000, 'CC0-1.0',  '2014-07-11', NOW(), NOW() - INTERVAL '1 day'),
(8,  'express',      'tj/express',           'Fast, unopinionated web framework',   'JavaScript', ARRAY['nodejs','framework','web'],          64000,  13000, 360,  350000, 'MIT',     '2009-06-26', NOW(), NOW() - INTERVAL '7 days'),
(16, 'next.js',      'vercel/next.js',       'The React Framework for the Web',     'JavaScript', ARRAY['react','ssr','nextjs','vercel'],    126000, 27000, 2800, 950000, 'MIT',     '2016-10-05', NOW(), NOW() - INTERVAL '6 hours'),
(17, 'react',        'facebook/react',       'A JavaScript library for building UI','JavaScript', ARRAY['react','ui','frontend','facebook'], 228000, 46000, 1100, 480000, 'MIT',     '2013-05-24', NOW(), NOW() - INTERVAL '12 hours'),
(18, 'tensorflow',   'google/tensorflow',    'Open Source ML Framework',            'Python',     ARRAY['machine-learning','ai','python'],   185000, 74000, 3600,5000000, 'Apache-2', '2015-11-09', NOW(), NOW() - INTERVAL '4 hours'),
(19, 'vscode',       'microsoft/vscode',     'Visual Studio Code',                  'TypeScript', ARRAY['editor','ide','typescript'],        165000, 29000, 8500,3500000, 'MIT',     '2015-09-03', NOW(), NOW() - INTERVAL '3 hours'),
(10, 'data-pipeline','nicowillis/data-pipeline','ETL pipeline for analytics',       'Python',     ARRAY['etl','data','python'],               320,    45,    12,   8000, 'MIT',     '2022-03-10', NOW(), NOW() - INTERVAL '5 days'),
(11, 'api-boilerplate','sarah_dev/api-boilerplate','REST API starter kit',          'TypeScript', ARRAY['api','express','typescript'],        1450,   210,   28,  15000, 'MIT',     '2021-08-20', NOW(), NOW() - INTERVAL '2 days');

-- Commits (sample subset)
INSERT INTO gh_commits (repo_id, author_id, sha, message, additions, deletions, files_changed, is_merge, committed_at, created_at) VALUES
(7, 2,  'a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0', 'feat: add Go section to awesome list',                   15,  2, 1, FALSE, NOW() - INTERVAL '1 day',     NOW()),
(7, 3,  'b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0a1', 'fix: remove broken links in databases section',          5,  8, 1, FALSE, NOW() - INTERVAL '2 days',    NOW()),
(7, 6,  'c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0a1b2', 'docs: update contributing guidelines',                   22, 3, 2, FALSE, NOW() - INTERVAL '3 days',    NOW()),
(8, 8,  'd4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0a1b2c3', 'perf: improve route matching speed by 15%',              88, 42, 5, FALSE, NOW() - INTERVAL '4 days',   NOW()),
(8, 9,  'e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0a1b2c3d4', 'feat: add async error handler middleware',               55, 12, 3, FALSE, NOW() - INTERVAL '5 days',   NOW()),
(9, 18, 'f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0a1b2c3d4e5', 'feat(keras): add transformer attention layer',           420,80, 12, FALSE, NOW() - INTERVAL '6 hours', NOW()),
(10,19, 'a7b8c9d0e1f2a3b4c5d6e7f8a9b0a1b2c3d4e5f6', 'fix: patch critical security vulnerability in parser',   30, 25, 2, FALSE, NOW() - INTERVAL '8 hours', NOW()),
(11,10, 'b8c9d0e1f2a3b4c5d6e7f8a9b0a1b2c3d4e5f6a7', 'chore: update typescript to 5.x',                        5, 180, 15, TRUE, NOW() - INTERVAL '1 day',   NOW()),
(12,11, 'c9d0e1f2a3b4c5d6e7f8a9b0a1b2c3d4e5f6a7b8', 'feat: add JWT refresh token support',                    145, 22, 6, FALSE, NOW() - INTERVAL '2 days',  NOW()),
(12,12, 'd0e1f2a3b4c5d6e7f8a9b0a1b2c3d4e5f6a7b8c9', 'test: add integration tests for auth endpoints',         220,  0, 8, FALSE, NOW() - INTERVAL '3 days',  NOW()),
(11,13, 'e1f2a3b4c5d6e7f8a9b0a1b2c3d4e5f6a7b8c9d0', 'fix: memory leak in connection pool',                     40, 35, 3, FALSE, NOW() - INTERVAL '10 days', NOW()),
(11,14, 'f2a3b4c5d6e7f8a9b0a1b2c3d4e5f6a7b8c9d0e1', 'feat: dark mode support',                                280, 10, 9, FALSE, NOW() - INTERVAL '12 days', NOW());

-- Pull Requests
INSERT INTO gh_pull_requests (repo_id, author_id, number, title, state, additions, deletions, commits_count, comments_count, reviews_count, merged_by_id, created_at, updated_at, merged_at) VALUES
(12, 11, 42, 'Add JWT authentication',              'merged', 145, 22, 6,  5, 3, 10, NOW() - INTERVAL '5 days',  NOW() - INTERVAL '2 days',  NOW() - INTERVAL '2 days'),
(12, 12, 43, 'Integration tests for auth',          'merged', 220,  0, 8,  8, 4, 11, NOW() - INTERVAL '4 days',  NOW() - INTERVAL '1 day',   NOW() - INTERVAL '1 day'),
(12, 13, 44, 'Fix memory leak in pool',             'merged',  40, 35, 3,  3, 2, 11, NOW() - INTERVAL '12 days', NOW() - INTERVAL '9 days',  NOW() - INTERVAL '9 days'),
(12, 14, 45, 'Dark mode UI support',                'open',   280, 10, 9,  6, 2, NULL, NOW() - INTERVAL '2 days', NOW(),                      NULL),
(11, 15, 20, 'Upgrade to Node 20 LTS',              'merged',  30, 50, 2,  4, 3, 10, NOW() - INTERVAL '20 days', NOW() - INTERVAL '18 days', NOW() - INTERVAL '18 days'),
(9,  18, 890,'Add multi-head attention',            'merged', 420, 80,12, 14, 6, 18, NOW() - INTERVAL '8 days',  NOW() - INTERVAL '5 days',  NOW() - INTERVAL '5 days'),
(7,   2, 501,'Add Rust awesome list section',       'merged',  15,  2, 1,  2, 1,  7, NOW() - INTERVAL '3 days',  NOW() - INTERVAL '1 day',   NOW() - INTERVAL '1 day'),
(8,   9, 301,'Async error handler',                 'open',    55, 12, 3,  3, 1, NULL, NOW() - INTERVAL '6 days', NOW(),                      NULL);

-- Issues
INSERT INTO gh_issues (repo_id, author_id, number, title, state, labels, comments_count, created_at, updated_at, closed_at) VALUES
(12, 10, 10, 'Token expiry not handled correctly',  'closed', ARRAY['bug','authentication'], 5, NOW() - INTERVAL '15 days', NOW() - INTERVAL '8 days',  NOW() - INTERVAL '8 days'),
(12, 11, 11, 'Add rate limiting to API endpoints',  'open',   ARRAY['enhancement','security'], 3, NOW() - INTERVAL '10 days', NOW(), NULL),
(12, 12, 12, 'Docs: update README with setup steps','closed', ARRAY['documentation'],         2, NOW() - INTERVAL '7 days',  NOW() - INTERVAL '5 days',  NOW() - INTERVAL '5 days'),
(9,  13, 100,'Model training OOM on large datasets', 'open',  ARRAY['bug','performance'],     12, NOW() - INTERVAL '20 days', NOW(), NULL),
(11,  4, 501,'Request: WebSocket support',          'open',   ARRAY['feature','enhancement'], 8, NOW() - INTERVAL '30 days', NOW(), NULL),
(8,   5, 201,'Memory leak in production middleware', 'closed', ARRAY['bug','critical'],       15, NOW() - INTERVAL '45 days', NOW() - INTERVAL '40 days', NOW() - INTERVAL '40 days');

-- Releases
INSERT INTO gh_releases (repo_id, author_id, tag_name, name, is_prerelease, download_count, created_at, published_at) VALUES
(12, 11, 'v1.0.0', 'Initial Release',             FALSE, 1200, NOW() - INTERVAL '60 days', NOW() - INTERVAL '60 days'),
(12, 11, 'v1.1.0', 'Auth & JWT Support',           FALSE, 3400, NOW() - INTERVAL '10 days', NOW() - INTERVAL '10 days'),
(12, 11, 'v1.2.0-beta', 'Dark Mode (Beta)',        TRUE,   200, NOW() - INTERVAL '2 days',  NOW() - INTERVAL '2 days'),
(9,  18, 'v2.14.0','TensorFlow 2.14',              FALSE,280000, NOW() - INTERVAL '30 days', NOW() - INTERVAL '30 days'),
(7,   7, 'v0.145.0','Weekly update',               FALSE,  500, NOW() - INTERVAL '7 days',  NOW() - INTERVAL '7 days');

-- Stars (sample)
INSERT INTO gh_stars (repo_id, user_id, starred_at) VALUES
(12, 10, NOW() - INTERVAL '1 day'),
(12, 13, NOW() - INTERVAL '2 days'),
(12, 14, NOW() - INTERVAL '3 days'),
(12, 15, NOW() - INTERVAL '4 days'),
(11, 11, NOW() - INTERVAL '1 day'),
(11, 12, NOW() - INTERVAL '5 days'),
(7,   2, NOW() - INTERVAL '1 day'),
(7,   4, NOW() - INTERVAL '2 days'),
(7,   5, NOW() - INTERVAL '3 days'),
(9,  13, NOW() - INTERVAL '1 day'),
(9,  14, NOW() - INTERVAL '6 days');
