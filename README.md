# Ride Operations & Cancellation Analytics

End-to-end analysis of **103,024 ride bookings** to find where a ride-hailing platform loses trips, who is responsible, and what operations teams could do about it. Built with **PostgreSQL** for data validation and analysis, and **Power BI** for the reporting layer.

> **Headline:** Only 58.3% of booking requests end in a fully completed trip. Roughly **88% of all failed bookings trace back to the supply side**: driver cancellations, customer cancellations caused by driver behaviour, and no driver being available.

---

## Business questions

1. What share of booking requests actually convert into completed trips, and where does the funnel leak?
2. Who cancels, why, and how much of the loss is driver-side versus customer-side?
3. Are there pickup locations or routes that systematically underperform the network average?
4. Does turnaround time or vehicle type explain failed or incomplete rides?
5. How often do customers come back, and does repeat usage change their experience?

## Dataset

| Attribute | Value |
|---|---|
| Records | 103,024 bookings (one row per booking, `booking_id` is unique) |
| Customers | 94,544 unique |
| Vehicle types | 7 (Auto, Bike, eBike, Mini, Prime Sedan, Prime Plus, Prime SUV) |
| Geography | Bengaluru pickup and drop locations |
| Key fields | booking date/time, status, vehicle type, pickup/drop location, V_TAT, C_TAT, cancellation reasons (driver and customer), incomplete-ride flag and reason, booking value, payment method, distance, driver and customer ratings |
| Source | [Kaggle — add link here] |

**Booking statuses:** `Success`, `Canceled by Customer`, `Canceled by Driver`, `Driver Not Found`. A `Success` booking can still be flagged `incomplete_rides = 'Yes'`.

## Repository structure

```
├── README.md
├── sql/
│   ├── Table Formation and QA.sql
│   ├── Cancellation and Driver Unavailability Analysis.sql
│   ├── Vehicle and Operational Efficiency Analysis.sql
│   ├── Location Analysis.sql
│   ├── Route Analysis.sql
│   └── Customer Behavior.sql
├── dashboard/
│   └── Uber_Project.pbix
```

GitHub lists files alphabetically, so the folder view won't match the order below — that's expected. The order in this README is the actual analytical sequence: build and validate the table first, then decompose failures, then benchmark locations and routes, then segment customers.

## Approach

**1. Schema and validation (`Table Formation and QA.sql`).** Defined a typed table with `booking_id` as primary key, then checked row counts, uniqueness, and cardinality. Ran integrity checks on the logical rules the data should obey: every successful booking has a payment method and ratings; no unsuccessful booking carries a turnaround time; every incomplete ride has a reason and no complete ride does. All counts reconcile — the three failure categories sum exactly to the 39,057 unsuccessful bookings.

**2. Funnel and failure decomposition (`Cancellation and Driver Unavailability Analysis.sql`, `Vehicle and Operational Efficiency Analysis.sql`).** Split outcomes into success, incomplete-but-successful, and each failure type, then broke each failure type down by stated reason, vehicle type, and location.

**3. Benchmarking against the network (`Location Analysis.sql`).** Rather than ranking locations by raw counts, computed network-wide unsuccessful and driver-not-found rates in a CTE and returned only pickup locations with at least 500 bookings that exceed *both* benchmarks. Drop locations were tiered into Low / Normal / High demand using the 25th and 75th percentiles of booking volume.

**4. Route performance (`Route Analysis.sql`).** Aggregated at the pickup–drop pair level, with a minimum-volume threshold (≥ 50 bookings) so that unsuccessful-rate rankings aren't driven by tiny samples.

**5. Customer segmentation (`Customer Behavior.sql`).** Built per-customer metrics in a CTE, bucketed customers by booking frequency, and compared success rate, cancellation rate, booking value, and rating across segments.

**SQL techniques used:** CTEs, conditional aggregation with `FILTER (WHERE …)` and `CASE`, window functions (`RANK() OVER`), ordered-set aggregates (`PERCENTILE_CONT … WITHIN GROUP`), `CROSS JOIN` against a single-row benchmark, `HAVING` thresholds, and custom sort orders.

## Key findings

### 1. The success rate overstates how many trips actually finish

| Outcome | Bookings | Share of all bookings |
|---|---:|---:|
| Success | 63,967 | 62.1% |
| — of which incomplete | 3,926 | 3.8% |
| **Fully completed** | **60,041** | **58.3%** |
| Canceled by Driver | 18,434 | 17.9% |
| Canceled by Customer | 10,499 | 10.2% |
| Driver Not Found | 10,124 | 9.8% |

About 6.1% of rides labelled `Success` are actually incomplete. Any KPI built on booking status alone overstates completion by nearly four percentage points.

### 2. Most failures are supply-side, even many of the "customer" cancellations

Driver cancellations alone account for **47.2%** of all unsuccessful bookings. But the customer cancellation reasons tell a further story:

| Customer cancellation reason | Count | Share |
|---|---:|---:|
| Driver is not moving towards pickup location | 3,175 | 30.2% |
| Driver asked to cancel | 2,670 | 25.4% |
| Change of plans | 2,081 | 19.8% |
| AC is not working | 1,568 | 14.9% |
| Wrong address | 1,005 | 9.6% |

**55.7% of customer cancellations are caused by the driver.** Reclassifying those, driver behaviour explains 62.2% of all failed bookings; adding driver-not-found cases, **88.1% of failures originate on the supply side**. Only change of plans and wrong address (around 8% of failures) are clearly customer-driven.

### 3. Drivers and customers blame each other

| Driver cancellation reason | Count | Share |
|---|---:|---:|
| Personal & car related issue | 6,542 | 35.5% |
| Customer related issue | 5,413 | 29.4% |
| Customer was coughing/sick | 3,654 | 19.8% |
| More than permitted people | 2,825 | 15.3% |

**64.5% of driver cancellations cite the customer**, while more than half of customer cancellations cite the driver. Self-reported reasons from each side are therefore weak evidence on their own; an objective signal such as GPS movement towards pickup is needed to attribute cancellations fairly.

### 4. Turnaround time and vehicle type do not explain failures

- Average driver turnaround (V_TAT) is 170.9 s for successful rides and 172.7 s for incomplete ones; customer turnaround (C_TAT) is 84.9 s versus 84.7 s. Waiting time does not distinguish incomplete rides from completed ones.
- Completed trips by vehicle type range only from 8,449 (Prime SUV) to 8,768 (Prime Sedan), and customer cancellations from 1,470 to 1,537. No vehicle category meaningfully outperforms another.

### 5. No single location is a hotspot, so benchmarking matters

The top ten pickup locations for driver cancellations fall within a narrow band (393 to 424 cases), so a raw "top 10" ranking is close to noise. This is why the location analysis filters against network-wide rates and minimum volumes instead of ranking absolute counts.

### 6. Repeat usage is very low

**91.6% of customers booked only once** in the period; 8.4% booked two or more times. Success rate, cancellation rate, booking value, and rating are effectively identical between one-time and 2–3-booking customers (62.1% vs 62.1% success). The 4–5-booking segment contains only 27 customers, too few to draw conclusions from.

## Power BI dashboard

| Page | Purpose |
|---|---|
| Checking the Data | Validation page reconciling record counts, status totals, and KPI measures against the SQL results |
| Trend Analysis and Breakdown | Daily success rate, daily failure counts by type, successful bookings by vehicle type, average booking value |
| Turnaround Time Analysis | Average V_TAT and C_TAT by vehicle type and pickup location |
| Customer Cancellation Analysis | Customer cancellations by reason and vehicle type |
| Driver Cancellation and Unavailability Analysis | Driver cancellations by reason and location; unsuccessful bookings by drop location |
| Incomplete Rides | Incomplete rides by vehicle type and reason, average value of incomplete rides |
| Demand Location Analysis | Booking volume by pickup and drop location |
| Demand Hour Analysis | Booking volume and successful bookings by part of day |

The report uses 16 DAX measures (counts, rates, and value measures) rather than implicit aggregations, and turnaround times are averaged rather than summed.

<!-- Add screenshots here, e.g. ![Overview](screenshots/overview.png) -->

## Limitations

- **Distributions are unusually uniform** across vehicle types, reasons, and locations, which suggests the dataset is synthetic or heavily balanced. The findings demonstrate the analytical method; the specific percentages should not be read as real market figures.
- **No driver identifier**, so driver-level retention, repeat cancellation behaviour, and acquisition cohorts cannot be analysed.
- **Single-table model in Power BI.** The report runs on one flat `Bookings` table with the auto date hierarchy.

## Next steps

- Restructure the Power BI model into a star schema with a dedicated date table and vehicle and location dimensions.
- Add hour-of-day supply-demand analysis to locate when driver-not-found peaks.
- Estimate revenue at risk from failed bookings by imputing fare from median fare-per-km by vehicle type.

## Tools

PostgreSQL · Power BI Desktop · DAX · Power Query

---

**Author:** [Sadat Iqbal] · [www.linkedin.com/in/sadat-i-56006010a] · [priomipe43@gmail.com]
