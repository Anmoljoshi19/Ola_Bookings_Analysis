[Ola Bookings Analysis](https://github.com/Anmoljoshi19/Ola_Bookings_Analysis/blob/main/Ola_booking_data.csv)

**Overview**

This project involves generating a synthetic dataset of 100,000 ride-booking records for Bengaluru,
analyzing booking trends, cancellations, and ride performance using SQL and Power BI. It provides insights
into ride volume, revenue, customer behavior, and rating distributions to support data-driven decision-making.

--------------------------------------------------------------------------------------------------------------------------

**Tools Used**

- MySQL (Data Cleaning, Transformation & Analysis)
- Power BI (Visualizations)
--------------------------------------------------------------------------------------------------------------------------

**Dataset**

- Date: Ride booking date  
- Time: Ride booking time  
- Booking_ID: Unique 10-digit identifier starting with "CNR"  
- Booking_Status: Status of the ride (Success, Cancelled by Customer, Cancelled by Driver, Incomplete)  
- Customer_ID: Unique identifier for the customer  
- Vehicle_Type: Type of vehicle used (Auto, Prime Plus, Prime Sedan, Mini, Bike, eBike, Prime SUV)  
- Pickup_Location: Starting point of the ride (50 predefined Bengaluru locations)  
- Drop_Location: Ending point of the ride (from the same 50 locations)  
- V_TAT: Vehicle turnaround time (Time taken for the vehicle to arrive)  
- C_TAT: Customer turnaround time (Time taken for the customer to reach the vehicle)  
- Cancelled_Rides_by_Customer: Number of rides canceled by the customer  
- Reason_for_Cancellation_by_Customer: Reason for customer cancellation (e.g., Driver not moving, Change of plans)  
- Cancelled_Rides_by_Driver: Number of rides canceled by the driver  
- Reason_for_Cancellation_by_Driver: Reason for driver cancellation (e.g., Personal issue, Customer had more passengers)  
- Incomplete_Rides: Number of rides that were incomplete  
- Incomplete_Rides_Reason: Reason for incomplete rides (Customer demand, Vehicle breakdown, Other issues)  
- Booking_Value: Fare amount for the ride  
- Payment_Method: Mode of payment (Cash, UPI, Card, Wallet)  
- Ride_Distance: Distance traveled during the ride (in km)  
- Driver_Ratings: Rating given by customers to drivers (1-5)  
- Customer_Rating: Rating given by drivers to customers (1-5)  

--------------------------------------------------------------------------------------------------------------------------

**Data Cleaning & Standardization**
```sql

CREATE TABLE booking_data (
    Date TEXT,
    Time TEXT,
    Booking_ID TEXT,
    Booking_Status TEXT,
    Customer_ID INT,
    Vehicle_Type TEXT,
    Pickup_Location TEXT,
    Drop_Location TEXT,
    Avg_VTAT TEXT,
    Avg_CTAT TEXT,
    Cancelled_Rides_by_Customer INT,
    Reason_for_cancelling_by_Customer TEXT,
    Cancelled_Rides_by_Driver INT,
    Reason_for_cancelling_by_Driver TEXT,
    Incomplete_Rides INT,
    Incomplete_Rides_Reason TEXT,
    Booking_Value INT,
    Ride_Distance TEXT,
    Driver_Ratings TEXT,
    Customer_Rating TEXT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Ola_booking_data.csv'
INTO TABLE booking_data
FIELDS TERMINATED BY ','  
OPTIONALLY ENCLOSED BY '"'  
LINES TERMINATED BY '\n'  
IGNORE 1 ROWS;

------------------------------------------------------------------------------------------------------------------------
-- Cleaning & Standaradising Data

-- 1. Droping unneccesary columns

ALTER TABLE booking_data
DROP COLUMN Cancelled_Rides_by_Customer,
DROP COLUMN Cancelled_Rides_by_Driver,
DROP COLUMN Incomplete_Rides;

-- 2. Replacing blank cells with null

UPDATE booking_data 
SET 
    Avg_VTAT = NULLIF(Avg_VTAT, ''),
    Avg_CTAT = NULLIF(Avg_CTAT, ''),
    Reason_for_cancelling_by_Customer = NULLIF(Reason_for_cancelling_by_Customer, ''),
    Reason_for_cancelling_by_Driver = NULLIF(Reason_for_cancelling_by_Driver, ''),
    Incomplete_Rides_Reason = NULLIF(Incomplete_Rides_Reason, ''),
    Ride_Distance = NULLIF(Ride_Distance, ''),
    Driver_Ratings = NULLIF(Driver_Ratings, ''),
    Customer_Rating = NULLIF(Customer_Rating, '
');

-- 3. Vtat, Ctat was in decimal format changed them to time format

UPDATE booking_data 
SET 
    Avg_VTAT = SEC_TO_TIME(FLOOR(Avg_VTAT) * 60 + ROUND((Avg_VTAT - FLOOR(Avg_VTAT)) * 60)),
    Avg_CTAT = SEC_TO_TIME(FLOOR(Avg_CTAT) * 60 + ROUND((Avg_CTAT - FLOOR(Avg_CTAT)) * 60)),
    `date` = STR_TO_DATE(`date`, '%d-%m-%Y');
 
 -- 4. Changing data type
 
alter table booking_data
modify column `date` DATE,
modify column `Time`  TIME,
modify column Avg_VTAT  TIME,
modify column Avg_CTAT  TIME,
modify column Ride_Distance DECIMAL(5,2),
modify column Driver_Ratings DECIMAL(5,1),
modify column Customer_Rating DECIMAL(5,1);

```
--------------------------------------------------------------------------------------------------------------------------

-- **Business Queryies**
```sql

-- 1. Retrieve all successful bookings:

select * from booking_data
where Booking_Status = 'Success';

-- 2. Find the average ride distance for each vehicle type:

SELECT 
    Vehicle_Type,
    ROUND(AVG(Ride_Distance), 2) AS avg_ride_distance
FROM
    booking_data
GROUP BY 1;

-- 3. Get the total number of cancelled rides by customers:

SELECT 
    COUNT(Booking_Status)
FROM
    booking_data
WHERE
    Booking_Status = 'Cancelled by Customer';

-- 4. List the top 5 customers who booked the highest number of rides:

SELECT 
    Customer_ID, COUNT(Booking_ID) AS total_rides
FROM
    booking_data
GROUP BY Customer_ID
ORDER BY total_rides DESC;

-- 5. Get the number of rides cancelled by drivers due to personal and car-related issues:

SELECT 
    COUNT(Booking_Status)
FROM
    booking_data
WHERE
    Reason_for_cancelling_by_Driver = 'Personal & Car related issues';

-- 6. Find the maximum and minimum driver ratings for Prime Sedan bookings:

SELECT 
    MAX(Driver_Ratings) AS Max_rating,
    MIN(Driver_Ratings) AS Min_rating
FROM
    booking_data
WHERE
    Vehicle_Type = 'Prime Sedan';

-- 7. Find the average customer rating per vehicle type:

SELECT 
    Vehicle_Type, ROUND(AVG(Customer_Rating), 1) AS avg_rating
FROM
    booking_data
GROUP BY 1;

-- 8. Calculate the total booking value of rides completed successfully:

SELECT 
    SUM(Booking_Value) AS total_value
FROM
    booking_data
WHERE
    Booking_Status = 'Success';

-- 9. List all incomplete rides along with the reason:

SELECT 
    Booking_ID, Incomplete_Rides_Reason
FROM
    booking_data
WHERE
    Booking_Status = 'Incomplete';

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

-- Exporting dataset for Dashboard building

SELECT 'Date', 'Time', 'Booking_ID', 'Booking_Status', 'Customer_ID', 'Vehicle_Type', 
       'Pickup_Location', 'Drop_Location', 'Avg_VTAT', 'Avg_CTAT', 
        'Reason_for_cancelling_by_Customer', 
        'Reason_for_cancelling_by_Driver', 
        'Incomplete_Rides_Reason', 'Booking_Value', 
       'Ride_Distance', 'Driver_Ratings', 'Customer_Rating'
UNION ALL
SELECT * 
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Cleaned_ola_booking_data.csv'
FIELDS TERMINATED BY ','  
OPTIONALLY ENCLOSED BY '"'  
LINES TERMINATED BY '\n'
FROM booking_data;

```
[SQL-Code-Ola-Bookings-Analysis](https://github.com/Anmoljoshi19/Ola_Bookings_Analysis/blob/main/Ola_booking.sql)

--------------------------------------------------------------------------------------------------------------------------

**Conclusion**

Conclusion  

This dataset provides a detailed overview of ride bookings in Bengaluru, capturing key metrics such as
booking status, vehicle types, cancellations, ride distances, and ratings. By analyzing this data, valuable
insights can be derived regarding customer behavior, ride demand patterns, and operational efficiency. The structured dataset
supports SQL-based analysis and Power BI visualization, enabling data-driven decision-making for optimizing ride services,
reducing cancellations, and improving overall user experience.

[Dashboard Slide 1](https://github.com/Anmoljoshi19/Ola_Bookings_Analysis/blob/main/PowerBI%20Report/Complete_report_ss/Screenshot%202025-03-07%20201122.png)
[Dashboard Slide 2](https://github.com/Anmoljoshi19/Ola_Bookings_Analysis/blob/main/PowerBI%20Report/Complete_report_ss/Screenshot%202025-03-07%20201233.png)
[Dashboard Slide 3](https://github.com/Anmoljoshi19/Ola_Bookings_Analysis/blob/main/PowerBI%20Report/Complete_report_ss/Screenshot%202025-03-07%20201301.png)
[Dashboard Slide 4](https://github.com/Anmoljoshi19/Ola_Bookings_Analysis/blob/main/PowerBI%20Report/Complete_report_ss/Screenshot%202025-03-07%20201314.png)
[Dashboard Slide 5](https://github.com/Anmoljoshi19/Ola_Bookings_Analysis/blob/main/PowerBI%20Report/Complete_report_ss/Screenshot%202025-03-07%20201331.png)

[Dashboard_file](https://github.com/Anmoljoshi19/Ola_Bookings_Analysis/blob/main/PowerBI%20Report/Ola%20_booking_powerBI.pbix)
