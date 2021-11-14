@..\install_prereq\initspool period_agg_report_queries
/***************************************************************************************************
Name: install_period_agg_reporting.sql   Author: Brendan Furey                     Date: 14-Nov-2021

Query driver script for the oracle_sql_projects Github project (subproject period_agg_reporting). 

Queries the test data with running sums, then runs the five queries for the reporting requirement,
three of which are static, with two using dynamic SQL, with gather_plan_statistics and SQL marker
text. At the end the five execution plans are printed via the Utils.Get_XPlan utility.

    GitHub: https://github.com/BrenPatF/oracle_sql_projects
    Blog:   https://brenpatf.github.io/jekyll/update/2021/11/14/2021-11-14-sql-for-period-aggregate-reporting.html

====================================================================================================
|  Script                            |  Notes                                                      |
|==================================================================================================|
|  install_period_agg_reporting.sql  |  Install driver script, calls remaining scripts below       |
|------------------------------------|-------------------------------------------------------------|
|  c_sales_history.sql               |  Creates sales_history table and inserts randomized data    |
|------------------------------------|-------------------------------------------------------------|
|  period_agg_dynamic.pks            |  Period_Agg_Dynamic package spec                            |
|------------------------------------|-------------------------------------------------------------|
|  period_agg_dynamic.pkb            |  Period_Agg_Dynamic package body                            |
|------------------------------------|-------------------------------------------------------------|
| *period_agg_report_queries.sql*    |  Query driver script                                        |
====================================================================================================

***************************************************************************************************/

COLUMN month_dt    FORMAT A11      HEADING "Month"
COLUMN prod_code   FORMAT A10      HEADING "Product"
COLUMN per_tp      FORMAT A15      HEADING "Period"
COLUMN sales_value FORMAT 999,990  HEADING "Value"
COLUMN sales_cost  FORMAT 999,990  HEADING "Cost"
COLUMN value_rsum  FORMAT 999,990  HEADING "Value to Date"
COLUMN cost_rsum   FORMAT 999,990  HEADING "Cost to Date"
ALTER SESSION SET NLS_DATE_FORMAT = "DD-Mon-YYYY";
BREAK ON prod_code
PROMPT Sales History Records with Running Sums
SELECT prod_code, month_dt, sales_value, Sum(sales_value) OVER (PARTITION BY prod_code ORDER BY month_dt) value_rsum, 
     sales_cost, Sum(sales_cost) OVER (PARTITION BY prod_code ORDER BY month_dt) cost_rsum
  FROM sales_history
 ORDER BY 1, 2
/
l
BREAK ON month_dt ON prod_code
PROMPT Periods Report by Union of Group Bys
SELECT /*+ gather_plan_statistics XPLAN_UGB */ 
     month_dt, prod_code, 'P1 - 1 Month' per_tp, sales_value, sales_cost
  FROM sales_history
 UNION ALL
SELECT drv.month_dt, drv.prod_code, 'P2 - 3 Months', Sum(msr.sales_value), Sum(msr.sales_cost)
  FROM sales_history drv
  JOIN sales_history msr
  ON msr.prod_code = drv.prod_code
   AND msr.month_dt BETWEEN Add_Months (drv.month_dt, -2) AND drv.month_dt
 GROUP BY drv.prod_code, drv.month_dt
 UNION ALL
SELECT drv.month_dt, drv.prod_code, 'P3 - YTD', Sum(msr.sales_value), Sum(msr.sales_cost)
  FROM sales_history drv
  JOIN sales_history msr
  ON msr.prod_code = drv.prod_code
   AND msr.month_dt BETWEEN Trunc(drv.month_dt, 'YEAR') AND drv.month_dt
 GROUP BY drv.prod_code, drv.month_dt
 UNION ALL
SELECT drv.month_dt, drv.prod_code, 'P4 - 1 Year', Sum(msr.sales_value), Sum(msr.sales_cost)
  FROM sales_history drv
  JOIN sales_history msr
  ON msr.prod_code = drv.prod_code
   AND msr.month_dt BETWEEN Add_Months (drv.month_dt, -11) AND drv.month_dt
 GROUP BY drv.prod_code, drv.month_dt
 ORDER BY 1, 2, 3
/
l
PROMPT Report by Analytic Aggregation
WITH period_aggs AS (
  SELECT /*+ gather_plan_statistics XPLAN_AAG */ 
       month_dt, prod_code, sales_value, 
       Sum(sales_value) OVER (PARTITION BY prod_code ORDER BY month_dt
                  RANGE BETWEEN INTERVAL '2' MONTH PRECEDING AND CURRENT ROW)     sales_value_3m, 
       Sum(sales_value) OVER (PARTITION BY prod_code, Trunc(month_dt, 'YEAR') ORDER BY month_dt
                  RANGE BETWEEN INTERVAL '11' MONTH PRECEDING AND CURRENT ROW)     sales_value_ytd, 
       Sum(sales_value) OVER (PARTITION BY prod_code ORDER BY month_dt
                  RANGE BETWEEN INTERVAL '11' MONTH PRECEDING AND CURRENT ROW)     sales_value_1y, 
       sales_cost,
       Sum(sales_cost) OVER (PARTITION BY prod_code ORDER BY month_dt
                  RANGE BETWEEN INTERVAL '2' MONTH PRECEDING AND CURRENT ROW)     sales_cost_3m, 
       Sum(sales_cost) OVER (PARTITION BY prod_code, Trunc(month_dt, 'YEAR') ORDER BY month_dt
                  RANGE BETWEEN INTERVAL '11' MONTH PRECEDING AND CURRENT ROW)     sales_cost_ytd, 
       Sum(sales_cost) OVER (PARTITION BY prod_code ORDER BY month_dt
                  RANGE BETWEEN INTERVAL '11' MONTH PRECEDING AND CURRENT ROW)     sales_cost_1y
    FROM sales_history
)
SELECT *
  FROM period_aggs
UNPIVOT (
    (sales_value, sales_cost)
    FOR per_tp IN (
      (sales_value, sales_cost)       AS 'P1 - 1 Month',
      (sales_value_3m, sales_cost_3m)   AS 'P2 - 3 Months',
      (sales_value_ytd, sales_cost_ytd)   AS 'P3 - YTD',
      (sales_value_1y, sales_cost_1y)   AS 'P4 - 1 Year'
    )
)
 ORDER BY 1, 2, 3
/
l
PROMPT Report by Single Group By with CASE Expressions
WITH period_list AS (
  SELECT month_dt, prod_code, COLUMN_VALUE per_tp
    FROM TABLE(SYS.ODCIVarchar2List(
          'P1 - 1 Month',
          'P2 - 3 Months',
          'P3 - YTD',
          'P4 - 1 Year')
      )
  CROSS JOIN (SELECT month_dt, prod_code FROM sales_history)
)
SELECT /*+ gather_plan_statistics XPLAN_GBC */
       drv.month_dt, drv.prod_code, drv.per_tp,
       Sum( CASE WHEN ( per_tp = 'P1 - 1 Month'  AND msr.month_dt = drv.month_dt ) OR 
                      ( per_tp = 'P2 - 3 Months' AND msr.month_dt >= Add_Months (drv.month_dt, -2) ) OR 
                      ( per_tp = 'P3 - YTD'      AND Trunc (msr.month_dt, 'YEAR') = Trunc (drv.month_dt, 'YEAR') ) OR 
                      ( per_tp = 'P4 - 1 Year'   AND msr.month_dt >= Add_Months (drv.month_dt, -11) )
                 THEN msr.sales_value END) sales_value,
       Sum( CASE WHEN ( per_tp = 'P1 - 1 Month'  AND msr.month_dt = drv.month_dt ) OR 
                      ( per_tp = 'P2 - 3 Months' AND msr.month_dt >= Add_Months (drv.month_dt, -2) ) OR 
                      ( per_tp = 'P3 - YTD'      AND Trunc (msr.month_dt, 'YEAR') = Trunc (drv.month_dt, 'YEAR') ) OR 
                      ( per_tp = 'P4 - 1 Year'   AND msr.month_dt >= Add_Months (drv.month_dt, -11) )
                 THEN msr.sales_cost END) sales_cost
  FROM period_list drv
  JOIN sales_history msr
  ON msr.prod_code = drv.prod_code
   AND msr.month_dt <= drv.month_dt
 GROUP BY drv.prod_code, drv.month_dt, drv.per_tp
 ORDER BY 1, 2, 3
/
l
PROMPT Report by Analytic Aggregation in pipelined function
SELECT *
  FROM Period_Agg_Dynamic.Period_Aggs(p_period_tps_lis => L1_chr_arr('cur', '3m', 'ytd', '1y'), 
                                      p_period_nos_lis => L1_num_arr( 0,     2,    11,    11))
 ORDER BY 1, 2, 3
/
l
PROMPT Report by Analytic Aggregation in SQL macro
SELECT /*+ gather_plan_statistics XPLAN_MAC */ *
  FROM Period_Agg_Dynamic.Period_Aggs_Macro(p_column_lis     => L1_chr_arr('sales_value', 'sales_cost'), 
                                            p_period_tps_lis => L1_chr_arr('cur', '3m', 'ytd', '1y'),
                                            p_period_nos_lis => L1_num_arr( 0,     2,    11,    11))
 ORDER BY 1, 2, 3
/
l
EXEC  Utils.W(Utils.Get_XPlan(p_sql_marker => 'XPLAN_UGB'));
EXEC  Utils.W(Utils.Get_XPlan(p_sql_marker => 'XPLAN_AAG'));
EXEC  Utils.W(Utils.Get_XPlan(p_sql_marker => 'XPLAN_GBC'));
EXEC  Utils.W(Utils.Get_XPlan(p_sql_marker => 'XPLAN_PLF'));
EXEC  Utils.W(Utils.Get_XPlan(p_sql_marker => 'XPLAN_MAC'));

@..\install_prereq\endspool