-- =====================================================================
-- Step 1, Lesson 1: set up the Snowflake "skeleton"
-- Run this top to bottom in a Snowsight worksheet.
-- Every statement is safe to re-run (IF NOT EXISTS / OR REPLACE where harmless).
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Admin roles create things. We only use the powerful roles for setup.
--    SYSADMIN   -> owns databases, warehouses (the "builder")
--    SECURITYADMIN -> creates roles and users, grants (the "gatekeeper")
--    ACCOUNTADMIN  -> both, plus billing. Avoid using it day to day.
-- ---------------------------------------------------------------------
USE ROLE SYSADMIN;

-- ---------------------------------------------------------------------
-- 2. Warehouses = compute. Storage and compute are separate in Snowflake:
--    data sits in storage for (almost) free, you pay per second a warehouse runs.
--    Two warehouses so loading and transforming never fight for the same compute,
--    and so you can see in the bill which job costs what.
-- ---------------------------------------------------------------------
CREATE WAREHOUSE IF NOT EXISTS LOADING_WH
  WAREHOUSE_SIZE = 'XSMALL'      -- smallest = 1 credit/hour, plenty for our data
  AUTO_SUSPEND = 60              -- turn off after 60s idle (the #1 cost saver)
  AUTO_RESUME = TRUE             -- wake up automatically when a query arrives
  INITIALLY_SUSPENDED = TRUE
  COMMENT = 'Used by COPY INTO / Snowpipe to load raw files';

CREATE WAREHOUSE IF NOT EXISTS TRANSFORMING_WH
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE
  COMMENT = 'Used by dbt to build models';

-- ---------------------------------------------------------------------
-- 3. Databases = layers of the pipeline.
--    RAW       : data exactly as it arrived. Never edited by hand.
--    ANALYTICS : what dbt builds from RAW (staging views + marts tables).
--    Keeping them apart means you can always rebuild ANALYTICS from RAW.
-- ---------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS RAW       COMMENT = 'Landing zone, untouched source data';
CREATE DATABASE IF NOT EXISTS ANALYTICS COMMENT = 'Built by dbt from RAW';

-- One schema per source system. Our fake data comes from a "shop" app.
CREATE SCHEMA IF NOT EXISTS RAW.SHOP;

-- ---------------------------------------------------------------------
-- 4. Functional roles = who does what. Each role gets only what its job needs.
--    LOADER      : writes into RAW, uses LOADING_WH
--    TRANSFORMER : reads RAW, writes ANALYTICS, uses TRANSFORMING_WH (dbt uses this)
--    REPORTER    : reads ANALYTICS only (a BI tool or analyst would use this)
-- ---------------------------------------------------------------------
USE ROLE SECURITYADMIN;

CREATE ROLE IF NOT EXISTS LOADER;
CREATE ROLE IF NOT EXISTS TRANSFORMER;
CREATE ROLE IF NOT EXISTS REPORTER;

-- Hang the new roles under SYSADMIN so admins can still see/manage their objects.
GRANT ROLE LOADER      TO ROLE SYSADMIN;
GRANT ROLE TRANSFORMER TO ROLE SYSADMIN;
GRANT ROLE REPORTER    TO ROLE SYSADMIN;

-- Give yourself all three so you can switch between them while learning.
SET my_user = CURRENT_USER();
GRANT ROLE LOADER      TO USER IDENTIFIER($my_user);
GRANT ROLE TRANSFORMER TO USER IDENTIFIER($my_user);
GRANT ROLE REPORTER    TO USER IDENTIFIER($my_user);

-- LOADER: use its warehouse, create and fill tables in RAW.SHOP
GRANT USAGE ON WAREHOUSE LOADING_WH TO ROLE LOADER;
GRANT USAGE ON DATABASE RAW TO ROLE LOADER;
GRANT ALL ON SCHEMA RAW.SHOP TO ROLE LOADER;

-- TRANSFORMER: read everything in RAW (including tables created later), own ANALYTICS
GRANT USAGE ON WAREHOUSE TRANSFORMING_WH TO ROLE TRANSFORMER;
GRANT USAGE ON DATABASE RAW TO ROLE TRANSFORMER;
GRANT USAGE ON ALL SCHEMAS IN DATABASE RAW TO ROLE TRANSFORMER;
GRANT SELECT ON ALL TABLES IN DATABASE RAW TO ROLE TRANSFORMER;
GRANT SELECT ON FUTURE TABLES IN DATABASE RAW TO ROLE TRANSFORMER;  -- "future" = tables not created yet
GRANT ALL ON DATABASE ANALYTICS TO ROLE TRANSFORMER;

-- REPORTER: read whatever dbt builds in ANALYTICS, nothing else
GRANT USAGE ON WAREHOUSE TRANSFORMING_WH TO ROLE REPORTER;
GRANT USAGE ON DATABASE ANALYTICS TO ROLE REPORTER;
GRANT USAGE ON FUTURE SCHEMAS IN DATABASE ANALYTICS TO ROLE REPORTER;
GRANT SELECT ON FUTURE TABLES IN DATABASE ANALYTICS TO ROLE REPORTER;
GRANT SELECT ON FUTURE VIEWS  IN DATABASE ANALYTICS TO ROLE REPORTER;

-- ---------------------------------------------------------------------
-- 5. Cost guardrail: a monthly credit cap. Needs ACCOUNTADMIN.
--    10 credits/month is far more than we need; it just stops accidents.
-- ---------------------------------------------------------------------
USE ROLE ACCOUNTADMIN;

CREATE RESOURCE MONITOR IF NOT EXISTS LEARNING_MONITOR
  WITH CREDIT_QUOTA = 10
  FREQUENCY = MONTHLY
  START_TIMESTAMP = IMMEDIATELY
  TRIGGERS ON 80 PERCENT DO NOTIFY
           ON 100 PERCENT DO SUSPEND;

ALTER WAREHOUSE LOADING_WH      SET RESOURCE_MONITOR = LEARNING_MONITOR;
ALTER WAREHOUSE TRANSFORMING_WH SET RESOURCE_MONITOR = LEARNING_MONITOR;

-- ---------------------------------------------------------------------
-- 6. Check your work (this is the "analysis" step of the experiment)
-- ---------------------------------------------------------------------
SHOW WAREHOUSES LIKE '%_WH';
SHOW DATABASES LIKE 'RAW';
SHOW GRANTS TO ROLE LOADER;
SHOW GRANTS TO ROLE TRANSFORMER;
SHOW GRANTS TO ROLE REPORTER;
