CREATE OR REPLACE PACKAGE Period_Agg_Dynamic AS
/***************************************************************************************************
Name: Period_Agg_Dynamic.pks            Author: Brendan Furey                      Date: 14-Nov-2021

Package spec component in the oracle_sql_projects Github project (subproject period_agg_reporting). 

The PL/SQL package contains a pipelined function and a SQL macro function to demonstrate dynamic SQL
approaches to reporting sales performance across multiple time periods.

    GitHub: https://github.com/BrenPatF/oracle_sql_projects
    Blog:   https://brenpatf.github.io/jekyll/update/2021/11/14/2021-11-14-sql-for-period-aggregate-reporting.html

====================================================================================================
|  Script                            |  Notes                                                      |
|==================================================================================================|
|  install_period_agg_reporting.sql  |  Install driver script, calls remaining scripts below       |
|------------------------------------|-------------------------------------------------------------|
|  c_sales_history.sql               |  Creates sales_history table and inserts randomized data    |
|------------------------------------|-------------------------------------------------------------|
| *period_agg_dynamic.pks            |  Period_Agg_Dynamic package spec                            |
|------------------------------------|-------------------------------------------------------------|
|  period_agg_dynamic.pkb            |  Period_Agg_Dynamic package body                            |
|------------------------------------|-------------------------------------------------------------|
|  period_agg_report_queries.sql     |  Query driver script                                        |
====================================================================================================

This file has the Period_Agg_Dynamic package spec

***************************************************************************************************/
TYPE period_agg_rec IS RECORD(
            month_dt                      sales_history.month_dt%TYPE,
            prod_code                     sales_history.prod_code%TYPE,
            per_tp                        VARCHAR2(30),
            sales_value                   sales_history.sales_value%TYPE,
            sales_cost                    sales_history.sales_cost%TYPE
);
TYPE period_agg_arr IS TABLE OF period_agg_rec;

FUNCTION Period_Aggs(
            p_period_tps_lis               L1_chr_arr, 
            p_period_nos_lis               L1_num_arr) 
            RETURN                         period_agg_arr PIPELINED;

FUNCTION Period_Aggs_Macro(
            p_column_lis                   L1_chr_arr, 
            p_period_tps_lis               L1_chr_arr, 
            p_period_nos_lis               L1_num_arr) 
            RETURN                         VARCHAR2 SQL_MACRO;

END Period_Agg_Dynamic;
/
SHO ERR
