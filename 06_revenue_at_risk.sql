-- 06_revenue_at_risk.sql
-- Convert the repeat-rate gap from 05 into an expected-dollar-value estimate.
--
-- Method: (# late first-orders) x (repeat-rate gap) = expected "lost" repeat customers.
-- Multiply by the average TOTAL incremental revenue a repeat customer generates across
-- all of their 2nd+ orders (not just one order) to get an expected revenue-at-risk figure
-- for this dataset's ~2-year window (Sep 2016 - Aug 2018).

WITH cust_orders AS (
    SELECT
        c.customer_unique_id,
        o.order_id,
        o.order_purchase_timestamp,
        ROW_NUMBER() OVER (PARTITION BY c.customer_unique_id ORDER BY o.order_purchase_timestamp) AS rn
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
),
order_value AS (
    SELECT order_id, SUM(price + freight_value) AS order_value
    FROM order_items
    GROUP BY 1
),
per_repeat_customer AS (
    SELECT co.customer_unique_id, SUM(ov.order_value) AS total_2nd_plus_revenue
    FROM cust_orders co
    JOIN order_value ov ON co.order_id = ov.order_id
    WHERE co.rn > 1
    GROUP BY 1
)
SELECT
    COUNT(*) AS n_repeat_customers,
    ROUND(AVG(total_2nd_plus_revenue), 2) AS avg_total_incremental_revenue_per_repeat_customer
FROM per_repeat_customer;

-- avg_total_incremental_revenue_per_repeat_customer = $163.15 (n=2,801)
--
-- Revenue-at-risk estimate:
--   late first-time customers          = 7,605
--   repeat-rate gap (on-time vs late)   = 0.52pp = 0.0052
--   expected lost repeat customers      = 7,605 x 0.0052 = 39.5
--   revenue at risk                     = 39.5 x $163.15 = ~$6,452 (this ~2-year window)
--
-- CAVEAT for the memo: this only captures the DIRECT effect of a late order on that
-- same customer's future spend. It does not (and cannot, from this data) capture
-- word-of-mouth or public 1-star reviews deterring OTHER prospective customers --
-- the true cost is almost certainly larger than this figure. State that plainly
-- rather than inflating the number to compensate.
