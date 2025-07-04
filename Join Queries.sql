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




















