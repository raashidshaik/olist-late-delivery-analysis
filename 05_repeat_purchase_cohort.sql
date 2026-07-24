-- 05_repeat_purchase_cohort.sql
-- Does a customer's FIRST-order delivery experience predict whether they come back?
--
-- IMPORTANT: Olist assigns a new customer_id to every order. customer_unique_id is
-- the only field that identifies the same person across orders. Joining on customer_id
-- instead would make every customer look like a one-time buyer by construction --
-- this is the single most common mistake in public Olist analyses.
--
-- Cohort logic: take each customer's first delivered order, tag it late/on-time,
-- then check whether that customer placed ANY subsequent order.

WITH order_flag AS (
    SELECT
        o.order_id,
        c.customer_unique_id,
        o.order_purchase_timestamp,
        CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 'late' ELSE 'on_time' END AS delivery_flag
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered' AND o.order_delivered_customer_date IS NOT NULL
),
first_orders AS (
    SELECT
        customer_unique_id,
        delivery_flag,
        ROW_NUMBER() OVER (PARTITION BY customer_unique_id ORDER BY order_purchase_timestamp) AS rn,
        COUNT(*) OVER (PARTITION BY customer_unique_id) AS n_total_orders
    FROM order_flag
)
SELECT
    delivery_flag,
    COUNT(*) AS n_first_time_customers,
    SUM(CASE WHEN n_total_orders > 1 THEN 1 ELSE 0 END) AS became_repeat,
    ROUND(100.0 * SUM(CASE WHEN n_total_orders > 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS repeat_rate_pct
FROM first_orders
WHERE rn = 1
GROUP BY 1;

-- Result: on-time first order -> 3.04% repeat (2,609 / 85,745)
--         late first order    -> 2.52% repeat (192 / 7,605)
-- Gap = 0.52pp. Two-proportion z-test: z=2.54, p=0.011 (significant at 95%, not overwhelming).
-- NOTE: platform-wide repeat-purchase rate on Olist is ~3% regardless of delivery
-- experience -- this caps how large any "revenue at risk" number from this angle can be.
