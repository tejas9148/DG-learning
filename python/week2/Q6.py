# Topic: Exception Patterns & Clean Code
# Refactor:
# def f(x,y):
#     try:
#         return x/y
#     except:
#         pass
# (a) Rename parameters, add a proper docstring (Args + Returns + Raises).
# (b) Handle ZeroDivisionError and TypeError separately with specific messages.
# (c) Add type hints: (dividend: float, divisor: float) -> Optional[float].
# (d) Write batch_divide(pairs: list[tuple]) calling safe_divide,
#     skipping failures, logging warnings.
# (e) Predict the output:
# from typing import Optional
# def safe_divide(a: float, b: float) -> Optional[float]:
#     try:
#         return a / b
#     except ZeroDivisionError:
#         print('Zero error')
#         return None
# results = [safe_divide(10,2), safe_divide(6,0), safe_divide(9,3)]
# print(results)

def f(x,y):
    try :
        return x/y
    except Exception as e:
        pass
#------------------------------------------------------------------

#refactored code 
#(a),(b),(c) 
import logging 
from typing import Optional
logging.basicConfig(level=logging.WARNING)

def safe_divide(dividend : float , divisor : float )->Optional[float]:
    """
    Divide dividend by divisor.

    Args:
        dividend: The number to be divided.
        divisor: The number to divide by.

    Returns:
        The division result, or None if division fails.

    Raises:
        ZeroDivisionError: If divisor is zero.
        TypeError: If the arguments are not valid for division.
    """  
    try:
        return dividend/divisor
    except ZeroDivisionError:
        logging.warning("Cannot divide by zero")
        return None
    except TypeError:
        logging.warning("Dividend and divisor must be numbers")
        return None
#---------------------------------------------------------------

#(d) batch divide
def batch_divide(pairs:list[tuple]):
    results=[]
    for dividend , divisor in pairs:
        result=safe_divide(dividend,divisor)
        if result is not None:
            results.append(result)
    return results

pairs = [(10,2),(6,0),(9,3),("10",2)]
print("batch results:",batch_divide(pairs))
#---------------------------------------------------------------

# (e)  predict the output
# predicted :
#            so when 6,0 takes as input it raises the exception so exception is handled first and then the result is displayed and return None and for other inputs the result is calculated and stored in results
#     output :: zero error
#               [5.0 , None , 3.0]

def predict_safe_divide(a: float, b: float) -> Optional[float]:
    try:
        return a / b

    except ZeroDivisionError:
        print("Zero error")
        return None


results = [
    predict_safe_divide(10, 2),
    predict_safe_divide(6, 0),
    predict_safe_divide(9, 3)
]

print(results)

#actual output
# Zero error 
# [5.0 , None , 3.0]