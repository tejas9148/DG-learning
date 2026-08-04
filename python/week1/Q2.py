marks = [85, 92, 78, 92, 88, 78, 95, 88, 70, 92]

#remove duplicates using set
unique_marks = set(marks)
print(unique_marks)

#count the number of students for unique marks
dict_marks={}
for num in marks:
    if num not in dict_marks:
        dict_marks[num]=1
    else:
        dict_marks[num]+=1
print(dict_marks)

#sort in ascending
sorted_dict = dict(sorted(dict_marks.items()))
print(sorted_dict)

#tuple
t_marks = (
    min(marks),
    max(marks),
    len(marks)
)
print(t_marks)

#output
nums=[4,7,4,2,7,9]
unique = set(nums)
counts = {n:nums.count(n) for n in unique}
print(sorted(counts.items()))