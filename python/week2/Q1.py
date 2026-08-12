numbers = [3, 7, 12, 19, 24, 31, 40, 47, 56, 63]
result = [x*x for x in numbers if x%2!=0]
print(result)

div_by_four= list(filter(lambda x :x%4==0 , numbers))
print(div_by_four)

padded_zero= list(map(lambda x: str(x).zfill(3), numbers))
print(padded_zero)

odd_or_even = {n:'even' if n%2==0 else "odd" for n in numbers}
print(odd_or_even)

#pridect output
# [1,9,25] [2,4,6] ['001','002','003']
nums = [1, 2, 3, 4, 5, 6]

odd_sq = [x**2 for x in nums if x % 2 != 0]

div2 = list(
    filter(lambda x: x % 2 == 0, nums)
)

padded = list(
    map(lambda x: str(x).zfill(3), nums[:3])
)

print(odd_sq, div2, padded)