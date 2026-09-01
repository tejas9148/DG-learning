# 6. Enum - naming fixed sets of values 

# Read: Why plain strings for fixed categories (like grade labels or status flags) can be error-prone, and how Python's enum.Enum helps. 
# Hands-on: Define a small Enum for a fixed set of labels of your choice (e.g., grade categories or a status flag), and use it in a short standalone example instead of plain strings.

from enum import Enum
class OrderStatus(Enum):
    PENDING="pending"
    PROCESSING = "processing"
    SHIPPED = "shipped"
    DELIVERED = "delivered"

order_status = OrderStatus.SHIPPED

print("Current status:", order_status)
print("Status value:", order_status.value)

if order_status == OrderStatus.SHIPPED:
    print("Your order has been shipped")


# Assigning a value using the Enum class

order_status = OrderStatus("shipped")
print("\nStatus from value:", order_status)


# Trying to assign an invalid value
try:
    order_status = OrderStatus("abc")
    print(order_status)
except ValueError as e:
    print("\nError:", e)


# Trying another invalid value
try:
    order_status = OrderStatus("cancelled")
    print(order_status)
except ValueError as e:
    print("Error:", e)


# Comparing a string with an Enum member
order_status = "shipped"

print("\nString status:", order_status)
print(OrderStatus.SHIPPED)
print(order_status)
if order_status == OrderStatus.SHIPPED:
    print("Order shipped")
else:
    print("String and Enum member are different")