@..\initspool rsf
BREAK ON department_id
COLUMN LAST_NAME FORMAT A20
PROMPT Employee Tree: Connect By
WITH cby AS (
    SELECT last_name, employee_id, manager_id, LEVEL lvl
      FROM employees
     START WITH employee_id = 100
     CONNECT BY PRIOR employee_id = manager_id
     ORDER SIBLINGS BY last_name
)
SELECT employee_id,
       LPad('.', 3*(lvl - 1), '.') || last_name last_name,
       manager_id,
       lvl
  FROM cby
/
L
PROMPT
PROMPT Employee Tree: Recursive subquery factors, depth first
WITH rsf(employee_id, last_name, manager_id, lvl) AS (
    SELECT employee_id,
           last_name,
           manager_id,
           1 lvl
      FROM employees
     WHERE manager_id IS NULL
    UNION ALL
    SELECT e.employee_id,
           e.last_name,
           e.manager_id,
           r.lvl + 1
      FROM rsf r
      JOIN employees e ON e.manager_id = r.employee_id
) SEARCH DEPTH FIRST BY last_name SET ord_by
SELECT employee_id,
       LPad('.', 3*(lvl - 1), '.') || last_name last_name,
       manager_id,
       lvl
  FROM rsf
 ORDER BY ord_by
/
L
PROMPT
PROMPT Employee Tree: Recursive subquery factors, breadth first
WITH rsf(employee_id, last_name, manager_id, lvl) AS (
    SELECT employee_id,
           last_name,
           manager_id,
           1 lvl
      FROM employees
     WHERE manager_id IS NULL
    UNION ALL
    SELECT e.employee_id,
           e.last_name,
           e.manager_id,
           r.lvl + 1
      FROM rsf r
      JOIN employees e ON e.manager_id = r.employee_id
) SEARCH BREADTH FIRST BY last_name SET ord_by
SELECT employee_id,
       LPad('.', 3*(lvl - 1), '.') || last_name last_name,
       manager_id,
       lvl
  FROM rsf
 ORDER BY ord_by
/
L
PROMPT
PROMPT Products using Recursive Subquery Factors: Passing through expressions
WITH multipliers AS (
SELECT department_id, employee_id, salary, (1 + salary/10000) mult, 
       Row_Number() OVER (PARTITION BY department_id ORDER BY employee_id) rn
  FROM employees
), rsf (department_id, employee_id, rn, salary, mult, running_prod, lvl) AS (
    SELECT department_id, employee_id, rn, salary, mult,
          mult running_prod, 1 lvl
      FROM multipliers
     WHERE rn = 1
    UNION ALL
    SELECT m.department_id, m.employee_id, m.rn, m.salary, m.mult,
           r.running_prod * m.mult, r.lvl + 1
      FROM rsf r
      JOIN multipliers m
        ON m.rn = r.rn + 1
       AND m.department_id = r.department_id
)
SELECT department_id, employee_id, salary, mult, running_prod, lvl
  FROM rsf
 ORDER BY department_id, employee_id
/
L
@..\endspool