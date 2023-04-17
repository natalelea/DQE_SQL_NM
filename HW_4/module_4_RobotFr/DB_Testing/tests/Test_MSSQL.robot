*** Settings ***
Suite Setup  Connect To Database Using Custom Params    pymssql    host=${DBHost}, port=${DBPort}, user=${DBUser}, password=${DBPass}, database=${DBName}
Suite Teardown    Disconnect From Database
Library  DatabaseLibrary

*** Variables ***
${DBHost}         'EPUALVIW08B4\\SQLEXPRESS01'
${DBPort}         '1433'
${DBName}         'TRN'
${DBPass}         '123Password!'
${DBUser}         'TestLogin'

*** Test Cases ***
Check Max Salary Value
    [Documentation]
    ...  | Name: Verifying if salary range is eligible
    ...  | Steps: 1. Getting maximum value of [salary] column from [hr].[employees]
    ...  |        2. Comparing if the result value is in expected range which is less then 50K
    ...  | Expected result: 24000.00
    ${output} =    Query    SELECT max([salary]) FROM [TRN].[hr].[employees]
    Log  ${output}
    Should Be Equal As Strings    ${output}    [(Decimal('24000.00'),)]

Check Duplicates - Employees tbl
    [Documentation]
    ...  | Name: Verifying duplicates by employee's name are not present in employees table
    ...  | Steps: 1. Getting values of the columns [first_name],[last_name] from [hr].[employees] table
    ...  |           that are present in table more that once
    ...  |        2. Checking if the result set is empty
    ...  | Expected result: No records are returned
    Row Count Is 0   SELECT [first_name],[last_name] FROM [TRN].[hr].[employees] GROUP BY [first_name],[last_name] HAVING COUNT(*) > 1

Check Count for Managers
    [Documentation]
    ...  | Name: Verifying count of job titles containing 'Manager' in the name
    ...  | Steps: 1. Getting count of rows from [hr].[jobs] table which have any Manager [job_title] value
    ...  |        2. Checking if the result value equals to expected count
    ...  | Expected result: 6
    ${output} =    Query    SELECT COUNT(*) FROM [TRN].[hr].[jobs] WHERE job_title like '%Manager%';
    Log    ${output}
    Should Be Equal As Strings    ${output}    [(6,)]

Check Country Values
    [Documentation]
    ...  | Name: Verifying countries from locations table
    ...  | Steps: 1. Getting unique values of [country_id] column from [hr].[locations] table
    ...  |        2. Checking if the result set equals to expected list of values
    ...  | Expected result: 'CA', 'DE', 'UK', 'US'
    ${output} =    Query    SELECT DISTINCT [country_id] FROM [TRN].[hr].[locations] ORDER BY [country_id]
    Log Many   ${output}
    Should Be Equal As Strings    ${output}     	[('CA',), ('DE',), ('UK',), ('US',)]

Check Duplicates - Departments tbl
    [Documentation]
    ...  | Name: Verifying count of unique names for departments
    ...  | Steps: 1. Getting count of non-empty values of [department_name] column from [hr].[departments] table
    ...  |        2. Getting count of unique values of [department_name] column from [hr].[departments] table
    ...  |        3. Checking if count of unique departments' values in the departments table
    ...  |           is equal to general count of departments' values
    ...  | Expected result: Counts are equal
    ${output} =    Query    SELECT COUNT([department_name]) as cnt_all, COUNT(distinct department_name) as cnt_unq FROM [TRN].[hr].[departments]
    Log Many   ${output}
    Should Be Equal As Strings    ${output[0][0]}     ${output[0][1]}

Check Average Salary Value
    [Documentation]
    ...  | Name: Verifying average salary value for employees having Steven King for manager
    ...  | Steps: 1. Getting records from [TRN].[hr].[employees] table where manager for current
    ...  |           employee is Steven King
    ...  |        2. Getting average value of the [salary] column for data from the returned set
    ...  |        3. Checking if the result value is equal to expected value
    ...  | Expected result: 10450.00
    ${output} =    Query    SELECT AVG([salary]) as avg_salary FROM [TRN].[hr].[employees] WHERE [manager_id] = (SELECT [employee_id] FROM [TRN].[hr].[employees] WHERE [first_name] = 'Steven' and [last_name] = 'King')
    Log  ${output}
    Should Be Equal As Strings    ${output}     	[(Decimal('10450.000000'),)]