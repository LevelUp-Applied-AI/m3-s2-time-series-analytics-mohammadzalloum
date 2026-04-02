-- Module 3 Thursday Stretch
-- Trend Analysis
-- Explicit frame clauses are used to compute moving averages.

WITH order_revenue AS (
    SELECT
        oi.order_id,
        SUM(oi.quantity * oi.unit_price) AS order_revenue
    FROM order_items oi
    GROUP BY oi.order_id
),
daily_revenue AS (
    SELECT
        o.order_date,
        SUM(orv.order_revenue) AS daily_revenue
    FROM orders o
    JOIN order_revenue orv
        ON orv.order_id = o.order_id
    WHERE o.status = 'completed'
    GROUP BY o.order_date
)
SELECT
    order_date,
    daily_revenue,
    ROUND(
        AVG(daily_revenue) OVER (
            ORDER BY order_date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS revenue_7d_moving_avg,
    ROUND(
        AVG(daily_revenue) OVER (
            ORDER BY order_date
            ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS revenue_30d_moving_avg,
    ROUND(
        daily_revenue
        - AVG(daily_revenue) OVER (
            ORDER BY order_date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS revenue_vs_7d_avg_gap
FROM daily_revenue
ORDER BY order_date;

WITH daily_orders AS (
    SELECT
        o.order_date,
        COUNT(DISTINCT o.order_id) AS daily_order_count
    FROM orders o
    WHERE o.status = 'completed'
    GROUP BY o.order_date
)
SELECT
    order_date,
    daily_order_count,
    ROUND(
        AVG(daily_order_count) OVER (
            ORDER BY order_date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS orders_7d_moving_avg,
    ROUND(
        AVG(daily_order_count) OVER (
            ORDER BY order_date
            ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS orders_30d_moving_avg,
    ROUND(
        daily_order_count
        - AVG(daily_order_count) OVER (
            ORDER BY order_date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS orders_vs_7d_avg_gap
FROM daily_orders
ORDER BY order_date;
