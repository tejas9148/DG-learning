from student_tracker import load_students


def main():
    try:
        students = load_students("students.json")

        for student in students:
            print(f"{student.name}: {student.average:.2f}")

    except FileNotFoundError:
        print("Error: students.json file not found.")

    except ValueError as error:
        print(f"Error: {error}")

    except Exception as error:
        print(f"Unexpected error: {error}")


if __name__ == "__main__":
    main()