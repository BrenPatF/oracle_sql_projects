@..\initspool analytics
BREAK ON department_id
PROMPT Average by Grouping
SELECT department_id, AVG(salary) avg_salary
  FROM employees
 GROUP BY department_id
 ORDER BY department_id
/
L
PROMPT 
PROMPT Analytic Averages: Overall, running and 3-point moving
SELECT department_id, employee_id, salary,
       AVG(salary) OVER (PARTITION BY department_id) avg_salary,
       AVG(salary) OVER (PARTITION BY department_id ORDER BY employee_id) run_avg_salary,
       AVG(salary) OVER (PARTITION BY department_id ORDER BY employee_id
       		ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) moving_avg_salary_3
  FROM employees
 ORDER BY department_id, employee_id
/
L
PROMPT 
PROMPT Analytics on Grouping: Running sum of the department average salaries
SELECT department_id, AVG(salary) avg_salary,
       SUM(AVG(salary)) OVER (ORDER BY department_id) run_sum_avg_salary
  FROM employees
 GROUP BY department_id
 ORDER BY department_id
/
L
@..\endspool