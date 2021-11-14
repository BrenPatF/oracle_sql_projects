# Oracle SQL Projects / period_agg_reporting
This project has the code and other artefacts for small SQL projects, including mp4 recordings that explain the project.

## period_agg_report_queries
The period_agg_reporting subproject has the scripts and artefacts for a blog post, [SQL for Period Aggregate Reporting](https://brenpatf.github.io/jekyll/update/2021/11/14/2021-11-14-sql-for-period-aggregate-reporting.html). I also explain the post in two tweet recordings (< 2m20s each).

Recording                      | SQL Script                    | Tweet
-------------------------------|-------------------------------|------
Period Aggregate Reporting.mp4 | period_agg_report_queries.sql | [Tweet](https://twitter.com/BrenPatF/status/1366062116264955912)

The requirement here is to provide reports on sales performance aggregated across multiple time periods, for each product and month. The output for a single month and product with two measures might look like this:

```
Month       Product    Period             Value     Cost
----------- ---------- --------------- -------- --------
01-Nov-2020 PROD_ONE   P1 - 1 Month       4,585      137
                       P2 - 3 Months      7,436    1,016
                       P3 - YTD          56,181    5,407
                       P4 - 1 Year       58,894    6,289
```

We have given three queries in static SQL with varying performance characteristics illustrated by their execution plans. These queries assume a fixed list of periods and measures.

We go on to provide two dynamic SQL queries for the required report, using PL/SQL functions of type:
- Pipelined function
- SQL macro

These allow for parametrization of the period list and (SQL macro only) the measures list.

## Running the Scripts
This subproject creates its own test data on an Oracle database of at least v11.2, in any schema where the appropriate privileges are available. The fifth query uses a SQL macro, a feature available from Oracle database v19.6. 

The execution plans are generated using wrapper functions from the GitHub project [Oracle PL/SQL general utilities module](https://github.com/BrenPatF/oracle_plsql_utils), which can be installed following the Installation instructions in the project root [README](../../../#installation).

### [Schema: app; Folder: period_agg_report_queries]

- Run script from sqlplus to create the example table with test data, and the PL/SQL package:
```
SQL> @install_period_agg_reporting
```
- Run script from sqlplus to run the queries:
```
SQL> @period_agg_report_queries
```