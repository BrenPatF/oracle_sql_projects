@..\initspool c_sales_history
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
EXEC DBMS_Stats.Gather_Table_Stats (ownname => 'LIB', tabname => 'sales_history')
COMMIT
/
@..\endspool