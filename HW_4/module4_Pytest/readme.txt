Instructions for executing DB tests:

1. in 'configuration_DB.py' change DB parameters to your local ones
2. go to the terminal
3. execute 'pip install -r requirements.txt' to install the required packages
4. execute the command 'cd DB_Testing' to move from the current directory to the directory of the Pytest file
5. execute 'py.test -v -s' for running the tests
6. execute 'pytest --html=report.html' for generating test report
7. go to location module4_Pytest\DB_Testing
8. open 'report.html' with any available browser to check the test report