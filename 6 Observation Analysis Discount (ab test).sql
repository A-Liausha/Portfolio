/*A/B simulation analysis comparing low discount (0-5%) versus high discount (20%+) strategies 
across product categories, evaluating total orders, gross profit, profit margin, repeat customers, 
and repeat purchase rate.*/   


   WITH discount_buckets_statistics AS (
    SELECT 
        p.category,
        CASE 
            WHEN s.discount = 0 THEN '0%'
            WHEN s.discount <= 0.1 THEN '1-10%'
            WHEN s.discount <= 0.2 THEN '11-20%'
            WHEN s.discount <= 0.3 THEN '21-30%'
            ELSE '>30%'
        END AS discount_bucket,
        COUNT(DISTINCT s.order_id) AS total_orders,
        SUM(s.quantity) AS total_units,
        SUM(s.sales) AS gross_revenue,
        SUM(s.profit) AS gross_profit,
        ROUND(AVG(s.sales / NULLIF(s.quantity, 0)), 2) AS avg_price
    FROM fact_sales s
    JOIN dim_product p ON s.product_id = p.product_id
    GROUP BY p.category, discount_bucket
    ORDER BY gross_profit DESC ),
repeat_customers AS (
    SELECT s.customer_id 
    FROM fact_sales s 
    GROUP BY s.customer_id 
    HAVING COUNT(DISTINCT order_id) > 1),
ab_test AS (
    SELECT 
        p.category,
        CASE 
            WHEN s.discount <= 0.05 THEN 'A (Low Discount 0-5%)'
            WHEN s.discount >= 0.2 THEN 'B (High Discount 20%+)'
        END AS test_group,
        COUNT(*) AS total_orders,
        SUM(s.quantity) AS total_units,
        SUM(s.profit) AS gross_profit,
        AVG(s.profit / NULLIF(s.sales, 0)) AS avg_margin,
        COUNT(DISTINCT rc.customer_id) AS repeat_customers
    FROM fact_sales s
    JOIN dim_product p ON s.product_id = p.product_id
    LEFT JOIN repeat_customers rc ON s.customer_id = rc.customer_id
    WHERE s.discount <= 0.05 OR s.discount >= 0.2
    GROUP BY p.category, test_group
    HAVING COUNT(*) > 10 )
SELECT 
    category,
    test_group,
    total_orders,
    gross_profit,
    ROUND(avg_margin * 100, 2) AS margin_pct,
    repeat_customers,
    ROUND(100.0 * repeat_customers / total_orders, 2) AS repeat_rate
FROM ab_test
ORDER BY category, test_group;

 
