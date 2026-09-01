#  sqlite3 - a lightweight built-in database 

# Read: Python's built-in sqlite3 module - connecting to a local .db file, creating a table, and running INSERT/SELECT statements. No server setup needed. 
# Hands-on: Write a short new script that creates a small table (e.g., name, score), inserts a few sample rows, then queries and prints them back. 

import sqlite3

connection = sqlite3.connect("student.db")
cursor = connection.cursor()

cursor.execute( """
      create table if not exists students ( name int , score integer)
""")

students = [("tejas",90),("rahul",80),("shiva",50)]

cursor.executemany("insert into students (name , score) values (?,?)" , students)
#save changes
connection.commit()
cursor.execute("select * from students")

rows= cursor.fetchall()
for name , marks in rows:
    print("Name:",name, "score",marks)
connection.close()
