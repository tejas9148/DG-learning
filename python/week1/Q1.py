name = input("Enter your name : ")
age = input ("Enter your age : ")

#convert age to int and calculate the year of birth
age_int = int(age)
current_year = 2025
year_born = current_year - age_int
print(year_born)

#age is even or odd
if age_int % 2==0:
    print("Even")
else:
    print("Odd")

#Age as float
res = float(age_int)/80
print(f"{res:.4f}")

#type()
print(type(name))
print(type(age))
print(type(age_int))

#output
x='15'
y=int(x)
z=float(y)/4
print(type(x).__name__ , y*2 , round(z,2) , y%2==0)

