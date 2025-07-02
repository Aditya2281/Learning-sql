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