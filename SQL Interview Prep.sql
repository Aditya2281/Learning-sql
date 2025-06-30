---Find the last time each bike was in use. 
---Output both the bike number and the date-timestamp of the bike's last use 
---(i.e., the date-time the bike was returned). Order the results by bikes that were most recently used.

select bike_number, max (end_time) as last_time 
  from dc_bikeshare_q1_2012
group by bike_number 
order by last_time desc

---Write a query that returns the number of unique users per client for each month. 
---Assume all events occur within the same year, so only month needs to be be in the output as a number from 1 to 12.

SELECT 
    client_id,
    EXTRACT(MONTH FROM time_id) AS month,
    COUNT(DISTINCT user_id) AS unique_users
FROM 
    fact_events
GROUP BY 
    client_id, 
    EXTRACT(MONTH FROM time_id)
ORDER BY 
    client_id, 
    month;
