# Student grade calculator
# reads student marks from csv file , it take file name manually (default student_input.csv)
# handles exceptions like filenotfounderror , valueerror
#calculates stats like total , average , highest , lowest , grade
#display report with name  , average , grade and pass/fail
#saves the report to .txt file having table and class summary

import csv
import json
import logging
logging.basicConfig(level=logging.INFO)
def load_students(filename):
    try:
        students=[]
        with open(filename , "r") as f:
            reader=csv.DictReader(f)
            for row in reader:
                if not row["Name"]:
                    logging.warning("malformed row is found")
                    continue
                row["Math"] = int(row["Math"])
                row["Science"] = int(row["Science"])
                row["English"] = int(row["English"])
                row["History"] = int(row["History"])
                row["PE"] = int(row["PE"])
                students.append(row)
        logging.info("file is loaded sucessfully")
        return students
    except FileNotFoundError:
        logging.error("file not found")
        return []
    except ValueError:
        logging.error("incorrect values in csv file")
        return []
    except KeyError:
        logging.error("values mismatched")
        return []


def calculate_stats(scores):
    try:
        total = sum(scores)
        average = total / len(scores)
        highest = max(scores)
        lowest = min(scores)
        if average >= 90:
            grade = "A"
        elif average >= 80:
            grade = "B"
        elif average >= 70:
            grade = "C"
        elif average >= 60:
            grade = "D"
        elif average>=40:
            grade="E"
        else:
            grade = "F"

        return total, average, highest, lowest, grade
    except : 
        print("no values in scores")
        return 0, 0, 0, 0, "N/A"

def display_report(students):
    print("name\taverage\tgrade\tpass/fail")
    for stu in students:
        if stu["Grade"] == "N/A":
            status = "N/A"
        elif stu["Average"]>=40:
            status="pass"
        else:
            status="Fail"
        print(
            f"{stu['Name']}\t"
            f"{stu['Average']:.2f}\t"
            f"{stu['Grade']}\t"
            f"{status}"
        )

def save_report(students , output_path):
    with open(output_path,"w") as f:
        f.write("name\taverage\tgrade\tpass/fail\n")
        for stu in students:
            if stu["Grade"] == "N/A":
                status = "N/A"
            elif stu["Average"]>=40:
                status="Pass"
            else:
                status="Fail"
            f.write(
                f"{stu['Name']}\t"
                f"{stu['Average']:.2f}\t"
                f"{stu['Grade']}\t"
                f"{status}\n"
            )
        total_students = len(students)
        total_average = 0

        for stu in students:
            total_average += stu["Average"]
        class_average = total_average / total_students
        f.write("\n")
        f.write("Class Summary\n")
        f.write(f"Total Students: {total_students}\n")
        f.write(f"Class Average: {class_average:.2f}\n")

def save_summary_json(students , output_path):
    total_students=len(students)
    if total_students==0:
        return
    total_average = sum(stu["Average"] for stu in students)
    class_average = total_average / total_students

    summary = {
        "total_students": total_students,
        "class_average": round(class_average, 2)
    }
    with open(output_path , "w") as f:
        json.dump(summary , f , indent =4)

def main():
    
    filename = input("Enter input file path (default: students_input.csv): ")

    if filename == "":
        filename = "students_input.csv"
    data=load_students(filename)
    if not data:
        return
    max_students = 30
    if len(data) > max_students:
        print(f"Warning: file contains {len(data)} students, but only the first {max_students} will be processed.")
        data = data[:max_students]
    for row in data:
        print(row)

    print("student stats")
    stats=[]
    for row in data:
        scores=[
            row["Math"],
            row["Science"],
            row["English"],
            row["History"],
            row["PE"]
        ]
        total, average, highest, lowest, grade = calculate_stats(scores)

        stats.append({
            "Name": row["Name"],
            "Total": total,
            "Average": average,
            "Highest": highest,
            "Lowest": lowest,
            "Grade": grade
        })
    for s in stats:
        print(s)

    print("student report:")
    display_report(stats)
    save_report(stats, "student_report.txt")
    save_summary_json(stats , "class_summary.json")

    

if __name__ == "__main__":
    main()
