-- Obtain vehicle plates that have never been fined
SELECT v.plate 
FROM vehicle v LEFT JOIN fine f 
ON v.VehicleID = f.VehicleID
WHERE f.VehicleID IS NULL;

-- Obtain name of vehicle owners who have never received a fine
SELECT p.name, p.surname 
FROM owner o JOIN fine f 
ON o.VehicleID = f.VehicleID
JOIN person p ON f.DriverID = p.pID;

-- Obtain each province and total of subtracted points
SELECT p.Province, SUM(f.points) AS total_subtracted_points
FROM fine f JOIN person p
ON f.DriverID = p.pID
GROUP BY p.Province HAVING p.Province IS NOT NULL
ORDER BY total_subtracted_points DESC;

-- Obtain province with max number of points deducted
SELECT p.Province, SUM(f.points) AS total_subtracted_points
FROM fine f JOIN person p
ON f.DriverID = p.pID
GROUP BY p.Province HAVING p.Province IS NOT NULL
ORDER BY total_subtracted_points DESC
LIMIT 1;

-- Obtain surname and name of people sanctioned by 'mild' and 'serious' infractions
SELECT count(*)--p.surname, p.name
FROM fine f JOIN person p
ON f.DriverID = p.pID
WHERE f.score IN ('MILD', 'SERIOUS');

SELECT p.surname, p.name
FROM person p JOIN
(
	SELECT * FROM fine 
	WHERE score IN ('MILD', 'SERIOUS')
) AS ms_fines
ON ms_fines.DriverID = p.pID;

-- Obtain the plate of the vehicle that has been sanctioned on different occasions but with different drivers. 
-- Also obtain the number of times sanctioned and the number of different conductors.
SELECT v.Plate, COUNT(f.DriverID) AS different_drivers, 
COUNT(v.Plate) AS num_of_times_sanctioned
FROM vehicle v JOIN fine f
ON v.VehicleID = f.VehicleID
GROUP BY v.Plate, f.DriverID 
HAVING COUNT(v.Plate) > 1;