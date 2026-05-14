/* Overhead cost analysis of unprofitable orders that segments orders by size (Nano, Small, Medium, Large) 
and calculates average loss, average overhead costs, and overhead percentage for orders where overheads 
exceed 25% of sales.*/

SELECT 
    CASE 
        WHEN sales < 200 THEN 'Nano Orders (<200)'
        WHEN sales < 500 THEN 'Small Orders (200-500)'
        WHEN sales < 1000 THEN 'Medium Orders (500-1000)'
        ELSE 'Large Orders (1000+)'
    END AS order_size,
    COUNT(*) AS orders,
    ROUND(AVG(-profit), 2) AS avg_loss,
    ROUND(AVG(personnel_cost + storage_costs + selling_costs), 2) AS avg_overheads,
    ROUND(100.0 * AVG(personnel_cost + storage_costs + selling_costs) / AVG(sales), 1) AS overheads_pct
FROM fact_sales
WHERE profit <= 0
    AND (personnel_cost + storage_costs + selling_costs) >= 0.25 * sales
GROUP BY order_size

