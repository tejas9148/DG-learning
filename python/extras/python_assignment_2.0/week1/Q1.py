import os
import mysql.connector
from dotenv import load_dotenv

load_dotenv()

connection = mysql.connector.connect(
    host=os.getenv("LD_DB_HOST"),
    user=os.getenv("LD_DB_USER"),
    password=os.getenv("LD_DB_PASSWORD"),
    database=os.getenv("LD_DB_NAME")
)

cursor = connection.cursor()

def employee_generator(cursor, batch_size=1000):
    cursor.execute("""
        SELECT emp_no, first_name, last_name, gender, hire_date
        FROM employees
    """)

    while True:
        rows = cursor.fetchmany(batch_size)

        if not rows:
            break

        for row in rows:
            yield row


count = 0

for employee in employee_generator(cursor):
    if count < 10:
        print(employee)
    count += 1

print("Total rows:", count)


cursor.close()
connection.close()