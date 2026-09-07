from .models import Student

def print_student_report(students : list[Student])->None:
    for stu in students:
        print(f"{stu.name}:{stu.average:.2f}")