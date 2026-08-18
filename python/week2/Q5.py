# Topic: Modules, Packages & Virtual Environments

# (a) Commands to: create virtual environment plp_env,
# activate it, install pandas and requests,

# (b) File structure for package 'gradebook' with
# student.py and report.py. Write __init__.py exposing
# Student and generate_report().

# gradebook/
# ├── __init__.py
# ├── student.py
# └── report.py

# student.py:
#
# class Student:
#     def __init__(self, name):
#         self.name = name

# __init__.py:
#
# from .student import Student
# from .report import generate_report

# (c) In report.py, write generate_report(students: list).
# Import and use from top-level main.py

#(d) Predict the output: # student.py: class Student:    
#  def __init__(self, name): self.name = name # main.py: from gradebook import Student s = Student('Priya') print(s.name, type(s).__name__, isinstance(s, Student)) 
#---------------------------------------------------------
#ANSWER
# (a)
#commands to create virtual environment
#   1: python -m venv plp_env
#   2: plp_env\Scripts\activate

#commands to install pandas 
#    1:pip install pandas requests

#commands to export requirements.txt
#    1:pip freeze > requirements.txt
#--------------------------------------------------------------

# (b) , (c) student and generate report
from gradebook import Student , generate_report

students = [
    Student("groot"),
    Student("Rahul"),
    Student("Tejas")
]
generate_report(students)
#----------------------------------------------------------

# (d)
#output
#pridected :
#  Priya Student  True
s = Student('Priya') 
print(s.name, type(s).__name__, isinstance(s, Student))

#Actual output:
#  Priya Student True