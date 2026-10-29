from marshmallow import Schema, fields, validate

from app.schemas.common import money, text, whole_number


class ProductSchema(Schema):
    product_code = fields.Str(required=True, validate=validate.Length(min=1, max=25))
    product_name = fields.Str(required=True, validate=validate.Length(min=1, max=50))
    list_price = fields.Float(required=True, validate=validate.Range(min=0))
    description = text(1000)
    standard_cost = money()
    reorder_level = whole_number()
    target_level = whole_number()
    quantity_per_unit = text(50)
    discontinued = fields.Boolean(allow_none=True)
    minimum_reorder_quantity = whole_number()
    category = text(50)
    supplier_ids = text(50)
