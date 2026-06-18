-- ============================================================
-- SEED DATA: Business (sample data for testing)
-- File:      data/sample/seed_business.sql
-- ============================================================

-- Products
INSERT INTO products (sku, name, category, price, cost, is_saas, billing_cycle, is_active) VALUES
('PRO-MONTHLY',   'Pro Plan - Monthly',        'SaaS',      49.00,  5.00, TRUE,  'monthly',  TRUE),
('PRO-ANNUAL',    'Pro Plan - Annual',          'SaaS',     490.00, 50.00, TRUE,  'annual',   TRUE),
('TEAM-MONTHLY',  'Team Plan - Monthly',        'SaaS',     199.00, 20.00, TRUE,  'monthly',  TRUE),
('TEAM-ANNUAL',   'Team Plan - Annual',         'SaaS',    1990.00,200.00, TRUE,  'annual',   TRUE),
('ENT-ANNUAL',    'Enterprise Plan - Annual',   'SaaS',    9900.00,800.00, TRUE,  'annual',   TRUE),
('CONSULT-H',     'Consulting (per hour)',       'Services', 200.00,  0.00, FALSE, 'usage',    TRUE),
('TRAINING-1D',   '1-Day Training Workshop',    'Services', 1500.00, 200.00,FALSE,'one_time', TRUE),
('SETUP-FEE',     'Onboarding Setup Fee',       'Services',  500.00, 50.00, FALSE,'one_time', FALSE);

-- Customers
INSERT INTO customers (email, name, company, country, region, segment, acquisition_channel, github_login, first_order_at, last_order_at, total_spent, created_at) VALUES
('alice@techcorp.com',    'Alice Johnson',    'TechCorp',          'US', 'West',    'enterprise',  'inbound',     'nicowillis', NOW()-INTERVAL '18 months', NOW()-INTERVAL '5 days',  48500.00, NOW()-INTERVAL '18 months'),
('bob@startup.io',        'Bob Martinez',     'Startup.io',        'US', 'East',    'startup',     'github',      'sarah_dev',  NOW()-INTERVAL '8 months',  NOW()-INTERVAL '15 days', 1960.00,  NOW()-INTERVAL '8 months'),
('clara@midmarket.co',    'Clara Schmidt',    'MidMarket GmbH',    'DE', 'DACH',    'mid_market',  'referral',    NULL,         NOW()-INTERVAL '12 months', NOW()-INTERVAL '1 month', 5970.00,  NOW()-INTERVAL '12 months'),
('david@enterprise.com',  'David Lee',        'Enterprise Co',     'SG', 'APAC',    'enterprise',  'event',       'lars_dev',   NOW()-INTERVAL '24 months', NOW()-INTERVAL '2 months',98000.00, NOW()-INTERVAL '24 months'),
('eva@smb.com',           'Eva Novak',        'EVA SMB',           'PL', 'EMEA',    'smb',         'paid_search', NULL,         NOW()-INTERVAL '3 months',  NOW()-INTERVAL '3 months',  490.00, NOW()-INTERVAL '3 months'),
('frank@techco.com',      'Frank Osei',       'TechCo Africa',     'GH', 'Africa',  'smb',         'organic',     'carlos_m',   NOW()-INTERVAL '6 months',  NOW()-INTERVAL '2 months',  980.00, NOW()-INTERVAL '6 months'),
('grace@bigcorp.com',     'Grace Liu',        'BigCorp Inc',       'US', 'Midwest', 'enterprise',  'outbound',    'priya_k',    NOW()-INTERVAL '30 months', NOW()-INTERVAL '1 month', 79200.00, NOW()-INTERVAL '30 months'),
('hiro@techkk.jp',        'Hiroshi Tanaka',   'TechKK KK',         'JP', 'APAC',    'mid_market',  'referral',    NULL,         NOW()-INTERVAL '14 months', NOW()-INTERVAL '3 months', 7960.00, NOW()-INTERVAL '14 months'),
('isabel@dev.br',         'Isabel Ferreira',  NULL,                'BR', 'LATAM',   'individual',  'github',      'amelia_w',   NOW()-INTERVAL '9 months',  NOW()-INTERVAL '2 months',  980.00, NOW()-INTERVAL '9 months'),
('jack@cloudco.com',      'Jack Hoffman',     'CloudCo',           'AU', 'APAC',    'mid_market',  'paid_search', NULL,         NOW()-INTERVAL '11 months', NOW()-INTERVAL '6 months', 5970.00, NOW()-INTERVAL '11 months');

-- Orders
INSERT INTO orders (customer_id, status, subtotal, discount_amount, tax_amount, total_amount, source_channel, completed_at) VALUES
-- Alice - enterprise, multiple orders
(1, 'completed', 9900.00,  0.00, 0.00, 9900.00,  'inbound',     NOW()-INTERVAL '18 months'),
(1, 'completed', 9900.00,  0.00, 0.00, 9900.00,  'renewal',     NOW()-INTERVAL '6 months'),
(1, 'completed', 500.00,   0.00, 0.00, 500.00,   'upsell',      NOW()-INTERVAL '5 days'),
-- Bob - startup monthly
(2, 'completed', 490.00,   0.00, 0.00, 490.00,   'github',      NOW()-INTERVAL '8 months'),
(2, 'completed', 490.00,   0.00, 0.00, 490.00,   'renewal',     NOW()-INTERVAL '1 month'),
-- Clara - mid market
(3, 'completed', 1990.00,  0.00, 0.00, 1990.00,  'referral',    NOW()-INTERVAL '12 months'),
(3, 'completed', 1990.00,  0.00, 0.00, 1990.00,  'renewal',     NOW()-INTERVAL '1 month'),
-- David - large enterprise
(4, 'completed', 9900.00,  0.00, 0.00, 9900.00,  'event',       NOW()-INTERVAL '24 months'),
(4, 'completed', 9900.00, 990.00, 0.00, 8910.00, 'renewal',     NOW()-INTERVAL '12 months'),
(4, 'completed', 9900.00,  0.00, 0.00, 9900.00,  'renewal',     NOW()-INTERVAL '2 months'),
-- Eva - SMB annual
(5, 'completed', 490.00,   0.00, 0.00, 490.00,   'paid_search', NOW()-INTERVAL '3 months'),
-- Frank - SMB
(6, 'completed', 490.00,   0.00, 0.00, 490.00,   'organic',     NOW()-INTERVAL '6 months'),
(6, 'completed', 490.00,   0.00, 0.00, 490.00,   'renewal',     NOW()-INTERVAL '2 months'),
-- Grace - large enterprise
(7, 'completed', 9900.00,  0.00, 0.00, 9900.00,  'outbound',    NOW()-INTERVAL '30 months'),
(7, 'completed', 9900.00,  0.00, 0.00, 9900.00,  'renewal',     NOW()-INTERVAL '18 months'),
(7, 'completed', 1500.00,  0.00, 0.00, 1500.00,  'upsell',      NOW()-INTERVAL '1 month');

-- Order Items (linking to products)
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount) VALUES
(1,  5, 1, 9900.00, 0),     -- Alice: ENT annual
(2,  5, 1, 9900.00, 0),     -- Alice: ENT renewal
(3,  6, 5, 100.00,  0),     -- Alice: 5 consulting hours
(4,  2, 1, 490.00,  0),     -- Bob: PRO annual
(5,  2, 1, 490.00,  0),     -- Bob renewal
(6,  4, 1, 1990.00, 0),     -- Clara: TEAM annual
(7,  4, 1, 1990.00, 0),     -- Clara renewal
(8,  5, 1, 9900.00, 0),     -- David: ENT annual
(9,  5, 1, 9900.00, 990),   -- David renewal with discount
(10, 5, 1, 9900.00, 0),     -- David 3rd year
(11, 2, 1,  490.00, 0),     -- Eva: PRO annual
(12, 2, 1,  490.00, 0),     -- Frank: PRO annual
(13, 2, 1,  490.00, 0),     -- Frank renewal
(14, 5, 1, 9900.00, 0),     -- Grace: ENT annual
(15, 5, 1, 9900.00, 0),     -- Grace renewal
(16, 7, 1, 1500.00, 0);     -- Grace: Training workshop

-- Subscriptions (active)
INSERT INTO subscriptions (customer_id, product_id, status, plan_name, mrr, current_period_start, current_period_end, created_at) VALUES
(1,  5, 'active', 'Enterprise Annual',    825.00, NOW()-INTERVAL '2 months',  NOW()+INTERVAL '10 months', NOW()-INTERVAL '18 months'),
(2,  2, 'active', 'Pro Annual',           40.83,  NOW()-INTERVAL '1 month',   NOW()+INTERVAL '11 months', NOW()-INTERVAL '8 months'),
(3,  4, 'active', 'Team Annual',          165.83, NOW()-INTERVAL '1 month',   NOW()+INTERVAL '11 months', NOW()-INTERVAL '12 months'),
(4,  5, 'active', 'Enterprise Annual',    825.00, NOW()-INTERVAL '2 months',  NOW()+INTERVAL '10 months', NOW()-INTERVAL '24 months'),
(5,  2, 'active', 'Pro Annual',           40.83,  NOW()-INTERVAL '3 months',  NOW()+INTERVAL '9 months',  NOW()-INTERVAL '3 months'),
(6,  2, 'active', 'Pro Annual',           40.83,  NOW()-INTERVAL '2 months',  NOW()+INTERVAL '10 months', NOW()-INTERVAL '6 months'),
(7,  5, 'active', 'Enterprise Annual',    825.00, NOW()-INTERVAL '1 month',   NOW()+INTERVAL '11 months', NOW()-INTERVAL '30 months'),
(8,  4, 'active', 'Team Annual',          165.83, NOW()-INTERVAL '3 months',  NOW()+INTERVAL '9 months',  NOW()-INTERVAL '14 months'),
(9,  1, 'active', 'Pro Monthly',          49.00,  NOW()-INTERVAL '15 days',   NOW()+INTERVAL '15 days',   NOW()-INTERVAL '9 months'),
(10, 4, 'active', 'Team Annual',          165.83, NOW()-INTERVAL '6 months',  NOW()+INTERVAL '6 months',  NOW()-INTERVAL '11 months');

-- Cancelled subscriptions (for churn analysis)
INSERT INTO subscriptions (customer_id, product_id, status, plan_name, mrr, current_period_start, current_period_end, cancelled_at, created_at) VALUES
(8,  3, 'cancelled', 'Team Monthly', 199.00, NOW()-INTERVAL '6 months', NOW()-INTERVAL '5 months', NOW()-INTERVAL '5 months', NOW()-INTERVAL '8 months'),
(9,  1, 'cancelled', 'Pro Monthly',   49.00, NOW()-INTERVAL '5 months', NOW()-INTERVAL '4 months', NOW()-INTERVAL '4 months', NOW()-INTERVAL '6 months');

-- Sales Pipeline
INSERT INTO sales_pipeline (customer_id, owner_name, company_name, deal_name, stage, deal_value, probability, expected_close, source) VALUES
(NULL, 'Ana Sales',    'Mega Corp',        'Mega Corp Enterprise License',     'negotiation', 49500.00, 70, CURRENT_DATE + 15,  'outbound'),
(NULL, 'Ben Sales',    'Growth Inc',       'Growth Inc Team Expansion',        'proposal',    11940.00, 50, CURRENT_DATE + 30,  'referral'),
(NULL, 'Ana Sales',    'NewCo EU',         'NewCo EU Pro Rollout',             'demo',         4900.00, 30, CURRENT_DATE + 45,  'inbound'),
(1,    'Chris Sales',  'TechCorp',         'TechCorp Enterprise Renewal + Pro','negotiation', 10890.00, 80, CURRENT_DATE + 10,  'renewal'),
(NULL, 'Diana Sales',  'SmallBiz Ltd',     'SmallBiz Annual Upgrade',          'qualified',    1990.00, 40, CURRENT_DATE + 60,  'paid_search'),
(NULL, 'Ben Sales',    'Unicorn Startup',  'Unicorn Startup Series A Deal',    'closed_won',  19800.00, 100, CURRENT_DATE - 5, 'github'),
(NULL, 'Ana Sales',    'Legacy Corp',      'Legacy Corp POC',                  'closed_lost', 49500.00, 0,  CURRENT_DATE - 20, 'outbound'),
(NULL, 'Chris Sales',  'DevShop',          'DevShop Team Plan',                'prospect',     5970.00, 10, CURRENT_DATE + 90, 'organic');

-- MRR Snapshots (last 6 months historical data)
INSERT INTO mrr_snapshots (snapshot_month, new_mrr, expansion_mrr, contraction_mrr, churn_mrr, total_mrr, active_subs, new_customers, churned_customers) VALUES
(DATE_TRUNC('month', NOW() - INTERVAL '5 months')::DATE, 1650.00, 200.00, 49.00, 199.00, 21000.00, 28, 2, 1),
(DATE_TRUNC('month', NOW() - INTERVAL '4 months')::DATE, 825.00,  165.00, 0.00,  49.00,  22941.00, 29, 1, 0),
(DATE_TRUNC('month', NOW() - INTERVAL '3 months')::DATE, 1980.00, 330.00, 165.00,0.00,   25086.00, 31, 3, 0),
(DATE_TRUNC('month', NOW() - INTERVAL '2 months')::DATE, 825.00,  0.00,   0.00,  0.00,   25911.00, 32, 1, 0),
(DATE_TRUNC('month', NOW() - INTERVAL '1 month')::DATE,  1650.00, 825.00, 40.83, 0.00,   28345.17, 34, 2, 0),
(DATE_TRUNC('month', NOW())::DATE,                        825.00,  0.00,   0.00,  0.00,   29170.17, 35, 1, 0);
