
# Build the student_tracker package with full file structure: 

# (a) Directory layout: student_tracker/ with models.py, database.py, reports.py, __init__.py, and main.py. 
# (b) In models.py, define a Student dataclass with name (str), scores (list[float]), and property average -> float. 
# (c) In __init__.py, expose Student and load_students(filepath: str) -> list[Student] reading from JSON. 
# (d) In main.py, import and use load_students(), print each student's name and average with proper error handling. 
# (e) Predict the output: from dataclasses import dataclass from typing import List @dataclass class Student:     name: str     scores: List[float]     @property     def average(self): return sum(self.scores)/len(self.scores) s = Student('Ravi', [80, 90, 70, 85]) print(s.name, round(s.average, 1), isinstance(s, Student)) 

# (e)
# predict output:
# Ravi 81.2  True
from dataclasses import dataclass 
from typing import List 
@dataclass 
class Student:     
    name: str     
    scores: List[float]     
    @property     
    def average(self): 
        return sum(self.scores)/len(self.scores) 
s = Student('Ravi', [80, 90, 70, 85]) 
print(s.name, round(s.average, 1), isinstance(s, Student)) 

# actual output
# Ravi 81.2 True