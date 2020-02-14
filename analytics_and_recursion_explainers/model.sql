@..\initspool model
BREAK ON department_id
PROMPT Running and Final Products: Final first rule, default SEQUENTIAL order
WITH multipliers AS (
SELECT department_id, employee_id, salary, (1 + salary/10000) mult, 
       COUNT(*) OVER (PARTITION BY department_id) n_emps
  FROM employees
)
SELECT department_id, employee_id, salary, mult, running_prod, final_prod
  FROM multipliers
 MODEL
 	PARTITION BY (department_id)
 	DIMENSION BY (Row_Number() OVER (PARTITION BY department_id 
 		                             ORDER BY employee_id) rn)
 	MEASURES (employee_id, salary, mult, mult running_prod, mult final_prod, n_emps)
 	RULES (
 		final_prod[any] = running_prod[n_emps[CV()]],
 		running_prod[rn > 1] = mult[CV()] * running_prod[CV() - 1]
 	)
 ORDER BY department_id, employee_id
/
L
PROMPT
PROMPT Running and Final Products: Final first rule, AUTOMATIC order
WITH multipliers AS (
SELECT department_id, employee_id, salary, (1 + salary/10000) mult, 
       COUNT(*) OVER (PARTITION BY department_id) n_emps
  FROM employees
)
SELECT department_id, employee_id, salary, mult, running_prod, final_prod
  FROM multipliers
 MODEL
 	PARTITION BY (department_id)
 	DIMENSION BY (Row_Number() OVER (PARTITION BY department_id 
 		                             ORDER BY employee_id) rn)
 	MEASURES (employee_id, salary, mult, mult running_prod, mult final_prod, n_emps)
 	RULES AUTOMATIC ORDER (
 		final_prod[any] = running_prod[n_emps[CV()]],
 		running_prod[rn > 1] = mult[CV()] * running_prod[CV() - 1]
 	)
 ORDER BY department_id, employee_id
/
L
PROMPT
PROMPT Average and Moving Average
SELECT department_id, employee_id, salary, avg_salary, moving_avg_salary_3
  FROM employees
 MODEL
 	PARTITION BY (department_id)
 	DIMENSION BY (Row_Number() OVER (PARTITION BY department_id 
 		                             ORDER BY employee_id) rn)
 	MEASURES (employee_id, salary, salary avg_salary, salary moving_avg_salary_3)
 	RULES (
 		avg_salary[ANY] = AVG(salary)[ANY],
 		moving_avg_salary_3[ANY] = AVG(salary)[rn BETWEEN CV()-2 AND CV()]
 	)
 ORDER BY department_id, employee_id
/
L
PROMPT
PROMPT UPSERT with FOR Loop: Split records into two with salary halved
SELECT department_id, employee_id, old_salary, split_salary
  FROM employees
 MODEL
 	PARTITION BY (department_id)
 	DIMENSION BY (Row_Number() OVER (PARTITION BY department_id 
 		                             ORDER BY employee_id) rn)
 	MEASURES (employee_id, salary old_salary, salary split_salary, 
 		      Count(*) OVER (PARTITION BY department_id) as n_emps)
 	RULES UPSERT (
 		employee_id[FOR rn FROM n_emps[1]+1 TO 2*n_emps[1] INCREMENT 1] = 
 		   employee_id[CV() - n_emps[1]],
 		split_salary[FOR rn FROM n_emps[1]+1 TO 2*n_emps[1] INCREMENT 1] = 
 		   old_salary[CV() - n_emps[1]],
 		split_salary[ANY] = 0.5 * split_salary[CV()]
 	)
 ORDER BY department_id, employee_id
/
L
PROMPT
PROMPT ITERATE: Take square root of salary iteratively until average < 10 
SELECT department_id, employee_id, salary, avg_salary
  FROM employees
 MODEL
 	PARTITION BY (department_id)
 	DIMENSION BY (Row_Number() OVER (PARTITION BY department_id ORDER BY employee_id) rn)
 	MEASURES (employee_id, salary, salary avg_salary, salary moving_avg_salary_3)
 	RULES ITERATE (100) UNTIL avg_salary[1] < 10.0 (
        salary[ANY] = SQRT(salary[CV()]),
 		avg_salary[ANY] = AVG(salary)[ANY]
 	)
 ORDER BY department_id, employee_id
/
L
PROMPT
PROMPT Within-Rule Order Default Ascending: Set salary = previous salary
SELECT department_id, employee_id, old_salary, salary
  FROM employees
 MODEL
 	PARTITION BY (department_id)
 	DIMENSION BY (Row_Number() OVER (PARTITION BY department_id ORDER BY employee_id) rn)
 	MEASURES (employee_id, salary old_salary, salary)
 	RULES (
 		salary[rn > 1] = salary[CV()-1]
 	)
 ORDER BY department_id, employee_id
/
L
PROMPT
PROMPT Within-Rule Order Descending: Set salary = previous salary
SELECT department_id, employee_id, old_salary, salary
  FROM employees
 MODEL
 	PARTITION BY (department_id)
 	DIMENSION BY (Row_Number() OVER (PARTITION BY department_id ORDER BY employee_id) rn)
 	MEASURES (employee_id, salary old_salary, salary)
 	RULES (
 		salary[rn > 1] ORDER BY rn DESC = salary[CV()-1]
 	)
 ORDER BY department_id, employee_id
/
L
@..\endspool