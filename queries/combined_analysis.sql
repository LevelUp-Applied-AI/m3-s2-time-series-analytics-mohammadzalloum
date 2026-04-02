-- Module 3 Thursday Stretch
-- Combined Analysis
-- Query 1 combines share-of-month, month-over-month growth, and running totals by segment.
-- Query 2 combines category revenue share, share change, and 3-month moving average trend.
-- Query 3 combines cohort retention with cohort-over-cohort change.

WITH order_revenue AS (
    SELECT
        oi.order_id,
        SUM(oi.quantity * oi.unit_price) AS order_revenue
    FROM order_items oi
    GROUP BY oi.order_id
),
monthly_segment AS (
    SELECT
        DATE_TRUNC('month', o.order_date)::date AS month_start,
        c.segment,
        SUM(orv.order_revenue) AS revenue
    FROM orders o
    JOIN order_revenue orv
        ON orv.order_id = o.order_id
    JOIN customers c
        ON c.customer_id = o.customer_id
    WHERE o.status = 'completed'
    GROUP BY
        DATE_TRUNC('month', o.order_date)::date,
        c.segment
)
SELECT
    month_start,
    segment,
    revenue,
    ROUND(
        100.0 * revenue
        / NULLIF(SUM(revenue) OVER (PARTITION BY month_start), 0),
        2
    ) AS monthly_revenue_share_pct,
    LAG(revenue) OVER (
        PARTITION BY segment
        ORDER BY month_start
    ) AS previous_month_revenue,
    ROUND(
        100.0 * (revenue - LAG(revenue) OVER (PARTITION BY segment ORDER BY month_start))
        / NULLIF(LAG(revenue) OVER (PARTITION BY segment ORDER BY month_start), 0),
        2
    ) AS revenue_mom_growth_pct,
    SUM(revenue) OVER (
        PARTITION BY segment
        ORDER BY month_start
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_segment_revenue
FROM monthly_segment
ORDER BY month_start, segment;

WITH monthly_category AS (
    SELECT
        DATE_TRUNC('month', o.order_date)::date AS month_start,
        p.category,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM orders o
    JOIN order_items oi
        ON oi.order_id = o.order_id
    JOIN products p
        ON p.product_id = oi.product_id
    WHERE o.status = 'completed'
    GROUP BY
        DATE_TRUNC('month', o.order_date)::date,
        p.category
),
category_share AS (
    SELECT
        month_start,
        category,
        revenue,
        100.0 * revenue / NULLIF(SUM(revenue) OVER (PARTITION BY month_start), 0) AS revenue_share_pct
    FROM monthly_category
)
SELECT
    month_start,
    category,
    revenue,
    ROUND(revenue_share_pct, 2) AS revenue_share_pct,
    ROUND(
        AVG(revenue) OVER (
            PARTITION BY category
            ORDER BY month_start
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS revenue_3mo_moving_avg,
    ROUND(
        revenue_share_pct
        - LAG(revenue_share_pct) OVER (
            PARTITION BY category
            ORDER BY month_start
        ),
        2
    ) AS share_change_vs_prev_month_pct_points
FROM category_share
ORDER BY month_start, category;

WITH completed_orders AS (
    SELECT
        o.customer_id,
        o.order_id,
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
cohort_30d_retention AS (
    SELECT
        f.cohort_month,
        SUM(
            CASE
                WHEN f.first_order_date <= (SELECT max_order_date FROM date_bounds) - INTERVAL '30 days'
                THEN 1 ELSE 0 END
        ) AS eligible_30d_customers,
        SUM(
            CASE
                WHEN f.first_order_date <= (SELECT max_order_date FROM date_bounds) - INTERVAL '30 days'
                 AND EXISTS (
                    SELECT 1
                    FROM completed_orders c
                    WHERE c.customer_id = f.customer_id
                      AND c.order_date > f.first_order_date
                      AND c.order_date <= f.first_order_date + INTERVAL '30 days'
                 )
                THEN 1 ELSE 0 END
        ) AS repeat_30d_customers
    FROM first_orders f
    GROUP BY f.cohort_month
)
SELECT
    cohort_month,
    eligible_30d_customers,
    repeat_30d_customers,
    ROUND(
        100.0 * repeat_30d_customers / NULLIF(eligible_30d_customers, 0),
        2
    ) AS repeat_30d_pct,
    ROUND(
        (
            100.0 * repeat_30d_customers / NULLIF(eligible_30d_customers, 0)
        ) - LAG(
            100.0 * repeat_30d_customers / NULLIF(eligible_30d_customers, 0)
        ) OVER (ORDER BY cohort_month),
        2
    ) AS cohort_over_cohort_change_pct_points
FROM cohort_30d_retention
WHERE eligible_30d_customers > 0
ORDER BY cohort_month;
