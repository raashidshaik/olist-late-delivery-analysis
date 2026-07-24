-- 04_review_score_impact.sql
-- How much does a late delivery move customer satisfaction (review_score)?

WITH base AS (
    SELECT
        o.order_id,
        CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 'late' ELSE 'on_time' END AS delivery_flag
    FROM orders o
    WHERE o.order_status = 'delivered' AND o.order_delivered_customer_date IS NOT NULL
)
SELECT
    b.delivery_flag,
    COUNT(*) AS n_orders,
    ROUND(AVG(r.review_score), 2) AS avg_review_score,
    ROUND(100.0 * SUM(CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_1_2_star
FROM base b
JOIN order_reviews r ON b.order_id = r.order_id
GROUP BY 1;

-- Result: on-time avg 4.29 stars (9.23% give 1-2 stars) vs late avg 2.57 stars
-- (54.03% give 1-2 stars). This is the headline finding -- large, unambiguous,
-- and not sensitive to how "late" is defined.
