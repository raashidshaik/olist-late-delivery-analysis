-- 02_causes_geography.sql
-- Does WHERE the customer is (and how far from the seller) predict lateness?

-- (a) Late rate by customer state, ranked by order volume
WITH base AS (
    SELECT
        o.order_id,
        c.customer_state,
        CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 END AS is_late
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered' AND o.order_delivered_customer_date IS NOT NULL
)
SELECT
    customer_state,
    COUNT(*) AS n_orders,
    ROUND(100.0 * AVG(is_late), 2) AS pct_late
FROM base
GROUP BY 1
ORDER BY n_orders DESC;

-- Result: SP (largest volume) = 5.89% late. Remote North/Northeast states run 2-3x higher:
-- MA 19.67%, CE 15.32%, BA 14.04%, PA 12.37%, ES 12.23% vs core South/Southeast ~5-7%.

-- (b) Late rate: is the seller in the same state as the customer, or a different one?
-- ~1.3% of orders (1,278 / 98,666) have items from more than one seller. To keep
-- "route" a single well-defined value per order, we use the order's FIRST item
-- (order_item_id = 1) as the representative seller -- transparent and reproducible,
-- rather than letting multi-seller orders silently double-count into both buckets.
WITH base AS (
    SELECT
        o.order_id,
        c.customer_state,
        s.seller_state,
        CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 END AS is_late
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id AND oi.order_item_id = 1
    JOIN sellers s ON oi.seller_id = s.seller_id
    WHERE o.order_status = 'delivered' AND o.order_delivered_customer_date IS NOT NULL
)
SELECT
    CASE WHEN customer_state = seller_state THEN 'same_state' ELSE 'different_state' END AS route,
    COUNT(*) AS n_orders,
    ROUND(100.0 * AVG(is_late), 2) AS pct_late
FROM base
GROUP BY 1;

-- Result: same-state ~6.0% late vs different-state ~9.2% late -- roughly a 50%
-- relative jump when the order has to travel across a state line.
