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



---- ARPU (Average Revenue Per User)

--Query I:
WITH kpis AS ( 
  SELECT 
    SUM(meal_price * order_quantity) AS revenue, 
    COUNT(DISTINCT user_id) AS users 
  FROM meals 
  JOIN orders ON meals.meal_id = orders.meal_id
) 
SELECT 
  ROUND(revenue :: NUMERIC / GREATEST(users, 1), 2) AS arpu 
FROM kpis;

--Query I (by month):
WITH kpis AS (
  SELECT 
    DATE_TRUNC('month', order_date) AS delivr_month,
    SUM(meal_price * order_quantity) AS revenue,
    COUNT(DISTINCT user_id) AS users
  FROM meals m
  JOIN orders o ON m.meal_id = o.meal_id
  GROUP BY delivr_month
)
SELECT 
  delivr_month,
  ROUND(
    revenue :: NUMERIC / GREATEST(users, 1),
  2) AS arpu
FROM kpis
ORDER BY delivr_month ASC;


---Query II (per user then average):
WITH user_revenues AS ( 
  SELECT 
    user_id, 
    SUM(meal_price * order_quantity) AS revenue 
  FROM meals 
  JOIN orders ON meals.meal_id = orders.meal_id 
  GROUP BY user_id
) 
SELECT 
  ROUND(AVG(revenue) :: NUMERIC, 2) AS arpu 
FROM user_revenues;


----Orders per user:
WITH user_orders AS ( 
  SELECT 
    user_id, 
    COUNT(DISTINCT order_id) AS orders 
  FROM meals 
  JOIN orders ON meals.meal_id = orders.meal_id 
  GROUP BY user_id
)  
SELECT 
  orders, 
  COUNT(DISTINCT user_id) AS users 
FROM user_orders 
GROUP BY orders 
ORDER BY orders ASC;


----Revenues rounded to 100s:
WITH user_revenues AS ( 
  SELECT 
    user_id, 
    SUM(meal_price * order_quantity) AS revenue 
  FROM meals 
  JOIN orders ON meals.meal_id = orders.meal_id 
  GROUP BY user_id
)  
SELECT 
  ROUND(revenue :: NUMERIC, -2) AS revenue_100, 
  COUNT(DISTINCT user_id) AS users 
FROM user_revenues 
GROUP BY revenue_100 
ORDER BY revenue_100 ASC;




--------Bucketing
---Top 5 order counts:
WITH user_orders AS ( 
  SELECT 
    user_id, 
    COUNT(DISTINCT order_id) AS orders 
  FROM meals 
  JOIN orders ON meals.meal_id = orders.meal_id 
  GROUP BY user_id
) 
SELECT 
  orders, 
  COUNT(DISTINCT user_id) AS users 
FROM user_orders 
GROUP BY orders 
ORDER BY orders ASC 
LIMIT 5;


---Meal price bucketing using CASE:
SELECT 
  CASE 
    WHEN meal_price < 4 THEN 'Low-price meal' 
    WHEN meal_price < 6 THEN 'Mid-price meal' 
    ELSE 'High-price meal' 
  END AS price_category, 
  COUNT(DISTINCT meal_id) 
FROM meals 
GROUP BY price_category;



----Revenue bucketing using CASE:
WITH user_revenues AS ( 
  SELECT 
    user_id, 
    SUM(meal_price * order_quantity) AS revenue 
  FROM meals 
  JOIN orders ON meals.meal_id = orders.meal_id 
  GROUP BY user_id
)  
SELECT 
  CASE 
    WHEN revenue < 150 THEN 'Low-revenue users' 
    WHEN revenue < 300 THEN 'Mid-revenue users' 
    ELSE 'High-revenue users' 
  END AS revenue_group, 
  COUNT(DISTINCT user_id) AS users 
FROM user_revenues 
GROUP BY revenue_group;
















