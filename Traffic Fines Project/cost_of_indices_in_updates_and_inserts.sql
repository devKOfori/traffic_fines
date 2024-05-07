-- 1.	The administration decides that the cost of all the fines characterized as ‘mild’
-- with a cost less than 90 euros should be increased by 10% of the cost. Perform this update, 
-- WITHIN A TRANSACTION so we can cancel it before it becomes permanent using ROLLBACK. 
-- Study the query plan and stop the update with ROLLBACK.
BEGIN;
UPDATE fine
SET balance = balance * 1.1
WHERE score = 'MILD' AND balance < 90;
ROLLBACK;


-- 2.	We want to perform a massive data insertion (within a transaction). 
-- To do that, we dump all the data in the table new_table inside fine. 
-- Take note of the execution time and cancel the insertion with ROLLBACK.
BEGIN;
INSERT INTO fine
SELECT * FROM new_table;
ROLLBACK;

-- 3.	Since we are foreseeing some queries with complex ordering, we want to create an index on the Fine table 
-- for the following attributes: informer, balance and location. Create said index.
CREATE INDEX idx_fine_complex_order ON fine(informer, balance, location);

-- 4.	Perform the same update as in (E1) after creating the index from (E3) and 
-- compare the cost (there is no explain feature in UPDATE, so runtime is enough).
BEGIN;
UPDATE fine
SET balance = balance * 1.1
WHERE score = 'MILD' AND balance < 90;
ROLLBACK;

-- 5.	Perform the same update as in (E2) after creating the index from (E3) and compare the cost 
-- (there is no explain feature in UPDATE, so runtime is enough).
BEGIN;
INSERT INTO fine
SELECT * FROM new_table;
ROLLBACK;
