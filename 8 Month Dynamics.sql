/* Monthly loss trend analysis that aggregates unprofitable orders by month, 
calculating total loss orders and total losses, ranked by highest loss amounts.*/

SELECT 
    to_char(s.order_date,'YYYY-MM') AS month,
    COUNT(s.order_id) AS loss_orders,
    SUM(-s.profit) AS total_losses
FROM fact_sales s
WHERE s.profit<=0
GROUP BY month
ORDER BY total_losses desc;