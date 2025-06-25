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

---Using Common Table Expressions
WITH costs_and_quantities AS (  
 SELECT  
   meals.meal_id,  
   SUM(stocked_quantity) AS quantity,  
   SUM(meal_cost * stocked_quantity) AS cost  
 FROM meals  
 JOIN stock ON meals.meal_id = stock.meal_id  
 GROUP BY meals.meal_id 
)   
SELECT   
 meal_id,  
 quantity,  
 cost  
FROM costs_and_quantities  
ORDER BY cost DESC  
LIMIT 3;

--- Bringing Revenue and Cost Together -> and Calculating Profit
WITH
	REVENUE AS (
		SELECT
			MEALS.MEAL_ID,
			SUM(MEAL_PRICE * ORDER_QUANTITY) AS REVENUE
		FROM
			MEALS
			JOIN ORDERS ON MEALS.MEAL_ID = ORDERS.MEAL_ID
		GROUP BY
			MEALS.MEAL_ID
	),
	COST AS (
		SELECT
			MEALS.MEAL_ID,
			SUM(MEAL_COST * STOCKED_QUANTITY) AS COST
		FROM
			MEALS
			JOIN STOCK ON MEALS.MEAL_ID = STOCK.MEAL_ID
		GROUP BY
			MEALS.MEAL_ID
	)
SELECT
	REVENUE.MEAL_ID,
	REVENUE,
	COST,
	REVENUE - COST AS PROFIT
FROM
	REVENUE
	JOIN COST ON REVENUE.MEAL_ID = COST.MEAL_ID
ORDER BY
	PROFIT DESC
LIMIT
	3;



SELECT 
  user_id, 
  MIN(order_date) AS reg_date 
FROM orders 
GROUP BY user_id 
ORDER BY user_id 
LIMIT 3;

WITH reg_dates AS ( 
  SELECT 
    user_id, 
    MIN(order_date) AS reg_date 
  FROM orders 
  GROUP BY user_id) 
SELECT 
  DATE_TRUNC('month', reg_date) :: DATE AS foodr_month, 
  COUNT(DISTINCT user_id) AS regs 
FROM reg_dates 
GROUP BY foodr_month 
ORDER BY foodr_month ASC 
LIMIT 3;


SELECT 
  DATE_TRUNC('month', order_date) :: DATE AS foodr_month, 
  COUNT(DISTINCT user_id) AS mau 
FROM orders 
GROUP BY foodr_month 
ORDER BY foodr_month ASC 
LIMIT 3;



WITH reg_dates AS ( 
  SELECT 
    user_id, 
    MIN(order_date) AS reg_date 
  FROM orders 
  GROUP BY user_id),  
  registrations AS ( 
  SELECT 
    DATE_TRUNC('month', reg_date) :: DATE AS foodr_month, 
    COUNT(DISTINCT user_id) AS regs 
  FROM reg_dates 
  GROUP BY foodr_month)  
SELECT 
  foodr_month, 
  regs, 
  SUM(regs) OVER (ORDER BY foodr_month ASC) AS regs_rt 
FROM registrations 
ORDER BY foodr_month ASC 
LIMIT 3;




