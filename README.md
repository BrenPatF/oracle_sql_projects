# Oracle SQL Projects
This project has the code and other artefacts for small SQL projects, including mp4 recordings that explain the project.

## sums_products

[A Note on Running Sums and Products in SQL](http://aprogrammerwrites.eu/?p=2679)
[Tweet](https://twitter.com/BrenPatF/status/1219149845505683459)

Recording                     | SQL Script
------------------------------|------------------
Running Sums and Products.mp4 | sums_products.sql

## analytics_and_recursion_explainers

[Analytic and Recursive SQL by Example](http://aprogrammerwrites.eu/?p=2702)

[Twitter Thread](https://twitter.com/BrenPatF/status/1228210581108191233)

### Analytic Functions

Recording     | SQL Script    | Tweet
--------------|---------------|----------------------------------
Analytics.mp4 | analytics.sql | [SQL Analytic Functions in a Tweet](https://twitter.com/BrenPatF/status/1228210581108191233)

### Model Clause

Recording     | SQL Script
--------------|--------------
Model.mp4     | model.sql

### Recursive Subquery Factors

Recording     | SQL Script
--------------|--------------
RSF.mp4       | rsf.sql

Here's a query structure diagram for the final recursive query:
<img src="analytics_and_recursion_explainers\RSF-QSD.png">

and a diagram showing partitioning and flow through the iterations for same:
<img src="analytics_and_recursion_explainers\RSF-Recursion.png">

## Installation
### Install 1: Install pre-requisite tools
#### Oracle database with HR demo schema
The database installation requires a minimum Oracle version of 11.2, with Oracle's HR demo schema installed [Oracle Database Software Downloads](https://www.oracle.com/database/technologies/oracle-database-software-downloads.html).

If HR demo schema is not installed, it can be got from here: [Oracle Database Sample Schemas](https://docs.oracle.com/cd/E11882_01/server.112/e10831/installation.htm#COMSC001).

### Install 2: Run scripts
#### [Schema: hr; Folder: analytics_and_recursion_explainers]

- Run scripts from slqplus:
```
SQL> @analytics
SQL> @model
SQL> @rsf
```

## Operating System/Oracle Versions
### Windows
Windows 10
### Oracle
Oracle Database Version 19.3.0.0.0

## License
MIT
