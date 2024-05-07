-- 1.	Obtain the surname, name and total points subtracted from each of the drivers that have been fined. 
-- We must only obtain those for whom the sum of the points subtracted is higher than the average of the sums 
-- for all drivers. We want to order the results descendingly by the number of points subtracted and ascendingly by surname. 
-- Study the query plan and cost.

select p.surname, p.name, sum(f.points) as total_points_subtracted
from person p join fine f on (p.pID = f.DriverID)
group by p.surname, p.name
having sum(f.points) > avg(f.points)
order by sum(f.points) desc;

-- 2.	Apply the most suitable denormalization technique to speed up the previous query, 
-- creating the SQL scripts needed to modify the database schema and update the data involved in the denormalization.


DROP TABLE IF EXISTS point_summary;
CREATE TABLE point_summary(
	id SERIAL PRIMARY KEY,
	DriverID INT NOT NULL UNIQUE,
	surname VARCHAR(30) NOT NULL,
	name VARCHAR(20) NOT NULL,
	totalPoints INT DEFAULT 0
);


DROP TABLE IF EXISTS drivers_points_stats;
CREATE TABLE drivers_points_stats (
	total_points INT DEFAULT 0,
	number_of_drivers INT DEFAULT 0
);

-- 3.	Create the necessary triggers to keep the data involved in the denormalization up to date.
DROP FUNCTION IF EXISTS update_point_summary();
CREATE FUNCTION update_point_summary()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
	DECLARE 
		driver_surname VARCHAR(30);
		driver_name VARCHAR(20);
	BEGIN
		-- check if driver ID already exists in point_summary
		IF EXISTS (
			SELECT DriverID FROM point_summary
			WHERE DriverID = New.DriverID
		) 
		THEN
			-- add to driver's total points if driver ID already exist
			UPDATE point_summary
			SET totalPoints = totalPoints + New.points
			WHERE DriverID = New.DriverID;
		ELSE
			-- if driver does not exist, 
			-- 1. fetch driver surname and name from person table
			SELECT surname, name INTO driver_surname, driver_name
			FROM person
			WHERE pID = New.DriverID;
			
			-- 2. insert new record for driver
			INSERT INTO point_summary(DriverID, surname, name, totalPoints)
			VALUES(New.DriverID, driver_surname, driver_name, New.points);
		END IF;
		RETURN New;
	END;
$$;

DROP FUNCTION IF EXISTS update_point_summary_after_delete();
CREATE FUNCTION update_point_summary_after_delete()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
	BEGIN
		DELETE FROM point_summary
		WHERE DriverID = OLD.DriverID;
	END;
$$;

-- create function to update drivers points statistics after insert or update
DROP FUNCTION IF EXISTS update_drivers_points_stats();
CREATE FUNCTION update_drivers_points_stats()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
	DECLARE drivers_count INT;
	BEGIN
		-- count number of drivers in point_summary table
		SELECT COUNT(DISTINCT(DriverID)) INTO drivers_count
		FROM point_summary;
		
		
		-- update the total_points and number
		UPDATE drivers_points_stats
		SET 
		total_points = total_points + NEW.totalPoints,
		number_of_drivers = drivers_count;
		RETURN NEW;
	END;
$$;


-- create function to update drivers_points_stats on delete in point_summary table
DROP FUNCTION IF EXISTS update_drivers_points_stats_on_delete();
CREATE FUNCTION update_drivers_points_stats_on_delete()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
	BEGIN
		UPDATE drivers_points_stats
		SET total_points = total_points - OLD.totalPoints,
		number_of_drivers = number_of_drivers - 1;
	END;
$$;

-- create trigger and bind to update_point_summary table after update or insert
DROP TRIGGER IF EXISTS trg_update_point_summary ON fine;
CREATE TRIGGER trg_update_point_summary
AFTER INSERT OR UPDATE
ON fine
FOR EACH ROW
EXECUTE FUNCTION update_point_summary();

-- create trigger and bind to update_point_summary table after delete
DROP TRIGGER IF EXISTS trg_update_point_summary2 ON fine;
CREATE TRIGGER trg_update_point_summary2
AFTER DELETE
ON fine
FOR EACH ROW
EXECUTE FUNCTION update_point_summary_after_delete();


-- create insert and update trigger and bind to update_drivers_points_stats
DROP TRIGGER IF EXISTS trg_update_drivers_points_stats ON point_summary;
CREATE TRIGGER trg_update_drivers_points_stats
AFTER INSERT OR UPDATE
ON point_summary
FOR EACH ROW
EXECUTE FUNCTION update_drivers_points_stats();

-- create after delete trigger and bind to update_drivers_points_stats_on_delete
DROP TRIGGER IF EXISTS update_drivers_points_stats_on_delete ON point_summary;
CREATE TRIGGER trg_update_drivers_points_stats_after_delete
AFTER DELETE
ON point_summary
FOR EACH ROW
EXECUTE FUNCTION update_drivers_points_stats_on_delete();

-- 4.	Repeat the query after applying the denormalization and creating the trigger. 
-- Study the query plan and cost and compare it with that of (1).

EXPLAIN SELECT * FROM point_summary;
SELECT * FROM drivers_points_stats;
SELECT surname, name, totalpoints
FROM point_summary
WHERE totalpoints >
(
	SELECT total_points / number_of_drivers
	FROM drivers_points_stats
) 
ORDER BY totalpoints;

-- 5.	Repeat the massive data insertion from (E2) with the denormalized database, 
-- studying the query plan and comparing the results obtained with those of E2.

BEGIN;
INSERT INTO fine
SELECT * FROM new_table;
ROLLBACK;