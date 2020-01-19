@..\initspool sums_products
PROMPT Sums
SELECT department_id, employee_id, salary,
       SUM(salary) OVER (PARTITION BY department_id ORDER BY employee_id) running_sum,
       SUM(salary) OVER (PARTITION BY department_id) total_sum
  FROM employees
-- WHERE department_id = 60
 ORDER BY department_id, employee_id
/
PROMPT Products
SELECT department_id, employee_id, salary, (1 + salary/10000) mult,
       EXP(SUM(LN((1 + salary/10000))) OVER (PARTITION BY department_id ORDER BY employee_id)) running_prod,
       EXP(SUM(LN((1 + salary/10000))) OVER (PARTITION BY department_id)) total_prod
  FROM employees
-- WHERE department_id = 60
 ORDER BY department_id, employee_id
/
PROMPT Products using MODEL Clause
WITH multipliers AS (
SELECT department_id, employee_id, salary, (1 + salary/10000) mult, 
       COUNT(*) OVER (PARTITION BY department_id) n_emps
  FROM employees
-- WHERE department_id = 60
)
SELECT department_id, employee_id, salary, mult, running_prod, total_prod
  FROM multipliers
 MODEL
 	PARTITION BY (department_id)
 	DIMENSION BY (Row_Number() OVER (PARTITION BY department_id ORDER BY employee_id) rn)
 	MEASURES (employee_id, salary, mult, mult running_prod, mult total_prod, n_emps)
 	RULES (
 		running_prod[rn > 1] = mult[CV()] * running_prod[CV() - 1],
 		total_prod[any] = running_prod[n_emps[CV()]]
 	)
 ORDER BY department_id, employee_id
/
PROMPT Products using Recursive Subquery Factors
WITH multipliers AS (
SELECT department_id, employee_id, salary, (1 + salary/10000) mult, 
       Row_Number() OVER (PARTITION BY department_id ORDER BY employee_id) rn,
       COUNT(*) OVER (PARTITION BY department_id) n_emps
  FROM employees
-- WHERE department_id = 60
), rsf (department_id, employee_id, rn, salary, mult, running_prod) AS (
	SELECT department_id, employee_id, rn, salary, mult, mult running_prod
	  FROM multipliers
	 WHERE rn = 1
	UNION ALL
	SELECT m.department_id, m.employee_id, m.rn, m.salary, m.mult, r.running_prod * m.mult
	  FROM rsf r
	  JOIN multipliers m
	    ON m.rn = r.rn + 1
	   AND m.department_id = r.department_id
)
SELECT department_id, employee_id, salary, mult, running_prod, 
       Last_Value(running_prod) OVER (PARTITION BY department_id) total_prod
  FROM rsf
 ORDER BY department_id, employee_id
/
@..\endspool