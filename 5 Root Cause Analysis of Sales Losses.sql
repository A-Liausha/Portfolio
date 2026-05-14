/* Root cause analysis of unprofitable orders that categorizes loss drivers into 
High Discount, High Purchasing Costs, High Cost Delivery, High Overheads, and Small Order, 
then calculates lost orders, total losses, average discount, and loss share per cause.*/

WITH Loss_Causes AS (
SELECT 
t.product_id, 
t.profit,
t.personnel_cost,
t.purchasing_costs,
t.quantity,
t.sales,
t.selling_costs,
t.shipping_costs,
t.storage_costs,
t.discount, 
CASE 
	WHEN t.discount >= 0.3 THEN 'High Discount'
	WHEN t.purchasing_costs>=t.sales THEN 'High Purchasing Costs'
	WHEN t.shipping_costs>=0.15*t.sales THEN 'High Cost Delivery'
	WHEN t.personnel_cost+t.storage_costs+t.selling_costs>=0.25*t.sales THEN 'High Overheads'
	WHEN t.quantity=1 AND t.sales <= 50 THEN 'Small Order'
		ELSE 'Other'
END AS Loss_reasons
FROM fact_sales t 
WHERE t.profit <=0)
SELECT
l.Loss_reasons,
count(l.product_id) AS lost_orders,
round(sum(-l.profit),2) AS total_losses,
round(avg(l.discount ),2) AS avg_discount,
ROUND(100.0 * COUNT(l.product_id) / (SELECT (COUNT(product_id)) FROM fact_sales t ), 2) AS percent_per_whole,
ROUND(100.0 * sum(-l.profit) / sum(sum(-l.profit)) over(), 2) AS loss_amount_share
FROM Loss_Causes l
GROUP BY l.Loss_reasons
ORDER BY total_losses DESC;


