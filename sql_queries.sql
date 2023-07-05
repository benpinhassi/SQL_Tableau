/*
In this file, we are executing 4 different queries.
Each query result is then exported to CSV file for uploading to Tableau Public.
Please ensure that you have set up the database using the 'sample_employee_database' before using this file.
*/

USE employees_mod;

/* 
Query 1
Male and female employees working in the company each year, starting from 1990.
*/
SELECT 
    YEAR(de.from_date) AS calender_year,
    e.gender,
    COUNT(e.gender) AS num_of_employees
FROM
    t_employees e
        JOIN
    t_dept_emp de ON e.emp_no = de.emp_no
WHERE
    YEAR(de.from_date) > 1989
GROUP BY gender , YEAR(de.from_date)
ORDER BY YEAR(de.from_date) , e.gender;

/* 
Query 2
Number of female and male managers from different departments for each year.
*/
SELECT 
    d.dept_name,
    ee.gender,
    dm.emp_no,
    dm.from_date,
    dm.to_date,
    e.calendar_year,
    CASE
        WHEN
            YEAR(dm.to_date) >= e.calendar_year
                AND YEAR(dm.from_date) <= e.calendar_year
        THEN
            1
        ELSE 0
    END AS active
FROM
    (SELECT 
        YEAR(hire_date) AS calendar_year
    FROM
        t_employees
    GROUP BY calendar_year) e
        CROSS JOIN
    t_dept_manager dm
        JOIN
    t_employees ee ON dm.emp_no = ee.emp_no
        JOIN
    t_departments d ON dm.dept_no = d.dept_no
ORDER BY dm.emp_no , calendar_year;

/* 
Query 3
Average salary of female versus male employees per each department until year 2002.
*/
SELECT 
    YEAR(s.from_date) AS salary_year,
    e.gender,
    t_departments.dept_name,
    AVG(s.salary) AS average_salary
FROM
    t_salaries s
        JOIN
    t_employees e ON e.emp_no = s.emp_no
        JOIN
    t_dept_emp ON t_dept_emp.emp_no = s.emp_no
        JOIN
    t_departments ON t_departments.dept_no = t_dept_emp.dept_no
WHERE
    YEAR(s.from_date) <= 2002
GROUP BY YEAR(s.from_date) , e.gender , t_departments.dept_name
ORDER BY t_departments.dept_name DESC , e.gender , YEAR(s.from_date);
    
/* 
Query 4
Stored procedure: Average male and female salary per department within a certain salary range.
*/
DELIMITER $$ 
CREATE PROCEDURE salary_dept_age( IN salary_from FLOAT, IN salary_to FLOAT)
BEGIN
SELECT 
	t_departments.dept_name,
    e.gender,
    AVG(s.salary) AS average_salary
FROM
	t_salaries s
		JOIN 
	t_employees e ON e.emp_no = s.emp_no
		JOIN 
	t_dept_emp ON t_dept_emp.emp_no = s.emp_no
		JOIN 
	t_departments ON t_departments.dept_no = t_dept_emp.dept_no
WHERE (YEAR(s.from_date) <= YEAR(SYSDATE()) AND YEAR(SYSDATE()) <= YEAR(s.to_date))
	AND
	(salary_from <= s.salary AND s.salary <= salary_to)
GROUP BY t_departments.dept_name, e.gender
ORDER BY t_departments.dept_name, e.gender;
END $$
DELIMITER ;
    
CALL salary_dept_age(50000, 90000);   

