#email split 
email=input("enter the email")
username , domain = email.split("@")
company = domain.split(".")[0]
print(company)
print(username)