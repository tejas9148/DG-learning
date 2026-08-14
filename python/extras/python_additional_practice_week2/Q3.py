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
