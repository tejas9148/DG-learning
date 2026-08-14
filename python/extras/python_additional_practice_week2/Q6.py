from enum import Enum
class OrderStatus(Enum):
    PENDING="pending"
    PROCESSING = "processing"
    SHIPPED = "shipped"
    DELIVERED = "delivered"

order_status = OrderStatus.SHIPPED

print("current status :" , order_status.value)
if order_status == OrderStatus.SHIPPED:
    print("your order has been shipped")