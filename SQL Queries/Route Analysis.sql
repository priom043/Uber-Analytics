-- ================================
-- Overall performance
-- ================================
SELECT
    pickup_location,
    drop_location,

    COUNT(DISTINCT booking_id) AS total_bookings,

    COUNT(DISTINCT booking_id)
        FILTER (WHERE booking_status = 'Success')
        AS successful_rides,

    COUNT(DISTINCT booking_id)
        FILTER (WHERE booking_status <> 'Success')
        AS unsuccessful_bookings,

    ROUND(
        100.0 *
        COUNT(DISTINCT booking_id)
        FILTER (WHERE booking_status = 'Success')
        / COUNT(DISTINCT booking_id),
        2
    ) AS success_rate,

    ROUND(AVG(ride_distance), 2) AS avg_ride_distance,

    ROUND(AVG(booking_value), 2) AS avg_booking_value

FROM bookings

GROUP BY
    pickup_location,
    drop_location

ORDER BY total_bookings DESC;

-- ===============================
-- Top 10 requested
-- ===============================
SELECT
    pickup_location,
    drop_location,
    COUNT(DISTINCT booking_id) AS total_bookings

FROM bookings

GROUP BY
    pickup_location,
    drop_location

ORDER BY total_bookings DESC

LIMIT 10;

-- =================================
-- Problematic Routes
-- =================================
SELECT
    pickup_location,
    drop_location,

    COUNT(*) AS total_bookings,

    COUNT(*) FILTER (
        WHERE booking_status <> 'Success'
    ) AS unsuccessful_bookings,

    ROUND(
        100.0 *
        COUNT(*) FILTER (
            WHERE booking_status <> 'Success'
        ) / COUNT(*),
        2
    ) AS unsuccessful_rate,

    ROUND(AVG(booking_value), 2) AS avg_booking_value

FROM bookings

GROUP BY
    pickup_location,
    drop_location

HAVING COUNT(*) >= 50

ORDER BY unsuccessful_rate DESC;