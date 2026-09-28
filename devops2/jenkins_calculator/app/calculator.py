def add(a, b):
    return a + b


def subtract(a, b):
    return a - b


def multiply(a, b):
    return a * b


def lambda_handler(event, context):
    operation = event.get("operation")
    a = event.get("a")
    b = event.get("b")

    if operation == "add":
        result = add(a, b)
    elif operation == "subtract":
        result = subtract(a, b)
    elif operation == "multiply":
        result = multiply(a, b)
    else:
        raise ValueError("Invalid operation")

    return {
        "statusCode": 200,
        "body": {
            "operation": operation,
            "result": result
        }
    }