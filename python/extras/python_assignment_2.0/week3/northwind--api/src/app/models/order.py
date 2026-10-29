from pynamodb.attributes import ListAttribute, MapAttribute, NumberAttribute, UnicodeAttribute
from pynamodb.indexes import AllProjection, GlobalSecondaryIndex
from pynamodb.models import Model

from app.config import Config


class OrderItem(MapAttribute):
    """One product line inside an order (this replaces the order_details table)."""

    product_id = NumberAttribute()
    quantity = NumberAttribute()
    unit_price = NumberAttribute()
    discount = NumberAttribute(default=0)


class CustomerIndex(GlobalSecondaryIndex):
    """Lets us fetch all orders of one customer (order history) without a table scan."""

    class Meta:
        index_name = "customer_id-index"
        projection = AllProjection()

    customer_id = NumberAttribute(hash_key=True)


class OrderModel(Model):
    """One item in the orders DynamoDB table."""

    class Meta:
        table_name = Config.ORDERS_TABLE
        region = Config.AWS_REGION

    id = NumberAttribute(hash_key=True)
    customer_id = NumberAttribute(null=True)
    employee_id = NumberAttribute(null=True)
    order_date = UnicodeAttribute(null=True)
    shipped_date = UnicodeAttribute(null=True)
    shipper_id = NumberAttribute(null=True)
    ship_name = UnicodeAttribute(null=True)
    ship_address = UnicodeAttribute(null=True)
    ship_city = UnicodeAttribute(null=True)
    ship_state_province = UnicodeAttribute(null=True)
    ship_zip_postal_code = UnicodeAttribute(null=True)
    ship_country_region = UnicodeAttribute(null=True)
    shipping_fee = NumberAttribute(null=True)
    taxes = NumberAttribute(null=True)
    payment_type = UnicodeAttribute(null=True)
    paid_date = UnicodeAttribute(null=True)
    notes = UnicodeAttribute(null=True)
    tax_rate = NumberAttribute(null=True)
    tax_status_id = NumberAttribute(null=True)
    status_id = NumberAttribute(null=True)
    items = ListAttribute(of=OrderItem, null=True)

    customer_index = CustomerIndex()
