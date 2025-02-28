CREATE TABLE departments (
    dept_id INT,
    department_name STRING,
    location STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

LOAD DATA INPATH '/user/hive/warehouse/department/departments.csv' INTO TABLE departments;

CREATE TABLE temp_employees (
    emp_id INT,
    name STRING,
    age INT,
    job_role STRING,
    salary DOUBLE,
    project STRING,
    join_date STRING,
    department STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

LOAD DATA INPATH '/user/hive/warehouse/employees/employees.csv' INTO TABLE temp_employees;

CREATE TABLE employees (
    emp_id INT,
    name STRING,
    age INT,
    job_role STRING,
    salary DOUBLE,
    project STRING,
    join_date STRING
)
PARTITIONED BY (department STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS PARQUET;

SET hive.exec.dynamic.partition.mode=nonstrict;
INSERT INTO TABLE employees PARTITION (department)
SELECT emp_id, name, age, job_role, salary, project, join_date, department FROM temp_employees;

SELECT * FROM employees WHERE year(join_date) > 2015;

SELECT department, AVG(salary) AS avg_salary FROM employees GROUP BY department;

SELECT * FROM employees WHERE project = 'Alpha';

SELECT job_role, COUNT(*) AS count FROM employees GROUP BY job_role;

SELECT e.* FROM employees e
JOIN (
    SELECT department, AVG(salary) AS avg_salary FROM employees GROUP BY department
) d ON e.department = d.department
WHERE e.salary > d.avg_salary;

SELECT department, COUNT(*) AS emp_count FROM employees GROUP BY department ORDER BY emp_count DESC LIMIT 1;

SELECT * FROM employees WHERE emp_id IS NOT NULL AND name IS NOT NULL;

SELECT e.*, d.location FROM employees e JOIN departments d ON e.department = d.department_name;

SELECT emp_id, name, salary, department,
       RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS rank
FROM employees;

SELECT * FROM (
    SELECT emp_id, name, salary, department,
           RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS rank
    FROM employees
) ranked WHERE rank <= 3;