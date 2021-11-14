WHENEVER SQLERROR CONTINUE
@..\install_prereq\initspool install_period_agg_reporting
/***************************************************************************************************
Name: install_period_agg_reporting.sql   Author: Brendan Furey                     Date: 14-Nov-2021

Installation script for the oracle_sql_projects Github project (subproject period_agg_reporting). 

Creeates table with test data, and PL/SQL package containing a pipelined function and a SQL macro 
function to demonstrate dynamic SQL approaches to reporting sales performance across multiple time
periods.

    GitHub: https://github.com/BrenPatF/oracle_sql_projects
    Blog:   https://brenpatf.github.io/jekyll/update/2021/11/14/2021-11-14-sql-for-period-aggregate-reporting.html

====================================================================================================
|  Script                            |  Notes                                                      |
|==================================================================================================|
| *install_period_agg_reporting.sql* |  Install driver script, calls remaining scripts below       |
|------------------------------------|-------------------------------------------------------------|
|  c_sales_history.sql               |  Creates sales_history table and inserts randomized data    |
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

    Packages            Description
    ==================  ============================================================================
    period_agg_dynamic  Dynamic SQL package, with pipelined function and macro function

***************************************************************************************************/

PROMPT Table creation and population
PROMPT =============================

@c_sales_history

PROMPT Packages creation
PROMPT =================

PROMPT Create package Period_Agg_Dynamic
@period_agg_dynamic.pks
@period_agg_dynamic.pkb

@..\install_prereq\endspool