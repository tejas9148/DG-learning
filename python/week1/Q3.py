#Fibinacci
a=0
b=1
i=0
while(i<15):
    if a>1000:
        break
    print(a)
    if a<10:
        print("small")
    elif a<100:
        print("medium")
    else:
        print("large")
    temp=a+b 
    a=b
    b=temp
    i+=1
    
#Table
num = 7
for i in range(1,6):
    print(num,"x",i,"=",num*i)

#output
result=[]
for i in range(1,6):
    if i%2==0:
        result.append(i*i)
print(result)
x=10
while x>0:
    x-=3
    print(x)
