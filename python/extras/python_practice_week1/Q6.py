
def generate(n):
    for i in range(1,n+1):
        if i%7==0 and i%5==0:
            yield str(i)
       

n= int(input("enter the number"))
print(",".join(generate(n)))