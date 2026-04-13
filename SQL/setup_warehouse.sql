
/*CREATE BASE SCHEMAS*/
-- Raw layer to hold JSON responses 'bronze'
CREATE SCHEMA raw;
-- Staging layer that holds 'silver' data
CREATE SCHEMA staging;
-- 'Gold' layer that holds final cleaned and organised data model
CREATE SCHEMA warehouse;

-- Check existence
SELECT name FROM sys.schemas WHERE name IN ('raw', 'staging', 'warehouse');
