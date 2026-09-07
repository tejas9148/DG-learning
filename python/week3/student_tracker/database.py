import json 
from .models import Student

def load_students(filepath:str)->list[Student]:
    with open(filepath , "r") as file:
        data=json.load(file)
    return [
        Student(
            name=item["name"],
            scores=item["scores"]
        )
        for item in data
    ]