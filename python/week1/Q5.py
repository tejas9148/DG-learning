file=open("student.txt","r")
total=0
count=0
highest=0
highest_name =""
for line in file:
    name,marks=line.split(",")
    print(name.upper(),marks)
    total+=int(marks)
    count+=1
    if int(marks)>highest:
        highest=int(marks)
        highest_name=name
avg=total/count
print("avg" ,total/count )
print(f"{highest} {highest_name}")
file.close()
f = open("student.txt", "a")
summary = f"Class Average: {avg:.1f} | Total Students: {count}"
f.write("\n" + summary.title().strip())
f.close()
#output
data = 'Alice,85\nBob,92\nCarol,78' 
lines = data.strip().split('\n') 
scores = [int(l.split(',')[1]) for l in lines] 
print(max(scores), round(sum(scores)/len(scores), 1))