# Oracle SQL Projects / period_agg_reporting
This project has the code and other artefacts for small SQL projects, including mp4 recordings that explain the project.

## period_agg_report_queries
The period_agg_reporting subproject has the scripts and artefacts for a blog post, [SQL for Period Aggregate Reporting](http://aprogrammerwrites.eu/?p=3006). I also explain the post in a tweet recording (< 2m20s).

Recording                      | SQL Script                    | Tweet
-------------------------------|-------------------------------|------
Period Aggregate Reporting.mp4 | period_agg_report_queries.sql | [Tweet](https://twitter.com/BrenPatF/status/)

## Running the Scripts
This subproject creates its own test data on an Oracle database of at least v11.2, in any schema where the appropriate privileges are available. The execution plans are generated using wrapper functions from the GitHub project [Oracle PL/SQL general utilities module](https://github.com/BrenPatF/oracle_plsql_utils), but you can run the scripts and ignore the execution plan failures if this is not installed.
### [Schema: lib; Folder: period_agg_report_queries]

- Run script from sqlplus to create the example table with test data:
```
SQL> @c_sales_history
```
- Run script from sqlplus to run the queries:
```
SQL> @period_agg_report_queries
```