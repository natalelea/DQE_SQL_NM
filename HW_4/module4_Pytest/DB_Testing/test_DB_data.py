import pytest
from configuration_DB import connection
cursor = connection.cursor()


def test_check_max_salary_value():
    """
    Name: Verifying if salary range is eligible
    Steps: 1. Getting maximum value of [salary] column from [hr].[employees]
           2. Comparing if the result value is in expected range which is less then 50K
    Expected result: True
    """
    cursor.execute(f""" SELECT max([salary])
                        FROM [TRN].[hr].[employees] """)
    row = cursor.fetchone()
    result = row[0]
    assert result < 50000


def test_check_duplicates_employees_tbl():
    """
    Name: Verifying duplicates by employee's name are not present in employees table
    Steps: 1. Getting values of the columns [first_name],[last_name] from [hr].[employees] table
              that are present in table more that once
           2. Checking if the result set is empty
    Expected result: None
    """
    cursor.execute(f""" SELECT [first_name],[last_name]
                        FROM [TRN].[hr].[employees]
                        GROUP BY [first_name],[last_name]
                        HAVING COUNT(*) > 1 """)
    result = cursor.fetchone()
    assert result is None


def test_check_count_for_manager():
    """
    Name: Verifying count of job titles containing 'Manager' in the name
    Steps: 1. Getting count of rows from [hr].[jobs] table which have any Manager [job_title] value
           2. Checking if the result value equals to expected count
    Expected result: 6
    """
    cursor.execute(f""" SELECT COUNT(*)
                        FROM [TRN].[hr].[jobs]
                        WHERE job_title like '%Manager%' """)
    row = cursor.fetchone()
    result = row[0]
    assert result == 6


def test_check_country_values():
    """
    Name: Verifying countries from locations table
    Steps: 1. Getting unique values of [country_id] column from [hr].[locations] table
           2. Checking if the result set equals to expected list of values
    Expected result: 'CA', 'DE', 'UK', 'US'
    """
    cursor.execute(f""" SELECT DISTINCT [country_id]
                        FROM [TRN].[hr].[locations]
                        ORDER BY [country_id] """)
    rows = cursor.fetchall()
    result_list = []
    for row in rows:
        result_list.append(row[0])
    assert result_list == ['CA', 'DE', 'UK', 'US']


def test_check_duplicates_departments_tbl():
    """
    Name: Verifying count of unique names for departments
    Steps: 1. Getting count of non-empty values of [department_name] column from [hr].[departments] table
           2. Getting count of unique values of [department_name] column from [hr].[departments] table
           3. Checking if count of unique departments' values in the departments table
              is equal to general count of departments' values
    Expected result: True
    """
    cursor.execute(f""" SELECT COUNT([department_name]) as cnt_all, 
                               COUNT(distinct department_name) as cnt_unq
                        FROM [TRN].[hr].[departments] """)
    row = cursor.fetchone()
    assert row[0] == row[1]


def test_check_avg_salary_value():
    """
    Name: Verifying average salary value for employees having Steven King for manager
    Steps: 1. Getting records from [TRN].[hr].[employees] table where manager for current
              employee is Steven King
           2. Getting average value of the [salary] column for data from the returned set
           3. Checking if the result value is in the range [10000; 11000]
    Expected result: True
    """
    cursor.execute(f""" SELECT AVG([salary]) as avg_salary
                        FROM [TRN].[hr].[employees]
                        WHERE [manager_id] = (
                                SELECT [employee_id] 
                                FROM [TRN].[hr].[employees]
                                WHERE [first_name] = 'Steven'
                                and [last_name] = 'King') """)
    row = cursor.fetchone()
    result = row[0]
    assert (10000 <= result <= 11000)
