CREATE OR REPLACE PACKAGE BODY Period_Agg_Dynamic AS
/***************************************************************************************************
Name: Period_Agg_Dynamic.pkb            Author: Brendan Furey                      Date: 14-Nov-2021

Package body component in the oracle_sql_projects Github project (subproject period_agg_reporting). 

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
|  period_agg_dynamic.pks            |  Period_Agg_Dynamic package spec                            |
|------------------------------------|-------------------------------------------------------------|
| *period_agg_dynamic.pkb*           |  Period_Agg_Dynamic package body                            |
|------------------------------------|-------------------------------------------------------------|
|  period_agg_report_queries.sql     |  Query driver script                                        |
====================================================================================================

This file has the Period_Agg_Dynamic package body

***************************************************************************************************/
/***************************************************************************************************

Period_Aggs: Pipelined function for reporting sales performance across multiple time periods. Period
             types are parametrized with numbers of months to look back

Usage:
SELECT *
  FROM Period_Agg_Dynamic.Period_Aggs(p_period_tps_lis => L1_chr_arr('cur', '3m', 'ytd', '1y'), 
                                      p_period_nos_lis => L1_num_arr( 0,     2,    11,    11))
 ORDER BY 1, 2, 3

***************************************************************************************************/
FUNCTION Period_Aggs(
            p_period_tps_lis               L1_chr_arr,                 -- period types to include (eg 'ytd', '1y' etc.)
            p_period_nos_lis               L1_num_arr)                 -- # period months to go back per period name
            RETURN                         period_agg_arr PIPELINED IS -- array of report records

  csr_period_aggs     SYS_REFCURSOR;
  l_column_lis        L1_chr_arr := L1_chr_arr('sales_value', 'sales_cost');

  l_query_text          VARCHAR2(4000) := 'WITH period_aggs AS (' ||
                                        'SELECT /*+ gather_plan_statistics XPLAN_PLF */ ' ||
                                        ' month_dt, prod_code';
  l_period_aggs       period_agg_rec;
BEGIN

  FOR i IN 1..l_column_lis.COUNT LOOP
    FOR j IN 1..p_period_tps_lis.COUNT LOOP

      l_query_text := l_query_text || ', ' || 
        CASE p_period_tps_lis(j) 
          WHEN 'cur' THEN l_column_lis(i) 
        ELSE
          'Sum(' || l_column_lis(i) || ') OVER (PARTITION BY prod_code ORDER BY ' ||
            CASE p_period_tps_lis(j) WHEN 'ytd' THEN 'Trunc(month_dt, ''YEAR'')' 
                                                ELSE ' month_dt' END ||
            ' RANGE BETWEEN INTERVAL ''' || p_period_nos_lis(j) || 
            ''' MONTH PRECEDING AND CURRENT ROW) ' ||
            l_column_lis(i) || CASE WHEN p_period_tps_lis(j)  != 'cur' THEN '_' || 
            p_period_tps_lis(j) END
        END;

    END LOOP;
  END LOOP;

  l_query_text := l_query_text || ' FROM sales_history) SELECT * FROM period_aggs UNPIVOT ((';
  FOR i IN 1..l_column_lis.COUNT LOOP

    l_query_text := l_query_text || l_column_lis(i) || ',';

  END LOOP;

  l_query_text := RTrim(l_query_text, ',') || ') FOR per_tp IN (';

  FOR j IN 1..p_period_tps_lis.COUNT LOOP

    l_query_text := l_query_text || '(';
    FOR i IN 1..l_column_lis.COUNT LOOP

      l_query_text := l_query_text || l_column_lis(i) || CASE WHEN p_period_tps_lis(j) != 'cur' THEN '_' ||
                    p_period_tps_lis(j) END || ',';

    END LOOP;
    l_query_text := RTrim(l_query_text, ',') || ') AS ''P' || j || ' - ' || p_period_tps_lis(j) || ''',';

  END LOOP;
  l_query_text := RTrim(l_query_text, ',') || '))';

  OPEN csr_period_aggs FOR l_query_text;

  LOOP
      FETCH csr_period_aggs INTO l_period_aggs;
      EXIT WHEN csr_period_aggs%NOTFOUND;
      PIPE ROW (l_period_aggs);
  END LOOP;

END Period_Aggs;

/***************************************************************************************************

Period_Aggs_Macro: SQL macro function for reporting sales performance across multiple time periods.
                   Both (measure) columns to include and period types are parametrized, with numbers
                   of months to look back. SQL macros available from Oracle database 19.6

Usage:
SELECT *
  FROM Period_Agg_Dynamic.Period_Aggs_Macro(p_column_lis     => L1_chr_arr('sales_value', 'sales_cost'), 
                                            p_period_tps_lis => L1_chr_arr('cur', '3m', 'ytd', '1y'),
                                            p_period_nos_lis => L1_num_arr( 0,     2,    11,    11))
 ORDER BY 1, 2, 3

***************************************************************************************************/
FUNCTION Period_Aggs_Macro(
            p_column_lis                   L1_chr_arr,           -- columns to include
            p_period_tps_lis               L1_chr_arr,           -- period types to include (eg 'ytd', '1y' etc.)
            p_period_nos_lis               L1_num_arr)           -- # period months to go back per period name
            RETURN                         VARCHAR2 SQL_MACRO IS -- SQL macro = text of query (upto 4000ch)

  l_query_text          VARCHAR2(4000) := 'WITH period_aggs AS (' ||
                                        'SELECT month_dt, prod_code';
BEGIN

  FOR i IN 1..p_column_lis.COUNT LOOP
    FOR j IN 1..p_period_tps_lis.COUNT LOOP

      l_query_text := l_query_text || ', ' || 
        CASE p_period_tps_lis(j) 
          WHEN 'cur' THEN p_column_lis(i) 
        ELSE
          'Sum(' || p_column_lis(i) || ') OVER (PARTITION BY prod_code ORDER BY ' ||
            CASE p_period_tps_lis(j) WHEN 'ytd' THEN 'Trunc(month_dt, ''YEAR'')' ELSE ' month_dt' END ||
            ' RANGE BETWEEN INTERVAL ''' || p_period_nos_lis(j) || 
            ''' MONTH PRECEDING AND CURRENT ROW) ' ||
            p_column_lis(i) || CASE WHEN p_period_tps_lis(j)  != 'cur' THEN '_' || 
            p_period_tps_lis(j) END
        END;

    END LOOP;
  END LOOP;

  l_query_text := l_query_text || ' FROM sales_history) SELECT * FROM period_aggs UNPIVOT ((';
  FOR i IN 1..p_column_lis.COUNT LOOP

    l_query_text := l_query_text || p_column_lis(i) || ',';

  END LOOP;

  l_query_text := RTrim(l_query_text, ',') || ') FOR per_tp IN (';

  FOR j IN 1..p_period_tps_lis.COUNT LOOP

    l_query_text := l_query_text || '(';
    FOR i IN 1..p_column_lis.COUNT LOOP

      l_query_text := l_query_text || p_column_lis(i) || CASE WHEN p_period_tps_lis(j) != 'cur' THEN '_' ||
       p_period_tps_lis(j) END || ',';

    END LOOP;
    l_query_text := RTrim(l_query_text, ',') || ') AS ''P' || j || ' - ' || p_period_tps_lis(j) || ''',';

  END LOOP;
  l_query_text := RTrim(l_query_text, ',') || '))';
  RETURN l_query_text;

END Period_Aggs_Macro;

END Period_Agg_Dynamic;
/
SHO ERR