-- ===================================
-- Identifying customer request frequency
-- ===================================

WITH customer_metrics AS (

    SELECT
        customer_id,

        COUNT(DISTINCT booking_id) AS total_bookings,

        COUNT(DISTINCT booking_id)
            FILTER (WHERE booking_status = 'Success')
            AS successful_rides,

        COUNT(DISTINCT booking_id)
            FILTER (WHERE booking_status = 'Canceled by Customer')
            AS customer_cancellations,

        COUNT(DISTINCT booking_id)
            FILTER (WHERE booking_status = 'Canceled by Driver')
            AS driver_cancellations,

        COUNT(DISTINCT booking_id)
            FILTER (WHERE booking_status = 'Driver Not Found')
            AS driver_not_found,

        AVG(booking_value) AS avg_booking_value,

        AVG(ride_distance) AS avg_ride_distance,

        AVG(customer_rating) AS avg_customer_rating

    FROM bookings

    GROUP BY customer_id
),

customer_segments AS (

    SELECT
        *,

        CASE
            WHEN total_bookings = 1
                THEN '1 booking'

            WHEN total_bookings BETWEEN 2 AND 3
                THEN '2-3 bookings'

            WHEN total_bookings BETWEEN 4 AND 5
                THEN '4-5 bookings'

            ELSE '6+ bookings'

        END AS booking_frequency_group

    FROM customer_metrics
)

SELECT
    booking_frequency_group,

    COUNT(*) AS number_of_customers,

    ROUND(
        AVG(total_bookings),
        2
    ) AS avg_bookings_per_customer,

    ROUND(
        100.0 * SUM(successful_rides)
        / SUM(total_bookings),
        2
    ) AS success_rate,

    ROUND(
        100.0 * SUM(customer_cancellations)
        / SUM(total_bookings),
        2
    ) AS customer_cancellation_rate,

    ROUND(
        AVG(avg_booking_value),
        2
    ) AS avg_booking_value,

    ROUND(
        AVG(avg_customer_rating),
        2
    ) AS avg_customer_rating

FROM customer_segments

GROUP BY booking_frequency_group

ORDER BY
    CASE booking_frequency_group
        WHEN '1 booking' THEN 1
        WHEN '2-3 bookings' THEN 2
        WHEN '4-5 bookings' THEN 3
        WHEN '6+ bookings' THEN 4
    END;

-- group -> no cust -> avg_booking_per_cust -> success rate -> cancellation rate -> booking value-> customer rating
-- "1 booking"	86590	1.00	62.08	10.16	548.68	4.00
-- "2-3 bookings"	7927	2.06	62.14	10.39	548.88	4.01
-- "4-5 bookings"	27	4.04	58.72	4.59	508.61	3.97
-- Conclusion: cutomer with more frequent requests have lower success rate, lower booking value and lower customer rating