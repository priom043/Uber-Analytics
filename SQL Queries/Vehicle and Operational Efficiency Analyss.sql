-- Part 6: Proportion of Succesful and Unsuccessful Bookings
 
-- ================================
-- Successful Bookings and its proportion
-- ================================
SELECT COUNT(DISTINCT
CASE
WHEN booking_status = 'Success' THEN booking_id
END) AS no_success,
COUNT(DISTINCT booking_id) AS total,
ROUND(COUNT(DISTINCT
CASE
WHEN booking_status = 'Success' THEN booking_id
END)::NUMERIC
/COUNT(DISTINCT booking_id),2) as prop
FROM bookings; -- 63967 success, 103024 total, 62% successful

-- =================================
-- Unsuccessful Bookings and its proportion
-- =================================
SELECT COUNT(DISTINCT
CASE
WHEN booking_status != 'Success' THEN booking_id
END) AS no_unsuccess,
COUNT(DISTINCT booking_id) AS total,
ROUND(COUNT(DISTINCT
CASE
WHEN booking_status != 'Success' THEN booking_id
END)::NUMERIC
/COUNT(DISTINCT booking_id),2) as prop
FROM bookings; -- 39057 success, 103024 total, 38% unsuccessful

--===================================
-- proportion of incomplete trip when labeled as successful
--===================================
SELECT COUNT(DISTINCT
CASE
WHEN incomplete_rides = 'Yes' THEN booking_id
END) AS n_incomp,
COUNT(DISTINCT
CASE
WHEN booking_status = 'Success' THEN booking_id
END) as n_success,
ROUND(
COUNT(DISTINCT
CASE
WHEN incomplete_rides = 'Yes' THEN booking_id
END)::NUMERIC/
COUNT(DISTINCT
CASE
WHEN booking_status = 'Success' THEN booking_id
END)
,2)
FROM bookings; -- 3926 incomplete rides, 63967 lablled as successful, proportion 6%


-- Part 7: V_TAT (driver turnaround time), C_TAT (customer turnaround time) and Ratings analysis

-- ==============================
-- Min, Max and Average V_TAT and C_TAT for successful rides
-- ==============================
SELECT MIN(v_tat), MAX(v_tat), ROUND(AVG(v_tat), 2), -- 35s, 308s, 170.88s
	MIN(c_tat),  MAX(c_tat), ROUND(AVG(c_tat), 2) -- 25s, 145s, 84.87s
	FROM bookings
	WHERE booking_status = 'Success';

-- ==============================
-- Min, Max and Average V_TAT and C_TAT for incomplete rides
-- ==============================
SELECT MIN(v_tat), MAX(v_tat), ROUND(AVG(v_tat), 2), -- 35s, 308s, 172.69s
	MIN(c_tat),  MAX(c_tat), ROUND(AVG(c_tat), 2) -- 25s, 145s, 84.72s
	FROM bookings
	WHERE incomplete_rides = 'Yes';

-- ===============================
-- Min, Max and Average Driver and Customer Rating
-- ===============================
SELECT MIN(driver_ratings), MAX(driver_ratings), ROUND(AVG(driver_ratings),2), -- min 3, max 5, average 4 
MIN(customer_rating), MAX(customer_rating), ROUND(AVG(customer_rating),2) -- min 3, max 5, average 4
FROM bookings;


-- Part 8: Vehicle Analysis

-- ===============================
-- Ranking vehicles based on successful trips
-- ===============================
SELECT
    vehicle_type,
    COUNT(DISTINCT booking_id) AS successful_trips,
    RANK() OVER (
        ORDER BY COUNT(DISTINCT booking_id) DESC
    ) AS trip_rank
FROM bookings
WHERE booking_status = 'Success'
  AND incomplete_rides = 'No'
GROUP BY vehicle_type
ORDER BY trip_rank;

-- Vehicle type -> Successful Trips -> Rank
-- "Prime Sedan" -> 8768 -> 1
-- "eBike" -> 8606 -> 2
-- "Auto" -> 8605 -> 3
-- "Bike" -> 8555 -> 4
-- "Prime Plus" -> 8539 -> 5
-- "Mini" -> 8519 -> 6
-- "Prime SUV" -> 8449 -> 7

-- ===============================
Ranking vehicles based on customer cancellation cases
-- ===============================
SELECT vehicle_type,
COUNT(DISTINCT booking_id) AS cust_cancel_count,
RANK() OVER (ORDER BY COUNT(DISTINCT booking_id) DESC) AS cancel_rank
FROM bookings
WHERE canceled_rides_by_customer IS NOT NULL
GROUP BY vehicle_type
ORDER BY cancel_rank;

-- "Bike" -> 1537 -> 1
-- "eBike" -> 1512 -> 2
-- "Mini" -> 1505 -> 3
-- "Auto" -> 1503 -> 4
-- "Prime SUV" -> 1498 -> 5
-- "Prime Plus" -> 1474 -> 6
-- "Prime Sedan" -> 1470 -> 7

-- ============================
-- Ranking vehicles based on average V_TAT
-- ============================
SELECT
    vehicle_type,
    ROUND(AVG(v_tat), 2) AS avg_driver_tat,
    RANK() OVER (ORDER BY AVG(v_tat)) AS tat_rank
FROM bookings
WHERE booking_status = 'Success'
GROUP BY vehicle_type
ORDER BY tat_rank;

-- vehicle -> avg_V_TAT -> Rank
-- "Prime SUV" -> 168.83 -> 1
-- "eBike" -> 170.07 -> 2
-- "Prime Sedan" -> 170.64 -> 3
-- "Bike" -> 171.07 -> 4
-- "Prime Plus" -> 171.21 -> 5
-- "Auto" -> 171.70 -> 6
-- "Mini" -> 172.62 -> 7

-- ============================
-- Ranking vehicles based on average C_TAT
-- ============================
SELECT
    vehicle_type,
    ROUND(AVG(c_tat), 2) AS avg_customer_tat,
    RANK() OVER (ORDER BY AVG(c_tat)) AS tat_rank
FROM bookings
WHERE booking_status = 'Success'
GROUP BY vehicle_type
ORDER BY tat_rank;

-- "Prime SUV" -> 84.05 -> 1
-- "Mini" -> 84.45 -> 2
-- "Prime Plus" -> 84.75 -> 3
-- "eBike" -> 84.98 -> 4
-- "Bike" -> 85.12 -> 5
-- "Auto" -> 85.34 -> 6
-- "Prime Sedan" -> 85.40 -> 7


-- Part 9: Measuring Distances

-- ================================
-- Average distance for successfully completed rides
-- ================================
SELECT MIN(ride_distance), MAX(ride_distance), ROUND(AVG(ride_distance),2)
FROM bookings
WHERE booking_status = 'Success' AND incomplete_rides = 'No'; -- Min 1km, Max 49km, Avg 22.82km