layer = 3
row = 5
col=8
matrix=[]
for i in range(layer):
    l=[]
    for j in range(row):
        r=[]
        for k in range(col):
            r.append(0)
        l.append(r)
    matrix.append(l)
print(matrix)