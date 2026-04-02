-- Module 3 Thursday Stretch
-- Growth Analysis
-- Assumption: revenue/order volume are measured on completed orders only.

WITH order_revenue AS (
    SELECT
        oi.order_id,
        SUM(oi.quantity * oi.unit_price) AS order_revenue
    FROM order_items oi
    GROUP BY oi.order_id
),
monthly_metrics AS (
    SELECT
        DATE_TRUNC('month', o.order_date)::date AS month_start,
        SUM(orv.order_revenue) AS revenue,
        COUNT(DISTINCT o.order_id) AS order_count,
        COUNT(DISTINCT o.customer_id) AS customer_count,
        SUM(orv.order_revenue) / COUNT(DISTINCT o.order_id) AS avg_order_value
    FROM orders o
    JOIN order_revenue orv
        ON orv.order_id = o.order_id
    WHERE o.status = 'completed'
    GROUP BY DATE_TRUNC('month', o.order_date)::date
)
SELECT
    month_start,
    revenue,
    LAG(revenue) OVER (ORDER BY month_start) AS previous_month_revenue,
    ROUND(
        100.0 * (revenue - LAG(revenue) OVER (ORDER BY month_start))
        / NULLIF(LAG(revenue) OVER (ORDER BY month_start), 0),
        2
    ) AS revenue_mom_growth_pct,
    order_count,
    LAG(order_count) OVER (ORDER BY month_start) AS previous_month_orders,
    ROUND(
        100.0 * (order_count - LAG(order_count) OVER (ORDER BY month_start))
        / NULLIF(LAG(order_count) OVER (ORDER BY month_start), 0),
        2
    ) AS order_mom_growth_pct,
    customer_count,
    LAG(customer_count) OVER (ORDER BY month_start) AS previous_month_customers,
    avg_order_value,
    ROUND(
        100.0 * (avg_order_value - LAG(avg_order_value) OVER (ORDER BY month_start))
        / NULLIF(LAG(avg_order_value) OVER (ORDER BY month_start), 0),
        2
    ) AS aov_mom_growth_pct
FROM monthly_metrics
ORDER BY month_start;

WITH order_revenue AS (
    SELECT
        oi.order_id,
        SUM(oi.quantity * oi.unit_price) AS order_revenue
    FROM order_items oi
    GROUP BY oi.order_id
),
quarterly_metrics AS (
    SELECT
        DATE_TRUNC('quarter', o.order_date)::date AS quarter_start,
        SUM(orv.order_revenue) AS revenue,
        COUNT(DISTINCT o.order_id) AS order_count,
        COUNT(DISTINCT o.customer_id) AS customer_count,
        SUM(orv.order_revenue) / COUNT(DISTINCT o.order_id) AS avg_order_value
    FROM orders o
    JOIN order_revenue orv
        ON orv.order_id = o.order_id
    WHERE o.status = 'completed'
    GROUP BY DATE_TRUNC('quarter', o.order_date)::date
)
SELECT
    quarter_start,
    revenue,
    LAG(revenue) OVER (ORDER BY quarter_start) AS previous_quarter_revenue,
    ROUND(
        100.0 * (revenue - LAG(revenue) OVER (ORDER BY quarter_start))
        / NULLIF(LAG(revenue) OVER (ORDER BY quarter_start), 0),
        2
    ) AS revenue_qoq_growth_pct,
    order_count,
    customer_count,
    avg_order_value,
    ROUND(
        100.0 * (avg_order_value - LAG(avg_order_value) OVER (ORDER BY quarter_start))
        / NULLIF(LAG(avg_order_value) OVER (ORDER BY quarter_start), 0),
        2
    ) AS aov_qoq_growth_pct
FROM quarterly_metrics
ORDER BY quarter_start;

WITH order_revenue AS (
    SELECT
        oi.order_id,
        SUM(oi.quantity * oi.unit_price) AS order_revenue
    FROM order_items oi
    GROUP BY oi.order_id
),
ranked_orders AS (
    SELECT
        o.customer_id,
        o.order_id,
        o.order_date,
        ROW_NUMBER() OVER (
            PARTITION BY o.customer_id
            ORDER BY o.order_date, o.order_id
        ) AS purchase_number
    FROM orders o
    WHERE o.status = 'completed'
),
first_orders AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', order_date)::date AS first_purchase_month
    FROM ranked_orders
    WHERE purchase_number = 1
),
monthly_customer_mix AS (
    SELECT
        DATE_TRUNC('month', o.order_date)::date AS month_start,
        SUM(orv.order_revenue) AS revenue,
        COUNT(DISTINCT o.order_id) AS order_count,
        COUNT(DISTINCT o.customer_id) AS customer_count,
        SUM(CASE
            WHEN DATE_TRUNC('month', o.order_date)::date = fo.first_purchase_month
            THEN orv.order_revenue ELSE 0 END) AS new_customer_revenue,
        SUM(CASE
            WHEN DATE_TRUNC('month', o.order_date)::date <> fo.first_purchase_month
            THEN orv.order_revenue ELSE 0 END) AS returning_customer_revenue
    FROM orders o
    JOIN order_revenue orv
        ON orv.order_id = o.order_id
    JOIN first_orders fo
        ON fo.customer_id = o.customer_id
    WHERE o.status = 'completed'
    GROUP BY DATE_TRUNC('month', o.order_date)::date
),
monthly_pricing AS (
    SELECT
        DATE_TRUNC('month', o.order_date)::date AS month_start,
        AVG(100.0 * (p.unit_price - oi.unit_price) / NULLIF(p.unit_price, 0)) AS avg_discount_pct
    FROM orders o
    JOIN order_items oi
        ON oi.order_id = o.order_id
    JOIN products p
        ON p.product_id = oi.product_id
    WHERE o.status = 'completed'
    GROUP BY DATE_TRUNC('month', o.order_date)::date
)
SELECT
    m.month_start,
    m.revenue,
    ROUND(
        100.0 * (m.revenue - LAG(m.revenue) OVER (ORDER BY m.month_start))
        / NULLIF(LAG(m.revenue) OVER (ORDER BY m.month_start), 0),
        2
    ) AS revenue_mom_growth_pct,
    m.order_count,
    ROUND(
        100.0 * (m.order_count - LAG(m.order_count) OVER (ORDER BY m.month_start))
        / NULLIF(LAG(m.order_count) OVER (ORDER BY m.month_start), 0),
        2
    ) AS orders_mom_growth_pct,
    m.customer_count,
    ROUND(m.revenue / NULLIF(m.order_count, 0), 2) AS avg_order_value,
    ROUND(m.new_customer_revenue, 2) AS new_customer_revenue,
    ROUND(m.returning_customer_revenue, 2) AS returning_customer_revenue,
    ROUND(100.0 * m.returning_customer_revenue / NULLIF(m.revenue, 0), 2) AS returning_revenue_share_pct,
    ROUND(mp.avg_discount_pct, 2) AS avg_discount_pct,
    ROUND(
        mp.avg_discount_pct - LAG(mp.avg_discount_pct) OVER (ORDER BY m.month_start),
        2
    ) AS discount_change_vs_prev_month_pct_points
FROM monthly_customer_mix m
JOIN monthly_pricing mp
    ON mp.month_start = m.month_start
ORDER BY m.month_start;
