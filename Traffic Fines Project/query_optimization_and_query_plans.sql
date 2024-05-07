-- A.	Obtain the name and surname, as well as the province and municipality of the people  who reside 
-- in any of the Andalucian provinces ('Almería', 'Cádiz', 'Córdoba', 'Granada', 'Huelva', 'Jaén', 'Málaga', 'Sevilla') 
-- who, driving a vehicle that is black, red, yellow, white or green, and have been sanctioned 
-- during the month of october (of any year) for an infraction related to inadequate speed (the word “speed” 
-- is in the ‘action’ attribute). Order the result by province in descending order and by municipality in ascending order. 
-- Write the query using JOINs and study the query plan. 
-- Paste the query and a screenshot of the query plan.

EXPLAIN SELECT p.name, p.surname, p.province, p.municipality
FROM person p JOIN fine f ON (p.pID = f.DriverID)
JOIN vehicle v ON (f.vehicleID = v.vehicleID)
WHERE p.province IN ('Almería', 'Cádiz', 'Córdoba', 'Granada', 'Huelva', 'Jaén', 'Málaga', 'Sevilla')
AND v.color IN ('black', 'red', 'yellow', 'white', 'green')
AND EXTRACT(MONTH FROM f.finedate) = 09
AND f.action LIKE '%speed%'
ORDER BY p.province DESC, p.municipality;



-- B.	Write an alternative query using the EXISTS operator in a way that the query plan obtains different costs. 
-- Paste the query and a screenshot of the query plan.
SELECT p.name, p.surname, p.province, p.municipality
FROM person p
WHERE p.province IN ('Almería', 'Cádiz', 'Córdoba', 'Granada', 'Huelva', 'Jaén', 'Málaga', 'Sevilla')
AND EXISTS (
	SELECT * FROM fine f, vehicle v
	WHERE f.vehicleID = v.vehicleID AND f.DriverID = p.pID 
	AND EXTRACT(MONTH FROM f.finedate) = 09 AND f.action LIKE '%speed%'
	AND v.color IN ('black', 'red', 'yellow', 'white', 'green')
) 
ORDER BY p.province DESC, p.municipality;

-- C. Create the indices that you deem necessary, 
-- justifying your choice and study the query plan again, comparing the costs 
-- between the two alternative queries. Paste the query and a screenshot of the query plan, 
-- as well as the command to create the indices.
CREATE INDEX idx_fine_finedate ON fine ((EXTRACT(month FROM finedate)));
