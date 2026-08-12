# Topic: OOP: Classes, __init__, Inheritance & Polymorphism

# Build a class hierarchy for a library system:
# (a) Base class LibraryItem: title, author, year, describe() method.
# (b) Subclass Book: add pages and genre, override describe().
# (c) Subclass Magazine: add issue_number and is_monthly, override describe().
# (d) Create a list with one Book and one Magazine, loop and call
#     describe() -- demonstrate polymorphism.
# (e) Predict the output:
# class Animal:
#     def __init__(self, name):
#         self.name = name
#
#     def speak(self):
#         return f'{self.name} speaks'
#
# class Dog(Animal):
#     def speak(self):
#         return f'{self.name} says Woof!'
#
# for a in [Animal('Cat'), Dog('Rex')]:
#     print(a.speak())
#-------------------------------------------

# (a) library item
class libraryitem:
    def __init__(self , title , author , year):
        self.title=title
        self.author = author
        self.year = year
    def describe(self):
        print( f"{self.title} by {self.author} in {self.year}")
# (b) subclass book
class book(libraryitem):
    def __init__(self,title,author,year,pages,genre):
        super().__init__(title,author,year)
        self.pages=pages
        self.genre=genre
    def describe(self):
        print(f"{self.title} by {self.author} in {self.year} {self.pages} pages , genre:{self.genre}")
# (c) subclass magazine
class magazine(libraryitem):
    def __init__(self , title ,author,year,issue_number , is_monthly):
        super().__init__(title,author,year)
        self.issue_number=issue_number
        self.is_monthly=is_monthly
    def describe(self):
        print(f"{self.title} by {self.author} in {self.year}, issue: {self.issue_number}, monthly: {self.is_monthly}")
#base class
item =libraryitem("python","nikki",2024)
item.describe()
#sub class book
item1=book("python","nikki",2024,20,"adventure")
item1.describe()
#sub class mazagine
item2=magazine("python","nikki",2024,42,True)
item2.describe()
# (d) list of book and magazine
items=[item1,item2]
for i in items:
    i.describe()

# (e) predict output:
 # Cat speaks
 # Rex says Woof!
class Animal:
    def __init__(self, name):
        self.name = name

    def speak(self):
        return f'{self.name} speaks'


class Dog(Animal):
    def speak(self):
        return f'{self.name} says Woof!'


for a in [Animal('Cat'), Dog('Rex')]:
    print(a.speak())

#actual output
# Cat speaks
# Rex says Woof!