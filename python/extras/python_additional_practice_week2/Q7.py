#  functools - partial and lru_cache 

# Read: The basics of functools.partial (pre-filling some arguments of a function) and functools.lru_cache (caching a function's results). 
# Hands-on: Write a short script demonstrating both: use partial to create a specialised version of a simple function, and lru_cache to cache results of a small slow-ish function (e.g., a manual Fibonacci). 

from functools import partial, lru_cache

# PART 1: partial

def multiply(a, b):
    return a * b

multiply_by_10 = partial(multiply, 10)

print("Partial:")
print(multiply_by_10(5))
print(multiply_by_10(8))


# PART 2: lru_cache

@lru_cache
def fibonacci(n):
    if n <= 1:
        return n

    return fibonacci(n - 1) + fibonacci(n - 2)

print("\nFibonacci:")
print(fibonacci(10))

print("\nCache information:")
print(fibonacci.cache_info())