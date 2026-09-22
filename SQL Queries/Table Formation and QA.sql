-- Part 1: Table constructiona and data inspection

--=============================
-- Create Table
--=============================
CREATE TABLE bookings (
    booking_date DATE,
    booking_time TIME,
    booking_id VARCHAR(50) PRIMARY KEY,
    booking_status VARCHAR(50),
    customer_id VARCHAR(50),
    vehicle_type VARCHAR(50),
    pickup_location VARCHAR(100),
    drop_location VARCHAR(100),
    v_tat NUMERIC(10,2),
    c_tat NUMERIC(10,2),
    canceled_rides_by_customer VARCHAR(100),
    canceled_rides_by_driver VARCHAR(100),
    incomplete_rides VARCHAR(20),
    incomplete_rides_reason VARCHAR(100),
    booking_value INTEGER,
    payment_method VARCHAR(50),
    ride_distance INTEGER,
    driver_ratings NUMERIC(3,1),
    customer_rating NUMERIC(3,1)
);

--============================
-- Inspecting the data
--============================
SELECT * FROM bookings
LIMIT 5;

--===========================
-- Finding total no of records
--===========================
SELECT COUNT(*) total_records
FROM bookings; -- 103024 records

--============================
-- Total no of unique customers and booking_ids
--============================
SELECT COUNT(DISTINCT customer_id) AS total_cust, COUNT(DISTINCT booking_id) AS total_bookings
FROM bookings; -- 94544 customers, 103024 bookings

--============================
-- Total no of vehicle type, pickup and drop off locations
--============================
SELECT COUNT(DISTINCT vehicle_type) AS vehicle_kind,
	   COUNT(DISTINCT pickup_location) AS no_pickup_loc,
	   COUNT(DISTINCT drop_location) AS no_drop_loc
	   FROM bookings;


-- Part 2: Data Integrity Check

--=================================
-- Any successful booking with no info on payment method?
--=================================
SELECT customer_id, booking_id, pickup_location, drop_location
FROM bookings
WHERE booking_status = 'success'
AND payment_method IS NULL; -- zero records

--=================================
-- Any successful booking with no driver ratings?
--=================================
SELECT COUNT(booking_id)
FROM bookings
WHERE booking_status = 'success'
AND driver_ratings IS NULL; -- zero records

--=================================
-- Any successful booking with no customer rating?
--=================================
SELECT COUNT(booking_id)
FROM bookings
WHERE booking_status = 'success'
AND customer_rating IS NULL; -- zero records

--=================================
-- Unsccessful booking where V_TAT or C_TAT is not null?
--=================================
SELECT COUNT(booking_id)
FROM bookings
WHERE booking_status != 'Success'
AND (v_tat IS NOT NULL OR c_tat IS NOT NULL); -- zero cases

--=================================
Trip is incomplete but no reasons exist
--=================================
SELECT COUNT(booking_id)
FROM bookings
WHERE incomplete_rides = 'Yes'
AND incomplete_rides_reason IS NULL; -- zero cases

--=================================
Trip is not incomplete but reason for not completing exists
--=================================
SELECT COUNT(booking_id)
FROM bookings
WHERE incomplete_rides = 'No'
AND incomplete_rides_reason IS NOT NULL;

