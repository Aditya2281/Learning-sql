select * from orders
select * from meals
select * from stock

---Calculating Revenue
SELECT
	ORDER_ID,
	SUM(MEAL_PRICE * ORDER_QUANTITY) AS REVENUE
FROM
	MEALS
	JOIN ORDERS ON MEALS.MEAL_ID = ORDERS.MEAL_ID
GROUP BY
	ORDER_ID

---Calculating Cost 
SELECT  
  meal_id,   
  SUM(meal_cost * stocked_quantity) AS total_cost   
FROM meals  
JOIN stock  using (meal_id)
GROUP BY meal_id  
ORDER BY total_cost DESC  
LIMIT 3;

---
