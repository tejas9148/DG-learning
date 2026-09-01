#  Custom exceptions 

# Read: Why and when to define your own exception classes instead of relying only on built-in ones like ValueError. 
# Hands-on: Define one or two custom exception classes of your own (e.g., InvalidScoreError), and write a short standalone example that raises and catches them. 

class InvalidScoreError(Exception):
    pass

class InvalidGradeError(Exception):
    pass

def validate_score(score):
    if not isinstance(score , (int , float)):
        raise InvalidGradeError("score must be number")
    if score <0 or score >100:
        raise InvalidScoreError("score must be between 0 to 100")

    return "valid score"


try:
    score =105
    print(validate_score(score))
except InvalidScoreError as e :
    print("Error :" , e)

except InvalidGradeError as e :
    print("Error :", e)