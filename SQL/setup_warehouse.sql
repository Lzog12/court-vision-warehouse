
/*CREATE BASE SCHEMAS*/
-- Raw layer to hold JSON responses 'bronze'
CREATE SCHEMA raw;
-- Staging layer that holds 'silver' data
CREATE SCHEMA staging;
-- 'Gold' layer that holds cleaned and organised data model
CREATE SCHEMA constellation;
-- 'marts' layer holds analytical views of the warehouse data
CREATE SCHEMA marts;

-- Check existence
SELECT name FROM sys.schemas WHERE name IN ('raw', 'staging', 'constellation', 'marts');
