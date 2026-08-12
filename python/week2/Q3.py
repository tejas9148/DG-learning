# Topic: Decorators & Context Managers
#
# Implement the following two Python patterns:
# (a) Decorator @log_call: prints 'Calling <name>...' before and
#     'Done.' after. Apply to sum_to_n(n).
# (b) Decorator @retry(times=3): re-calls function up to 3 times
#     on Exception. Simulate random failure.
# (c) Custom context manager TempFile: creates file on __enter__,
#     deletes on __exit__. Write and read 3 lines.
# (d) Predict the output:
#     def double(func):
#         def wrapper(x):
#             return func(x) * 2
#         return wrapper
#
#     @double
#     def square(n):
#         return n * n
#
#     print(square(3))
#     print(square(5))
#--------------------------------------

# (a)  
from functools import wraps
import os
import random

def log_call(func):
    @wraps(func)
    def wrapper(*args,**kwargs):
        print(f"calling {func.__name__}...")
        result=func(*args,**kwargs)
        print("Done.")
        return result
    return wrapper
@log_call
def sum_to_n(n):
    return sum(range(1,n+1))

print(sum_to_n(5))
#-----------------------------------------

# (b) retry

def retry(times):
    def decorator(func):
        def wrapper(*args,**kwargs):
            for attempt in range(1,times+1):
                try:
                    return func(*args,**kwargs)
                except Exception:
                    print(f"attempt {attempt} failed")

        return wrapper
    return decorator

@retry(3)
def test():
    if random.random() < 0.5:
        raise Exception("failed")
    return "success"

print(test())

# (c) custom context manager
class tempfile:
    def __init__(self , filename):
        self.filename=filename
    def __enter__(self):
        self.file=open(self.filename,"w+")
        return self.file
    def __exit__(self,exc_type,exc_value,traceback):
        self.file.close()
        os.remove(self.filename)

with tempfile("temp.txt") as f:
    f.write("Line 1\n")
    f.write("Line 2\n")
    f.write("Line 3\n")
    f.seek(0)
    print(f.read())


#output
#predicted output
# 18
# 50
def double(func):
    def wrapper(x):
        return func(x)*2
    return wrapper
@double
def square(n):
    return n*n

print(square(3))
print(square(5))
#actual output
# 18
# 50
