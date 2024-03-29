/***************************************************************************************************
Name: install_period_agg_reporting.sql   Author: Brendan Furey                     Date: 14-Nov-2021

Table creation/population script for the oracle_sql_projects Github project
(subproject period_agg_reporting). 

Creeates table with test data, to demonstrate dynamic SQL approaches to reporting sales performance
across multiple time periods. This script is called by the install driver script.

    GitHub: https://github.com/BrenPatF/oracle_sql_projects
    Blog:   https://brenpatf.github.io/jekyll/update/2021/11/14/2021-11-14-sql-for-period-aggregate-reporting.html

====================================================================================================
|  Script                            |  Notes                                                      |
|==================================================================================================|
|  install_period_agg_reporting.sql  |  Install driver script, calls remaining scripts below       |
|------------------------------------|-------------------------------------------------------------|
| *c_sales_history.sql*              |  Creates sales_history table and inserts randomized data    |
|------------------------------------|-------------------------------------------------------------|
|  period_agg_dynamic.pks            |  Period_Agg_Dynamic package spec                            |
|------------------------------------|-------------------------------------------------------------|
|  period_agg_dynamic.pkb            |  Period_Agg_Dynamic package body                            |
|------------------------------------|-------------------------------------------------------------|
|  period_agg_report_queries.sql     |  Query driver script                                        |
====================================================================================================

Components created in app schema:

    Tables              Description
    ==================  ============================================================================
    sales_history       Source sales order history demo table for the queries

    Test Data           Description
    ==================  ============================================================================
    sales_history       Randomized records inserted


***************************************************************************************************/
PROMPT Create sales_history
DROP TABLE sales_history
/
CREATE TABLE sales_history (
        prod_code               VARCHAR2(30) NOT NULL,
        month_dt                DATE NOT NULL,
        sales_value             NUMBER(10,0),
        sales_cost              NUMBER(10,0),
        CONSTRAINT slh_pk       PRIMARY KEY (prod_code, month_dt)
)
/
l
PROMPT 3 years random values for PROD_ONE
INSERT INTO sales_history
WITH month_gen AS (
	SELECT LEVEL rn, Add_Months(Trunc(SYSDATE, 'MONTH'), LEVEL - 36) dt
	  FROM DUAL
	CONNECT BY LEVEL < 37
)
SELECT 'PROD_ONE',
	   dt,
	  DBMS_Random.Value (low => 1000, high => 10000),
	  DBMS_Random.Value (low => 100, high => 1000)
  FROM month_gen
/
l
PROMPT 3 years random values for PROD_TWO
INSERT INTO sales_history
WITH month_gen AS (
	SELECT LEVEL rn, Add_Months(Trunc(SYSDATE, 'MONTH'), LEVEL - 36) dt
	  FROM DUAL
	CONNECT BY LEVEL < 37
)
SELECT 'PROD_TWO',
	   dt,
	  DBMS_Random.Value (low => 1000, high => 10000),
	  DBMS_Random.Value (low => 100, high => 1000)
  FROM month_gen
/
EXEC DBMS_Stats.Gather_Table_Stats (ownname => 'APP', tabname => 'sales_history')
COMMIT
/
