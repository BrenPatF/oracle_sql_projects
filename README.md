# Oracle SQL Projects
<img src="mountains.png">
This project has the code and other artefacts for small SQL projects, including mp4 recordings that explain the project.

:file_cabinet: :question: :outbox_tray:

## In this README...
[&darr; Subprojects](#subprojects)<br />
[&darr; Installation](#installation)<br />
[&darr; Running the Scripts](#running-the-scripts)<br />
[&darr; See Also](#see-also)

## Subprojects
[&uarr; In this README...](#in-this-readme)<br />
[&darr; sums_products](#sums_products)<br />
[&darr; analytics_and_recursion_explainers](#analytics_and_recursion_explainers)<br />
[&darr; period_agg_reporting](#period_agg_reporting)

### sums_products
[&uarr; Subprojects](#subprojects)

The sums_products subproject has the scripts and artefacts for a blog post, [A Note on Running Sums and Products in SQL](http://aprogrammerwrites.eu/?p=2679). I explain the post in a tweet recording (< 2m20s), followed up by three further tweets explaining the SQL techniques more generally (the latter are in the analytics_and_recursion_explainers subproject).

- [Blog: A Note on Running Sums and Products in SQL](http://aprogrammerwrites.eu/?p=2679)
- [Tweet](https://twitter.com/BrenPatF/status/1219149845505683459)
- [README: sums_products](sums_products/README.md)

### analytics_and_recursion_explainers
[&uarr; Subprojects](#subprojects)

The analytics_and_recursion_explainers subproject has the scripts and artefacts for a Twitter thread in which I explain how three SQL techniques work, in a single tweet recording (< 2m20s) each.

- [Blog: Analytic and Recursive SQL by Example](http://aprogrammerwrites.eu/?p=2702)
- [Twitter Thread](https://twitter.com/BrenPatF/status/1228610471391113216)
- [README: analytics_and_recursion_explainers](analytics_and_recursion_explainers/README.md)

### period_agg_reporting
[&uarr; Subprojects](#subprojects)

The period_agg_reporting subproject has the scripts and artefacts for a Twitter thread in which I explain three SQL queries for doing rolling aggregates over multiple time periods, in a single tweet recording (< 2m20s) each.

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

- [Blog: SQL for Period Aggregate Reporting](https://brenpatf.github.io/jekyll/update/2021/11/14/2021-11-14-sql-for-period-aggregate-reporting.html)
- [Twitter Thread](https://twitter.com/BrenPatF/status/)
- [README: period_agg_reporting](period_agg_reporting/README.md)

## Installation
[&uarr; In this README...](#in-this-readme)<br />
[&darr; Install prerequisite tools](#install-prerequisite-tools)<br />
[&darr; Install prerequisite module](#install-prerequisite-module)<br />

The project code consists of SQL query scripts that can be run from sqlplus as long as the pre-requisites are in place.

### Install prerequisite tools
[&uarr; Installation](#installation)

#### Oracle database with HR demo schema
The database installation requires a minimum Oracle version of 11.2, with Oracle's HR demo schema installed (first two subprojects only) [Oracle Database Software Downloads](https://www.oracle.com/database/technologies/oracle-database-software-downloads.html).

If HR demo schema is not installed, it can be got from here: [Oracle Database Sample Schemas](https://docs.oracle.com/cd/E11882_01/server.112/e10831/installation.htm#COMSC001).

### Install prerequisite module
[&uarr; Installation](#installation)

The install of the period_agg_reporting subproject depends on the prerequisite module Utils.

The prerequisite module can be installed by following the instructions for the module at the module root page listed in the `See Also` section below. This allows inclusion of the examples and unit tests for the module. Alternatively, the next section shows how to install the module directly without the examples or unit tests.

#### [Schema: sys; Folder: install_prereq] Create lib and app schemas
- Run script from slqplus:

```
SQL> @install_sys
```

#### [Schema: lib; Folder: install_prereq\lib] Create lib components
- Run script from sqlplus:

```
SQL> @install_utils app
```

#### [Schema: app; Folder: install_prereq\app] Create app synonyms
- Run script from slqplus:

```
SQL> @c_utils_syns lib
```

## Running the Scripts
[&uarr; In this README...](#in-this-readme)

See the subproject READMEs:
- [README: sums_products](sums_products/README.md)
- [README: analytics_and_recursion_explainers](analytics_and_recursion_explainers/README.md)
- [README: period_agg_reporting](period_agg_reporting/README.md)

## Operating System/Oracle Versions
### Windows
Windows 10/11
### Oracle
Oracle Database Version 21.3.0.0.0 (all except SQL macro function in the period_agg_reporting subproject should work back to v11.2)

## See Also
[&uarr; In this README...](#in-this-readme)<br />
- [Utils - Oracle PL/SQL general utilities module](https://github.com/BrenPatF/oracle_plsql_utils)

## License
MIT
