class reverseorder:
    def __init__(self , data):
        self.data=data
        self.index=len(data)-1

    def __iter__(self):
        return self

    def __next__(self):
        if self.index<0:
            raise StopIteration
        value = self.data[self.index]
        self.index-=1
        return value
        
numbers = [10 , 20 , 30 , 40 ,50]

for num in reverseorder(numbers):
    print(num)