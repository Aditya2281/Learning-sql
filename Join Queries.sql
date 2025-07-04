--Calculating Revenue 
SELECT  
  order_id,  
  SUM(meal_price * order_quantity) AS revenue  
FROM meals  
JOIN orders ON meals.meal_id = orders.meal_id  
GROUP BY order_id;

--Calculating Cost 
SELECT  
  meals.meal_id,   
  SUM(meal_cost * stocked_quantity) AS cost   
FROM meals  
JOIN stock ON meals.meal_id = stock.meal_id  
GROUP BY meals.meal_id  
ORDER BY meals.cost DESC  
LIMIT 3;

--Bringing Revenue and Cost Together -> and Calculating Profit
WITH revenue AS (  
  SELECT  
    meals.meal_id,  
    SUM(meal_price * order_quantity) AS revenue  
  FROM meals  
  JOIN orders ON meals.meal_id = orders.meal_id  
  GROUP BY meals.meal_id 
),   
cost AS (  
  SELECT  
    meals.meal_id,  
    SUM(meal_cost * stocked_quantity) AS cost  
  FROM meals  
  JOIN stock ON meals.meal_id = stock.meal_id  
  GROUP BY meals.meal_id 
)
SELECT  
  revenue.meal_id,  
  revenue,  
  cost,  
  revenue - cost AS profit  
FROM revenue  
JOIN cost ON revenue.meal_id = cost.meal_id  
ORDER BY profit DESC  
LIMIT 3; 


---Lagged MAU - query
WITH maus AS ( 
  SELECT 
    DATE_TRUNC('month', order_date) :: DATE AS foodr_month, 
    COUNT(DISTINCT user_id) AS mau 
  FROM orders 
  GROUP BY foodr_month)  
 SELECT 
  foodr_month, 
  mau, 
  COALESCE( 
    LAG(mau) OVER (ORDER BY foodr_month ASC), 
  1) AS last_mau 
FROM maus 
ORDER BY foodr_month ASC 
LIMIT 3;

---Deltas - query
WITH maus AS ( 
  SELECT 
    DATE_TRUNC('month', order_date) :: DATE AS foodr_month, 
    COUNT(DISTINCT user_id) AS mau 
  FROM orders 
  GROUP BY foodr_month),  
  maus_lag AS ( 
  SELECT 
    foodr_month, 
    mau, 
    COALESCE( 
      LAG(mau) OVER (ORDER BY foodr_month ASC), 
    1) AS last_mau 
  FROM maus) 
SELECT 
  foodr_month, 
  mau, 
  mau - last_mau AS mau_delta 
FROM maus_lag 
ORDER BY foodr_month 
LIMIT 3;


---Growth rate - query
WITH maus AS ( 
  SELECT 
    DATE_TRUNC('month', order_date) :: DATE AS foodr_month, 
    COUNT(DISTINCT user_id) AS mau 
  FROM orders 
  GROUP BY foodr_month),  
  maus_lag AS ( 
  SELECT 
    foodr_month, 
    mau, 
    COALESCE( 
      LAG(mau) OVER (ORDER BY foodr_month ASC), 
    1) AS last_mau 
  FROM maus) 
 SELECT 
  foodr_month, 
  mau, 
  ROUND( 
    (mau - last_mau) :: NUMERIC / last_mau, 
  2) AS growth 
FROM maus_lag 
ORDER BY foodr_month 
LIMIT 3;



---Retention rate - query
WITH user_activity AS ( 
  SELECT DISTINCT 
    DATE_TRUNC('month', order_date) :: DATE AS foodr_month, 
    user_id 
  FROM orders)  
SELECT 
  previous.foodr_month, 
  ROUND( 
    COUNT(DISTINCT current.user_id) :: NUMERIC / 
    GREATEST(COUNT(DISTINCT previous.user_id), 1), 
  2) AS retention  
FROM user_activity AS previous 
LEFT JOIN user_activity AS current 
ON previous.user_id = current.user_id 
AND previous.foodr_month = (current.foodr_month - INTERVAL '1 month') 
GROUP BY previous.foodr_month 
ORDER BY previous.foodr_month ASC 
;




















