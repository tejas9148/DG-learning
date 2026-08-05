def safe_divide(a,b):
    try:
        result=a/b
        print(result)
    except ZeroDivisionError:
        print("cannot be divided by zero")
    except TypeError:
        print("invalid value to divide")


#file not found

def read_student_file(filename):
    try:
        with open(filename,"r") as f:
            f.read()
    except FileNotFoundError:
        print("file not found")
    finally:
        print("file operation complete")

def main():
    safe_divide(10,2)
    safe_divide(10,0)
    safe_divide(10,"abc")
    read_student_file("read.txt")
    read_student_file("student.txt")

main()


#output
def safe_div(a,b):
    try:
        return a/b
    except ZeroDivisionError:
        return "Zero!"
    finally:
        print("done")
print(safe_div(10,2))
print(safe_div(5,0))