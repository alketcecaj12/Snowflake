-- =====================================================================
-- Step 1, Lesson 1: experiments. Run each block on its own.
-- Before running, write down what you EXPECT to happen (your hypothesis).
-- =====================================================================

-- Experiment A: can REPORTER see raw data?
USE ROLE REPORTER;
USE WAREHOUSE TRANSFORMING_WH;
SHOW DATABASES;                -- Which databases appear? Is RAW there?

-- Experiment B: can LOADER create a table in ANALYTICS?
USE ROLE LOADER;
USE WAREHOUSE LOADING_WH;
CREATE TABLE ANALYTICS.PUBLIC.should_i_exist (id INT);   -- Success or error? Why?
CREATE TABLE RAW.SHOP.scratch (id INT);                  -- And this one?
DROP TABLE IF EXISTS RAW.SHOP.scratch;

-- Experiment C: does a warehouse cost money while idle?
USE ROLE SYSADMIN;
SHOW WAREHOUSES LIKE 'LOADING_WH';   -- note the "state" column
SELECT 1;                            -- this tiny query wakes the current warehouse
SHOW WAREHOUSES LIKE 'LOADING_WH';   -- state now? Wait ~90 seconds and run SHOW again.
