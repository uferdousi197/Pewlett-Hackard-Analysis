-- creating tables for PH-EmployeeDB

CREATE TABLE departments(
	dept_no VARCHAR(4) NOT NULL, 
	dept_name VARCHAR(40) NOT NULL,
	PRIMARY KEY(dept_no),
	UNIQUE (dept_name)
);

CREATE TABLE employees (
	emp_no INT NOT NULL,
	birth_date DATE NOT NULL,
	first_name VARCHAR NOT NULL,
	last_name VARCHAR NOT NULL,
	genger VARCHAR NOT NULL,
	hire_date DATE NOT NULL,
	PRIMARY KEY (emp_no)
);

CREATE TABLE dept_manager (
	dept_no VARCHAR(4) NOT NULL,
	emp_no INT NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES employees(emp_no),
	FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
	PRIMARY KEY (emp_no, dept_no)
);

CREATE TABLE salaries (
    emp_no INT NOT NULL,
    salary INT NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES Employees (emp_no),
	PRIMARY KEY (emp_no)
);

CREATE TABLE titles (
	emp_no INT NOT NULL,
	title VARCHAR(50) NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	PRIMARY KEY (emp_no, title, from_date)
);


CREATE TABLE dept_employee(
	emp_no INT NOT NULL,
	dept_no VARCHAR NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
	PRIMARY KEY (emp_no, dept_no)
);


-- use SELECT query to confirm tables creation
SELECT * FROM departments;
SELECT * FROM employees;
SELECT * FROM dept_manager;
SELECT * FROM dept_employee;
SELECT * FROM titles;
SELECT * FROM salaries;

--Retirement Eligibility
SELECT emp_no, birth_date, first_name, last_name, gender, hire_date
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

--Current Retirement Eligibility 

SELECT r.emp_no, r.first_name, r.last_name,d.dept_no, d.to_date
INTO current_emp
FROM retirement_info AS r
LEFT JOIN dept_employee AS d
ON r.emp_no = d.emp_no
WHERE d.to_date = '9999-01-01';

--Number of title Retiring

SELECT DISTINCT ON(ce.emp_no)ce.emp_no AS Employee_number,ce.first_name, ce.last_name, 
    t.title AS Title, t.from_date, s.salary AS Salary
INTO retirement_titles
FROM current_emp AS ce
INNER JOIN titles AS t ON ce.emp_no = t.emp_no
INNER JOIN salaries AS s ON ce.emp_no = s.emp_no;

SELECT * FROM retirement_titles

-- Most recent title
SELECT employee_number, first_name, last_name, title, from_date, salary
INTO unique_titles
FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY (cei.employee_number, cei.first_name, cei.last_name)
                ORDER BY cei.from_date DESC) AS emp_row_number
      FROM retirement_titles AS cei) AS unique_employee	  
WHERE emp_row_number =1;

SELECT * FROM unique_titles

-- Frequency of retiring employee titles 
SELECT *, count(ct.Employee_number) 
		OVER (PARTITION BY ct.title ORDER BY ct.from_date DESC) AS emp_count
INTO retiring_titles
FROM unique_titles AS ct;
-- get total count per title group
SELECT COUNT(employee_number), title
FROM retiring_titles
GROUP BY title;


-- eleigible for mentor program
SELECT DISTINCT ON(em.emp_no) em.emp_no, em.first_name, em.last_name, 
    t.title AS Title, t.from_date, t.to_date
INTO mentorship_eligibilty
FROM Employees AS em
INNER JOIN titles AS t ON em.emp_no = t.emp_no
INNER JOIN dept_employee AS d ON em.emp_no = d.emp_no
WHERE (em.birth_date BETWEEN '1965-01-01' AND '1965-12-31')
AND (d.to_date = '9999-01-01');

SELECT * FROM mentorship_eligibilty



