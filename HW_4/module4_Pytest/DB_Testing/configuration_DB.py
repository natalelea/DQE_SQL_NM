import pypyodbc as odbc

DRIVER_NAME = 'SQL SERVER'
SERVER_NAME = 'EPUALVIW08B4\\SQLEXPRESS01'
DATABASE_NAME = 'TRN'
UID = 'TestLogin'
PWD = '123Password!'

connection = odbc.connect(f"DRIVER={DRIVER_NAME};"
                          f"Server={SERVER_NAME};"
                          f"User Id={UID};"
                          f"Password={PWD};"
                          f"Database={DATABASE_NAME}")
