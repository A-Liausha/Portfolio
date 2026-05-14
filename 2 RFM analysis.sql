/* RFM (Recency, Frequency, Monetary) customer segmentation classifies customers into categories
 such as Champions, Loyal, At Risk, and Lost, 
then calculates key metrics including customer count, average spend, total revenue, and revenue contribution per segment.*/

WITH rfm_metrics AS (
	SELECT
		customer_id,
		COUNT(DISTINCT order_id) AS frequency,
		SUM(sales) AS monetary_value,
		CURRENT_DATE - MAX(order_date) AS recency
	FROM
		fact_sales
	GROUP BY
		customer_id
),
rfm_scores AS (
	SELECT
		customer_id,
		NTILE(5) OVER (
		ORDER BY
			recency DESC
		) AS recency_score,
		NTILE(5) OVER (
		ORDER BY
			frequency
		) AS frequency_score,
		NTILE(5) OVER (
		ORDER BY
			monetary_value
		) AS monetary_score,
		frequency,
		monetary_value,
		recency
	FROM
		rfm_metrics
),
segment AS (
	SELECT
		customer_id,
		CASE
			WHEN recency_score = 5
			AND frequency_score >= 4
			AND monetary_score >= 4 THEN 'Champions'
			WHEN recency_score >= 4
			AND frequency_score >= 3
			AND monetary_score >= 3 THEN 'Loyal'
			WHEN recency_score <= 2
			AND frequency_score >= 4
			AND monetary_score >= 4 THEN 'Cannot Lose'
			WHEN recency_score <= 2
			AND frequency_score >= 3
			AND monetary_score >= 3 THEN 'At Risk'
			WHEN recency_score >= 4
			AND frequency_score <= 2
			AND monetary_score >= 2 THEN 'Promising'
			WHEN recency_score = 5
			AND frequency_score = 1
			AND monetary_score = 1 THEN 'New Customers'
			ELSE 'Lost'
		END AS segment_name,
		frequency,
		monetary_value,
		recency
	FROM
		rfm_scores
) 
SELECT
	segment_name,
	COUNT(DISTINCT customer_id) AS customers_number,
	ROUND(100 * COUNT(DISTINCT customer_id)/ sum(COUNT(DISTINCT customer_id)) OVER(), 2) AS customer_percent,
	ROUND(AVG(monetary_value), 2) AS avg_spent,
	SUM(monetary_value) AS total_revenue,
	ROUND(100.0 * SUM(monetary_value) / SUM(SUM(monetary_value)) OVER (), 2) AS revenue_percent,
	ROUND((SUM(monetary_value)/ COUNT(DISTINCT customer_id)), 2) AS revenue_per_customer
FROM
	segment
GROUP BY
	segment_name
ORDER BY
	revenue_percent DESC;
