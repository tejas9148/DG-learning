def calculate_grade(score , total=100 , passing=50):
    
    if score < 0 or score > total:
        raise ValueError

    percentage = (score/total)*100

    if percentage>=90:
        return (percentage, 'A')
    elif percentage>=75:
        return (percentage , 'B')
    elif percentage>=60:
        return (percentage , 'C')
    elif percentage>=passing:
        return (percentage , 'D')
    else:
        return (percentage , 'F')
    
    

print(calculate_grade(95))
print(calculate_grade(80))
print(calculate_grade(55))
try:
    print(calculate_grade(-5))
except ValueError:
    print("invalid score")



#output
def grade(s,t=100 , p=50):
    pct=(s/t)*100
    return 'Pass' if pct>=p else 'Fail'
print(grade(45))
print(grade(60, 150)) 
print(grade(80, p=90))