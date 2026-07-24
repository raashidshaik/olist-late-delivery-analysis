-- 03_causes_category.sql
-- Control check: does the PRODUCT being shipped predict lateness, independent of geography?
-- If category drove lateness, we'd expect a wide spread across categories. We don't see one.

WITH base AS (
    SELECT DISTINCT
        o.order_id,
        p.product_category_name,
        CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 END AS is_late
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    WHERE o.order_status = 'delivered' AND o.order_delivered_customer_date IS NOT NULL
)
SELECT
    product_category_name,
    COUNT(*) AS n_orders,
    ROUND(100.0 * AVG(is_late), 2) AS pct_late
FROM base
GROUP BY 1
ORDER BY n_orders DESC
LIMIT 10;

-- Result: top 10 categories by volume all sit in a narrow 6.95%-8.96% late-rate band.
-- No category stands out. This is the control that rules out "it's a seller/product
-- quality issue" and points the causal story at logistics/geography instead (see 02).
