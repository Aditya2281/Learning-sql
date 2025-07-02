--Write a query that returns the user ID of all users that have created at least one ‘Refinance’ submission and at least one ‘InSchool’ submission.
SELECT
	USER_ID
FROM
	LOANS
WHERE
	TYPE = 'Refinance'
	OR TYPE = 'InSchool'
GROUP BY
	USER_ID
HAVING
	COUNT(DISTINCT TYPE) =2


---We have a table with employees and their salaries, however, some of the records are old and contain outdated salary information. Find the current salary of each employee assuming that salaries increase each year. 
--Output their id, first name, last name, department ID, and current salary. Order your list by employee ID in ascending order.
SELECT 
    id,
    first_name,
    last_name,
    department_id,
    salary
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY id ORDER BY salary DESC) AS rn
    FROM ms_employee_salary
) sub
WHERE rn = 1
ORDER BY id;