import json
import os
import pandas as pd
import mysql.connector
from dotenv import load_dotenv

load_dotenv()

connection = mysql.connector.connect(
    host=os.getenv("DM_DB_HOST"),
    user=os.getenv("DM_DB_USER"),
    password=os.getenv("DM_DB_PASSWORD")
)

cursor = connection.cursor()

db_name = os.getenv("DM_DB_NAME")

cursor.execute(f"CREATE DATABASE IF NOT EXISTS {db_name}")
cursor.execute(f"USE {db_name}")

with open("sample_data_for_assignment.json", "r") as file:
    json_data = json.load(file)

cols = json_data["cols"]
data = json_data["data"]

cursor.execute("""
    CREATE TABLE IF NOT EXISTS json_to_sql_table (
        id INT,
        name VARCHAR(100),
        email VARCHAR(100),
        postalZip VARCHAR(50),
        phone VARCHAR(50)
    )
""")

cursor.execute("TRUNCATE TABLE json_to_sql_table")

cursor.executemany("""
    INSERT INTO json_to_sql_table
    (id, name, email, postalZip, phone)
    VALUES (%s, %s, %s, %s, %s)
""", data)

connection.commit()

df = pd.read_sql(
    "SELECT * FROM json_to_sql_table",
    connection
)

print("Original Data:")
print(df)


def change_email(email):
    return email.split("@")[0] + "@gmail.com"


df["email"] = df["email"].apply(change_email)


def convert_postal(value):
    numbers = "".join(
        char for char in str(value)
        if char.isdigit()
    )
    return int(numbers)


df["postalZip"] = df["postalZip"].apply(convert_postal)


def phone_to_ascii(phone):
    digits = "".join(
        char for char in str(phone)
        if char.isdigit()
    )

    result = ""

    for i in range(0, len(digits) - 1, 2):
        number = int(digits[i:i + 2])

        if number < 65:
            result += "O"
        else:
            result += chr(number)

    return result


df["phone"] = df["phone"].apply(phone_to_ascii)
df = df.rename(columns={"phone": "coded_phone_number"})

print("\nFinal Data:")
print(df)

cursor.close()
connection.close()