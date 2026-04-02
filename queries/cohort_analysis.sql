-- Module 3 Thursday Stretch
-- Cohort Analysis
-- Assumption: "purchase" means a completed order.
-- Recent cohorts are right-censored, so retention denominators include only
-- customers with a full 30/60/90 day observation window.

WITH completed_orders AS (
    SELECT
        o.order_id,
        o.customer_id,
        o.order_date
    FROM orders o
    WHERE o.status = 'completed'
),
ranked_orders AS (
    SELECT
        customer_id,
        order_id,
        order_date,
        DATE_TRUNC('month', order_date)::date AS order_month,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY order_date, order_id
        ) AS purchase_number
    FROM completed_orders
),
first_orders AS (
    SELECT
        customer_id,
        order_id AS first_order_id,
        order_date AS first_order_date,
        DATE_TRUNC('month', order_date)::date AS cohort_month
    FROM ranked_orders
    WHERE purchase_number = 1
)
SELECT
    cohort_month,
    COUNT(*) AS cohort_size
FROM first_orders
GROUP BY cohort_month
ORDER BY cohort_month;

WITH completed_orders AS (
    SELECT
        o.order_id,
        o.customer_id,
        o.order_date
    FROM orders o
    WHERE o.status = 'completed'
),
ranked_orders AS (
    SELECT
        customer_id,
        order_id,
        order_date,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY order_date, order_id
        ) AS purchase_number
    FROM completed_orders
),
first_orders AS (
    SELECT
        customer_id,
        order_date AS first_order_date,
        DATE_TRUNC('month', order_date)::date AS cohort_month
    FROM ranked_orders
    WHERE purchase_number = 1
),
date_bounds AS (
    SELECT MAX(order_date) AS max_order_date
    FROM completed_orders
),
repeat_flags AS (
    SELECT
        f.customer_id,
        f.cohort_month,
        f.first_order_date,
        MAX(CASE
            WHEN c.order_date > f.first_order_date
             AND c.order_date <= f.first_order_date + INTERVAL '30 days'
            THEN 1 ELSE 0 END) AS repeat_30d,
        MAX(CASE
            WHEN c.order_date > f.first_order_date
             AND c.order_date <= f.first_order_date + INTERVAL '60 days'
            THEN 1 ELSE 0 END) AS repeat_60d,
        MAX(CASE
            WHEN c.order_date > f.first_order_date
             AND c.order_date <= f.first_order_date + INTERVAL '90 days'
            THEN 1 ELSE 0 END) AS repeat_90d,
        CASE
            WHEN f.first_order_date <= (SELECT max_order_date FROM date_bounds) - INTERVAL '30 days'
            THEN 1 ELSE 0 END AS eligible_30d,
        CASE
            WHEN f.first_order_date <= (SELECT max_order_date FROM date_bounds) - INTERVAL '60 days'
            THEN 1 ELSE 0 END AS eligible_60d,
        CASE
            WHEN f.first_order_date <= (SELECT max_order_date FROM date_bounds) - INTERVAL '90 days'
            THEN 1 ELSE 0 END AS eligible_90d
    FROM first_orders f
    LEFT JOIN completed_orders c
        ON c.customer_id = f.customer_id
    GROUP BY
        f.customer_id,
        f.cohort_month,
        f.first_order_date
)
SELECT
    cohort_month,
    COUNT(*) AS cohort_size,
    SUM(eligible_30d) AS eligible_30d_customers,
    SUM(CASE WHEN eligible_30d = 1 THEN repeat_30d ELSE 0 END) AS repeat_30d_customers,
    ROUND(
        100.0 * SUM(CASE WHEN eligible_30d = 1 THEN repeat_30d ELSE 0 END)
        / NULLIF(SUM(eligible_30d), 0),
        2
    ) AS repeat_30d_pct,
    SUM(eligible_60d) AS eligible_60d_customers,
    SUM(CASE WHEN eligible_60d = 1 THEN repeat_60d ELSE 0 END) AS repeat_60d_customers,
    ROUND(
        100.0 * SUM(CASE WHEN eligible_60d = 1 THEN repeat_60d ELSE 0 END)
        / NULLIF(SUM(eligible_60d), 0),
        2
    ) AS repeat_60d_pct,
    SUM(eligible_90d) AS eligible_90d_customers,
    SUM(CASE WHEN eligible_90d = 1 THEN repeat_90d ELSE 0 END) AS repeat_90d_customers,
    ROUND(
        100.0 * SUM(CASE WHEN eligible_90d = 1 THEN repeat_90d ELSE 0 END)
        / NULLIF(SUM(eligible_90d), 0),
        2
    ) AS repeat_90d_pct
FROM repeat_flags
GROUP BY cohort_month
ORDER BY cohort_month;

WITH completed_orders AS (
    SELECT
        o.order_id,
        o.customer_id,
        o.order_date
    FROM orders o
    WHERE o.status = 'completed'
),
ranked_orders AS (
    SELECT
        customer_id,
        order_id,
        order_date,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY order_date, order_id
        ) AS purchase_number
    FROM completed_orders
),
first_orders AS (
    SELECT
        customer_id,
        order_date AS first_order_date,
        DATE_TRUNC('month', order_date)::date AS cohort_month
    FROM ranked_orders
    WHERE purchase_number = 1
),
date_bounds AS (
    SELECT MAX(order_date) AS max_order_date
    FROM completed_orders
),
cohort_retention AS (
    SELECT
        f.cohort_month,
        SUM(
            CASE
                WHEN f.first_order_date <= (SELECT max_order_date FROM date_bounds) - INTERVAL '90 days'
                THEN 1 ELSE 0 END
        ) AS eligible_90d_customers,
        SUM(
            CASE
                WHEN f.first_order_date <= (SELECT max_order_date FROM date_bounds) - INTERVAL '90 days'
                 AND EXISTS (
                    SELECT 1
                    FROM completed_orders c
                    WHERE c.customer_id = f.customer_id
                      AND c.order_date > f.first_order_date
                      AND c.order_date <= f.first_order_date + INTERVAL '90 days'
                )
                THEN 1 ELSE 0 END
        ) AS repeat_90d_customers
    FROM first_orders f
    GROUP BY f.cohort_month
)
SELECT
    cohort_month,
    eligible_90d_customers,
    repeat_90d_customers,
    ROUND(100.0 * repeat_90d_customers / NULLIF(eligible_90d_customers, 0), 2) AS repeat_90d_pct
FROM cohort_retention
WHERE eligible_90d_customers > 0
ORDER BY repeat_90d_pct DESC, cohort_month;
