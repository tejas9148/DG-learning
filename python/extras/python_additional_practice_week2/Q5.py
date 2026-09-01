#  itertools - a few handy building blocks 

# Read: The basics of itertools.groupby, itertools.chain, and itertools.count, and what problems they're typically used for. 
# Hands-on: Write a short script with any small sample list of your own, and use itertools.groupby to group items by some property (e.g., group numbers by odd/even). 
import itertools

numbers=[1,2,3,4,5,6]
#sort numbers because group by groups the consicutive similar elements

numbers.sort(key = lambda x:x%2)
groups = itertools.groupby(numbers , key = lambda x:x%2)

for key , group in groups:
    if key ==1:
        print("odd : " , list(group))
    else :
        print("Even : " , list(group))