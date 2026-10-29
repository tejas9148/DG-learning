from marshmallow import Schema, fields, validate

from app.schemas.common import date_field, money, text, whole_number

ORDER_STATUS_IDS = [0, 1, 2, 3]   # New, Invoiced, Shipped, Closed
TAX_STATUS_IDS = [0, 1]           # Tax Exempt, Taxable


class OrderItemSchema(Schema):
    product_id = fields.Int(required=True, strict=True, validate=validate.Range(min=1))
    quantity = fields.Float(required=True, validate=validate.Range(min=0, min_inclusive=False))
    unit_price = fields.Float(validate=validate.Range(min=0))      # defaults to the product's list price
    discount = fields.Float(validate=validate.Range(min=0, max=1))  # 0.1 means 10 percent


class OrderSchema(Schema):
    customer_id = fields.Int(required=True, strict=True, validate=validate.Range(min=1))
    items = fields.List(fields.Nested(OrderItemSchema), required=True, validate=validate.Length(min=1))
    employee_id = whole_number()
    order_date = date_field()
    shipped_date = date_field()
    shipper_id = whole_number()
    ship_name = text(50)
    ship_address = text(255)
    ship_city = text(50)
    ship_state_province = text(50)
    ship_zip_postal_code = text(50)
    ship_country_region = text(50)
    shipping_fee = money()
    taxes = money()
    payment_type = text(50)
    paid_date = date_field()
    notes = text(1000)
    tax_rate = fields.Float(validate=validate.Range(min=0, max=100), allow_none=True)
    tax_status_id = fields.Int(strict=True, validate=validate.OneOf(TAX_STATUS_IDS), allow_none=True)
    status_id = fields.Int(strict=True, validate=validate.OneOf(ORDER_STATUS_IDS), allow_none=True)
