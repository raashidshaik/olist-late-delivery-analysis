-- 01_late_delivery_rate.sql
-- Baseline: what share of delivered orders arrived after the estimated delivery date?
-- "Late" = order_delivered_customer_date > order_estimated_delivery_date
-- Scope: order_status = 'delivered' only (in-flight/canceled/unavailable orders excluded
-- since they don't have a real delivery outcome to evaluate).

SELECT
    CASE
        WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 'late'
        ELSE 'on_time'
    END AS delivery_flag,
    COUNT(*) AS n_orders,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_delivered
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL  -- 8 rows have a null delivery date; drop
GROUP BY 1;

-- Result: 91.89% on-time, 8.11% late (n=96,478 delivered orders with a valid delivery date)
