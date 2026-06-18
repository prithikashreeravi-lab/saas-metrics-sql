-- ============================================================
-- SCHEMA: Business Analytics
-- File:   02_business_schema.sql
-- ============================================================

-- ------------------------------------------------------------
-- CUSTOMERS
-- ------------------------------------------------------------
CREATE TABLE customers (
    id                 BIGSERIAL PRIMARY KEY,
    external_id        UUID NOT NULL DEFAULT uuid_generate_v4() UNIQUE,
    email              VARCHAR(255) NOT NULL UNIQUE,
    name               VARCHAR(300) NOT NULL,
    company            VARCHAR(300),
    country            CHAR(2),                   -- ISO 3166-1 alpha-2
    region             VARCHAR(100),
    segment            VARCHAR(50) CHECK (segment IN ('enterprise', 'mid_market', 'smb', 'startup', 'individual')),
    acquisition_channel VARCHAR(100),             -- 'organic','paid_search','referral','github','event', etc.
    github_login       VARCHAR(100),              -- link to gh_users.login
    is_active          BOOLEAN DEFAULT TRUE,
    first_order_at     TIMESTAMPTZ,
    last_order_at      TIMESTAMPTZ,
    total_spent        NUMERIC(12,2) DEFAULT 0,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_customers_segment  ON customers(segment);
CREATE INDEX idx_customers_channel  ON customers(acquisition_channel);
CREATE INDEX idx_customers_github   ON customers(github_login);
CREATE INDEX idx_customers_active   ON customers(is_active, last_order_at DESC);

-- ------------------------------------------------------------
-- PRODUCTS
-- ------------------------------------------------------------
CREATE TABLE products (
    id           BIGSERIAL PRIMARY KEY,
    sku          VARCHAR(100) NOT NULL UNIQUE,
    name         VARCHAR(300) NOT NULL,
    category     VARCHAR(100),
    subcategory  VARCHAR(100),
    price        NUMERIC(10,2) NOT NULL,
    cost         NUMERIC(10,2),                  -- COGS for margin analysis
    is_saas      BOOLEAN DEFAULT FALSE,
    billing_cycle VARCHAR(20) CHECK (billing_cycle IN ('monthly','annual','one_time','usage')),
    is_active    BOOLEAN DEFAULT TRUE,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_products_category ON products(category);

-- ------------------------------------------------------------
-- ORDERS
-- ------------------------------------------------------------
CREATE TABLE orders (
    id              BIGSERIAL PRIMARY KEY,
    customer_id     BIGINT NOT NULL REFERENCES customers(id) ON DELETE RESTRICT,
    status          VARCHAR(30) NOT NULL CHECK (status IN ('pending','processing','completed','refunded','cancelled')),
    currency        CHAR(3) DEFAULT 'USD',
    subtotal        NUMERIC(12,2) NOT NULL,
    discount_amount NUMERIC(12,2) DEFAULT 0,
    tax_amount      NUMERIC(12,2) DEFAULT 0,
    total_amount    NUMERIC(12,2) NOT NULL,
    coupon_code     VARCHAR(50),
    source_channel  VARCHAR(100),               -- where this order originated
    notes           TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at    TIMESTAMPTZ,
    refunded_at     TIMESTAMPTZ
);

CREATE INDEX idx_orders_customer    ON orders(customer_id);
CREATE INDEX idx_orders_status      ON orders(status);
CREATE INDEX idx_orders_created     ON orders(created_at DESC);
CREATE INDEX idx_orders_completed   ON orders(completed_at DESC) WHERE status = 'completed';

-- ------------------------------------------------------------
-- ORDER ITEMS
-- ------------------------------------------------------------
CREATE TABLE order_items (
    id          BIGSERIAL PRIMARY KEY,
    order_id    BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id  BIGINT NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    quantity    INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
    unit_price  NUMERIC(10,2) NOT NULL,
    discount    NUMERIC(10,2) DEFAULT 0,
    line_total  NUMERIC(12,2) GENERATED ALWAYS AS ((unit_price - discount) * quantity) STORED
);

CREATE INDEX idx_order_items_order   ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);

-- ------------------------------------------------------------
-- SUBSCRIPTIONS (SaaS MRR tracking)
-- ------------------------------------------------------------
CREATE TABLE subscriptions (
    id              BIGSERIAL PRIMARY KEY,
    customer_id     BIGINT NOT NULL REFERENCES customers(id) ON DELETE RESTRICT,
    product_id      BIGINT NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    status          VARCHAR(30) NOT NULL CHECK (status IN ('trialing','active','past_due','cancelled','paused')),
    plan_name       VARCHAR(100),
    mrr             NUMERIC(10,2) NOT NULL,       -- monthly recurring revenue for this sub
    quantity        INT DEFAULT 1,
    trial_ends_at   TIMESTAMPTZ,
    current_period_start TIMESTAMPTZ NOT NULL,
    current_period_end   TIMESTAMPTZ NOT NULL,
    cancel_at_period_end BOOLEAN DEFAULT FALSE,
    cancelled_at    TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_subs_customer  ON subscriptions(customer_id);
CREATE INDEX idx_subs_status    ON subscriptions(status);
CREATE INDEX idx_subs_mrr       ON subscriptions(mrr DESC) WHERE status = 'active';

-- ------------------------------------------------------------
-- SALES PIPELINE (CRM)
-- ------------------------------------------------------------
CREATE TABLE sales_pipeline (
    id              BIGSERIAL PRIMARY KEY,
    customer_id     BIGINT REFERENCES customers(id) ON DELETE SET NULL,
    owner_name      VARCHAR(200),                -- sales rep
    company_name    VARCHAR(300),
    deal_name       VARCHAR(400) NOT NULL,
    stage           VARCHAR(50) NOT NULL CHECK (stage IN (
                        'prospect','qualified','demo','proposal','negotiation','closed_won','closed_lost'
                    )),
    deal_value      NUMERIC(12,2),
    probability     NUMERIC(5,2) CHECK (probability BETWEEN 0 AND 100),
    expected_close  DATE,
    actual_close    DATE,
    lost_reason     VARCHAR(200),
    source          VARCHAR(100),               -- 'inbound','outbound','referral','event'
    notes           TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_pipeline_stage       ON sales_pipeline(stage);
CREATE INDEX idx_pipeline_close       ON sales_pipeline(expected_close);
CREATE INDEX idx_pipeline_value       ON sales_pipeline(deal_value DESC);

-- ------------------------------------------------------------
-- MRR SNAPSHOTS (monthly rollup for trend analysis)
-- ------------------------------------------------------------
CREATE TABLE mrr_snapshots (
    snapshot_month  DATE NOT NULL,             -- first day of month
    new_mrr         NUMERIC(12,2) DEFAULT 0,
    expansion_mrr   NUMERIC(12,2) DEFAULT 0,
    contraction_mrr NUMERIC(12,2) DEFAULT 0,
    churn_mrr       NUMERIC(12,2) DEFAULT 0,
    net_new_mrr     NUMERIC(12,2) GENERATED ALWAYS AS (new_mrr + expansion_mrr - contraction_mrr - churn_mrr) STORED,
    total_mrr       NUMERIC(12,2) DEFAULT 0,
    active_subs     INT DEFAULT 0,
    new_customers   INT DEFAULT 0,
    churned_customers INT DEFAULT 0,
    PRIMARY KEY (snapshot_month)
);
