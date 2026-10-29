from pynamodb.attributes import BooleanAttribute, NumberAttribute, UnicodeAttribute
from pynamodb.models import Model

from app.config import Config


class ProductModel(Model):
    """One item in the products DynamoDB table."""

    class Meta:
        table_name = Config.PRODUCTS_TABLE
        region = Config.AWS_REGION

    id = NumberAttribute(hash_key=True)
    product_code = UnicodeAttribute(null=True)
    product_name = UnicodeAttribute(null=True)
    description = UnicodeAttribute(null=True)
    standard_cost = NumberAttribute(null=True)
    list_price = NumberAttribute(null=True)
    reorder_level = NumberAttribute(null=True)
    target_level = NumberAttribute(null=True)
    quantity_per_unit = UnicodeAttribute(null=True)
    discontinued = BooleanAttribute(null=True)
    minimum_reorder_quantity = NumberAttribute(null=True)
    category = UnicodeAttribute(null=True)
    supplier_ids = UnicodeAttribute(null=True)
