/*Product-level profitability analysis that aggregates gross profit, 
revenue, average discount, total quantity, profit margin, profit-to-cost ratio, 
and profit share across products, ranked by gross profit for the top 20 products.*/

SELECT 
dp.product_name,
dp.category,
sum(t.profit)AS gross_profit,
sum (t.sales ) AS revenue,
round(avg (t.discount ),2) AS avg_discount,
sum(t.quantity ) AS total_quantity,
round(100*(sum(t.profit)/sum (t.sales*(1 - t.discount))),2) AS Profit_Margin_precent,
round(100*(sum(t.profit)/sum(t.shipping_costs + t.storage_costs + t.personnel_cost + t.selling_costs + t.purchasing_costs)),2) AS Profit_to_cost_percent,
round(100.0 * SUM(t.profit) / SUM(SUM(t.profit)) OVER (), 2) AS profit_share
FROM fact_sales t 
LEFT JOIN dim_product dp ON t.product_id =dp.product_id 
GROUP BY dp.product_name,
dp.category
ORDER BY gross_profit DESC
LIMIT 20