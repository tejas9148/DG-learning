my_list = [12,24,35,24,88,120,155,88,120,155]
seen = set()
unique=[]
for num in my_list:
    if num not in seen:
        seen.add(num)
        unique.append(num)
print(unique)