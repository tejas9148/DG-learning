import mysql.connector
import os
from dotenv import load_dotenv

load_dotenv()

connection = mysql.connector.connect(
    host=os.environ["DB_HOST"],
    user=os.environ["DB_USER"],
    password=os.environ["DB_PASSWORD"],
    database=os.environ["DB_NAME"]
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