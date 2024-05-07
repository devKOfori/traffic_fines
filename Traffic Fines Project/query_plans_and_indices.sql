-- A.	Create a query to obtain the name and surname, without repetition and ordered by surname and name descendingly, 
-- of the Men (‘H’) that driving a car that is not their own, manufactured before 2005, have received at least a fine for 
-- at least 400€ during the month of september 2020.
SELECT * 
FROM fine f JOIN vehicle v
ON f.VehicleID = v.VehicleID
JOIN person p ON f.DriverID = p.pID
LEFT JOIN owner o ON f.DriverID = o.OwnerID
WHERE f.balance > 400 AND EXTRACT(MONTH FROM finedate) = 09
AND v.manufactureyear < 2005 AND p.Gender = 'H' 
AND o.OwnerID IS NULL;

-- -- B.	Study and discuss the query plan, taking note of the costs. Paste a screenshot of the query plan.
EXPLAIN SELECT * 
FROM fine f JOIN vehicle v
ON f.VehicleID = v.VehicleID
JOIN person p ON f.DriverID = p.pID
LEFT JOIN owner o ON f.DriverID = o.OwnerID
WHERE f.balance > 400 AND EXTRACT(MONTH FROM finedate) = 09
AND v.manufactureyear < 2005 AND p.Gender = 'H' 
AND o.OwnerID IS NULL;
-- -- C.	Create the primary keys using the traffic_pk.sql script and study the query plan again, comparing the costs 
-- with those of the previous question. Paste a screenshot of the query plan.
ALTER TABLE person
ADD CONSTRAINT person_pk PRIMARY KEY (pID);

ALTER TABLE vehicle
ADD CONSTRAINT vehicle_pk PRIMARY KEY (VehicleID);

ALTER TABLE owner
ADD CONSTRAINT owner_pk PRIMARY KEY (VehicleID,OwnerID,PurchaseDate);

ALTER TABLE fine
ADD CONSTRAINT fine_pk PRIMARY KEY (FineID);


-- -- D.	Now create the foreign keys using the traffic_fk.sql script and study the query plan again, comparing the costs 
-- with those of the previous question. Paste a screenshot of the query plan.
ALTER TABLE owner
ADD CONSTRAINT owner_fk_vehicle FOREIGN KEY (VehicleID) 
				 REFERENCES vehicle (VehicleID) 
				 ON DELETE CASCADE;
         
ALTER TABLE owner
ADD CONSTRAINT owner_fk_person FOREIGN KEY (OwnerID) 
				 REFERENCES person (pID) 
				 ON DELETE CASCADE;
         
ALTER TABLE fine
ADD CONSTRAINT fine_fk_vehicle FOREIGN KEY (VehicleID) 
				 REFERENCES vehicle (VehicleID) 
				 ON DELETE CASCADE;

ALTER TABLE fine
ADD CONSTRAINT fine_fk_person FOREIGN KEY (DriverID) 
				 REFERENCES person (pID) 
				 ON DELETE CASCADE;

-- -- E.	Create the indices that you deem necessary, justifying your choice and study the query plan again, 
-- comparing the costs with those of the previous question. Paste a screenshot of the query plan and the commands you used 
-- to create the indices
CREATE INDEX idx_fine_driverid ON fine (DriverID);
CREATE INDEX idx_fine_vehicleid ON fine (VehicleID);
CREATE INDEX idx_fine_finedate ON fine (finedate);
CREATE INDEX idx_vehicle_manufactureyear ON vehicle (manufactureyear);

