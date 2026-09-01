#  re - regular expressions, just the basics 

# Read: What a regular expression is, and common patterns for matching digits, letters, and simple formats (re.match, re.search, re.fullmatch). 
# Hands-on: Write a short script with a handful of sample strings, and check each one against a simple pattern of your choice (e.g., a basic email-like format) using re.match.

import re 
emails = [
    "tejas@gmail.com",
    "john123@yahoo.com",
    "hello@test.in",
    "invalid-email",
    "@gmail.com",
    "test@gmail",
    "abc@gmail.com"
]
pattern = r"^\w+@\w+\.\w{3}$"
for email in emails:
    result = re.match(pattern , email)
    if result:
        print(email , "valid")
    else :
        print(email , "invalid")
        
sql_statements = [
    "CREATE TABLE users (id INT, name VARCHAR(50));",
    "CREATE TABLE IF NOT EXISTS employees (id INT, name VARCHAR(50));"
]

pattern = r"CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?(\w+)"

for statement in sql_statements:
    result = re.search(pattern, statement, re.IGNORECASE)

    if result:
        print("Full match :", result.group(0))
        print("Table name :", result.group(1))
    else:
        print("No table found")