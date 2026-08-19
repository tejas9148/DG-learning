
# You have calculator.py with add(a,b), subtract(a,b), multiply(a,b), divide(a,b). Write test_calculator.py containing: 

# (a) A fixture named sample_values providing {a, b, expected_sum}. 
# (b) A basic test test_add_positive() using the fixture. 
# (c) A parametrized test test_multiply with at least 4 combinations. 
# (d) pytest.raises to confirm divide(10,0) raises ZeroDivisionError. Edge case: divide(0,5) returns 0.0. 
# (e) Predict the output: def divide(a, b):     if b == 0: raise ZeroDivisionError('Cannot divide by zero')     return a / b try:     print(divide(10, 2))     print(divide(5, 0)) except ZeroDivisionError as e:     print(f'Caught: {e}') 

import pytest
from calculator import add , subtract , multiply , divide

# (a)
@pytest.fixture
def sample_values():
    return {
        "a":10,
        "b":5,
        "expected_value":15
    }

# (b)
def test_add_positive(sample_values):
    assert add(sample_values["a"],sample_values["b"])==sample_values["expected_value"]

# (c)
@pytest.mark.parametrize("a,b,excepted",[(2,3,6),(5,4,20),(0,10,0),(-2,5,-10)])

def test_multiply(a,b,excepted):
    assert multiply(a,b)==excepted

# (d)
def test_divide_by_zero():
    with pytest.raises(ZeroDivisionError):
        divide (10,0)

def test_divide_zero():
    assert divide(0,5)==0.0


# (e)
#predict output
# 5.0
# Caught:Cannot divide by zero
def divide(a, b):     
    if b == 0: raise ZeroDivisionError('Cannot divide by zero')     
    return a / b 
try:     
    print(divide(10, 2))     
    print(divide(5, 0)) 
except ZeroDivisionError as e:     
    print(f'Caught: {e}')

#actual output
#5.0
#Caught: Cannot divide by zero