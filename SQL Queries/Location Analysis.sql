-- =================================
-- pickup location analysis
-- =================================
WITH overall_metrics AS (

    SELECT

        100.0 *
        COUNT(DISTINCT booking_id)
        FILTER (WHERE booking_status <> 'Success')
        / COUNT(DISTINCT booking_id)
        AS overall_unsuccessful_rate,

        100.0 *
        COUNT(DISTINCT booking_id)
        FILTER (WHERE booking_status = 'Driver Not Found')
        / COUNT(DISTINCT booking_id)
        AS overall_driver_not_found_rate

    FROM bookings
),

location_metrics AS (

    SELECT
        pickup_location,

        COUNT(DISTINCT booking_id) AS total_bookings,

        COUNT(DISTINCT booking_id)
            FILTER (WHERE booking_status <> 'Success')
            AS unsuccessful_bookings,

        COUNT(DISTINCT booking_id)
            FILTER (WHERE booking_status = 'Driver Not Found')
            AS driver_not_found,

        COUNT(DISTINCT booking_id)
            FILTER (WHERE booking_status = 'Canceled by Customer')
            AS customer_cancellations,

        COUNT(DISTINCT booking_id)
            FILTER (WHERE booking_status = 'Canceled by Driver')
            AS driver_cancellations

    FROM bookings

    GROUP BY pickup_location
)

SELECT
    lm.pickup_location,
    lm.total_bookings,
    lm.unsuccessful_bookings,

    ROUND(
        100.0 * lm.unsuccessful_bookings
        / lm.total_bookings,
        2
    ) AS unsuccessful_rate,

    ROUND(
        100.0 * lm.driver_not_found
        / lm.total_bookings,
        2
    ) AS driver_not_found_rate,

    ROUND(
        100.0 * lm.customer_cancellations
        / lm.total_bookings,
        2
    ) AS customer_cancellation_rate,

    ROUND(
        100.0 * lm.driver_cancellations
        / lm.total_bookings,
        2
    ) AS driver_cancellation_rate,

    ROUND(
        lm.total_bookings *
        lm.unsuccessful_bookings::numeric
        / lm.total_bookings,
        0
    ) AS estimated_unsuccessful_requests

FROM location_metrics lm

CROSS JOIN overall_metrics om

WHERE lm.total_bookings >= 500

  AND (
        100.0 * lm.unsuccessful_bookings
        / lm.total_bookings
      ) > om.overall_unsuccessful_rate

  AND (
        100.0 * lm.driver_not_found
        / lm.total_bookings
      ) > om.overall_driver_not_found_rate

ORDER BY estimated_unsuccessful_requests DESC;


-- =================================
-- Drop location classification
-- =================================
WITH location_stats AS (
    SELECT
        drop_location,
        COUNT(DISTINCT booking_id) AS booking_count
    FROM bookings
    GROUP BY drop_location
),

percentiles AS (
    SELECT
        PERCENTILE_CONT(0.25)
            WITHIN GROUP (ORDER BY booking_count) AS p25,
        PERCENTILE_CONT(0.75)
            WITHIN GROUP (ORDER BY booking_count) AS p75
    FROM location_stats
)

SELECT
    l.drop_location,
    l.booking_count,
    CASE
        WHEN l.booking_count < p.p25 THEN 'Low'
        WHEN l.booking_count <= p.p75 THEN 'Normal'
        ELSE 'High'
    END AS location_category
FROM location_stats l
CROSS JOIN percentiles p
ORDER BY l.booking_count DESC;