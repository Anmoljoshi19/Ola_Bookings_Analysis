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

update booking_data
set Avg_VTAT = nullif(Avg_VTAT,''),
Avg_CTAT = nullif(Avg_CTAT,''),
Reason_for_cancelling_by_Customer = nullif(Reason_for_cancelling_by_Customer,''),
Reason_for_cancelling_by_Driver = nullif(Reason_for_cancelling_by_Driver,''),
Incomplete_Rides_Reason = nullif(Incomplete_Rides_Reason,''),
Ride_Distance = nullif(Ride_Distance,''),
Driver_Ratings = nullif(Driver_Ratings,''),
Customer_Rating = nullif(Customer_Rating,'\r');

-- 3. Vtat, Ctat was in decimal format changed them to time format

update booking_data
set Avg_VTAT = SEC_TO_TIME(FLOOR(Avg_VTAT) * 60 + ROUND((Avg_VTAT - FLOOR(Avg_VTAT)) * 60)),
Avg_CTAT = SEC_TO_TIME(FLOOR(Avg_CTAT) * 60 + ROUND((Avg_CTAT - FLOOR(Avg_CTAT)) * 60)),
`date` = str_to_date(`date`, '%d-%m-%Y');
 
 -- 4. Changing data type
 
alter table booking_data
modify column `date` DATE,
modify column `Time`  TIME,
modify column Avg_VTAT  TIME,
modify column Avg_CTAT  TIME,
modify column Ride_Distance DECIMAL(5,2),
modify column Driver_Ratings DECIMAL(5,1),
modify column Customer_Rating DECIMAL(5,1);

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

-- Business Queryies

-- 1. Retrieve all successful bookings:

select * from booking_data
where Booking_Status = 'Success';

-- 2. Find the average ride distance for each vehicle type:

select Vehicle_Type, round(avg(Ride_Distance),2) as avg_ride_distance
from booking_data
group by 1;

-- 3. Get the total number of cancelled rides by customers:

select count(Booking_Status)
from booking_data
where Booking_Status = 'Cancelled by Customer';

-- 4. List the top 5 customers who booked the highest number of rides:

select Customer_ID, count(Booking_ID) as total_rides
from booking_data
group by Customer_ID
order by total_rides desc;

-- 5. Get the number of rides cancelled by drivers due to personal and car-related issues:

select count(Booking_Status)
from booking_data
where Reason_for_cancelling_by_Driver = 'Personal & Car related issues';

-- 6. Find the maximum and minimum driver ratings for Prime Sedan bookings:

select max(Driver_Ratings) as Max_rating , min(Driver_Ratings) as Min_rating
from booking_data
where Vehicle_Type = 'Prime Sedan';

-- 7. Find the average customer rating per vehicle type:

select Vehicle_Type , round(avg(Customer_Rating),1) as avg_rating
from booking_data
group by 1;

-- 8. Calculate the total booking value of rides completed successfully:

select sum(Booking_Value) as total_value
from booking_data
where Booking_Status = 'Success';

-- 9. List all incomplete rides along with the reason:

select Booking_ID, Incomplete_Rides_Reason
from booking_data
where Booking_Status = 'Incomplete';

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

