import mysql.connector

connection = mysql.connector.connect(
    host="localhost",
    user="root",
    password = "password",
    database="test_db"
)

c=connection.cursor()
c.execute("select * from employees;")

def employee_generator(c):
    while True:
        row = c.fetchone()
        if row is None:
            break
        yield row

for emp in employee_generator(c):
    print(emp)