-- Part 3: Customer Cancellation

--================================
-- Total no of customer cancellation
--================================
SELECT COUNT(canceled_rides_by_customer)
FROM bookings
WHERE canceled_rides_by_customer IS NOT NULL; -- 10499 cases

--================================
-- Reasons for customer cancelling and their count
--================================
SELECT canceled_rides_by_customer, COUNT(canceled_rides_by_customer) AS num_cust_cancel
FROM bookings
WHERE booking_status != 'Success'
AND canceled_rides_by_customer IS NOT NULL 
GROUP By canceled_rides_by_customer
ORDER BY num_cust_cancel DESC;

-- "Driver is not moving towards pickup location" -> 3175
-- "Driver asked to cancel" -> 2670
-- "Change of plans" -> 2081
-- "AC is Not working" -> 1568
-- "Wrong Address" -> 1005

--================================
-- Customer cancellation cases ranked by vehicle type
--================================
SELECT vehicle_type, COUNT(vehicle_type) as freq
FROM bookings
WHERE booking_status = 'Canceled by Customer'
GROUP BY vehicle_type
ORDER BY freq DESC;

-- "Bike" -> 1537
-- "eBike" -> 1512
-- "Mini" -> 1505
-- "Auto" -> 1503
-- "Prime SUV" -> 1498
-- "Prime Plus" -> 1474
-- "Prime Sedan" -> 1470


-- Part 4: Driver Cancellation Analysis

--================================
-- Total no of driver cancellation
--================================
SELECT COUNT(canceled_rides_by_driver)
FROM bookings
WHERE canceled_rides_by_driver IS NOT NULL; -- 18434 cases

--================================
-- Reasons for driver cancellation and their count
--================================
SELECT canceled_rides_by_driver, COUNT(canceled_rides_by_driver) as num_driver_cancel
FROM bookings
WHERE canceled_rides_by_driver IS NOT NULL
GROUP BY canceled_rides_by_driver
ORDER BY num_driver_cancel DESC;

-- "Personal & Car related issue" -> 6542
-- "Customer related issue" -> 5413
-- "Customer was coughing/sick" -> 3654
-- "More than permitted people in there" -> 2825

--================================
-- Top 10 pickup spot that led to most driver cancellation
--================================
SELECT pickup_location, COUNT(pickup_location) as freq
FROM bookings
WHERE booking_status = 'Canceled by Driver'
GROUP BY pickup_location
ORDER BY freq DESC
LIMIT 10;

-- "Tumkur Road" -> 424
-- "Whitefield" -> 418
-- "Sarjapur Road" -> 415
-- "Langford Town" -> 411
-- "Kengeri" -> 402
-- "BTM Layout" -> 400
-- "Banashankari" -> 396
-- "Vijayanagar" -> 396
-- "JP Nagar" -> 394
-- "Yelahanka" -> 393

--================================
-- Top 10 drop off location that led to most driver cancellation
--================================
SELECT drop_location, COUNT(drop_location) as freq
FROM bookings
WHERE booking_status = 'Canceled by Driver'
GROUP BY drop_location
ORDER BY freq DESC
LIMIT 10;

-- "Marathahalli" -> 416
-- "RT Nagar" -> 408
-- "Koramangala" -> 407
-- "Langford Town" -> 396
-- "Sarjapur Road" -> 391
-- "HSR Layout" -> 388
-- "Bellandur" -> 382
-- "Indiranagar" -> 381
-- "Tumkur Road" -> 380
-- "Basavanagudi" -> 380


-- Part 5: Driver Unavailability Analysis

--=================================
Total count of driver unavailability case
--=================================
SELECT COUNT(booking_id)
FROM bookings
WHERE booking_status = 'Driver Not Found'; -- 10124 cases

--=================================
-- Top 10 pickup spot that led to most driver unavailbility
--=================================
SELECT pickup_location, COUNT(pickup_location) as freq
FROM bookings
WHERE booking_status = 'Driver Not Found'
GROUP BY pickup_location
ORDER BY freq DESC
LIMIT 10;

-- "Hennur" -> 228
-- "Marathahalli" -> 225
-- "Mysore Road" -> 220
-- "Peenya" -> 220
-- "Hosur Road" -> 219
-- "Cox Town" -> 218
-- "Sahakar Nagar" -> 218
-- "Kengeri" -> 217
-- "Nagarbhavi" -> 215
-- "Kammanahalli" -> 215

--================================
-- Top 10 drop off location that led to most driver unavailability
--================================
SELECT drop_location, COUNT(drop_location) as freq
FROM bookings
WHERE booking_status = 'Driver Not Found'
GROUP BY drop_location
ORDER BY freq DESC
LIMIT 10;

-- "MG Road" -> 232
-- "Hennur" -> 227
-- "Hulimavu" -> 225
-- "Malleshwaram" -> 222
-- "Vijayanagar" -> 221
-- "Hosur Road" -> 219
-- "Koramangala" -> 218
-- "Peenya" -> 215
-- "HSR Layout" -> 212
-- "Mysore Road" -> 208