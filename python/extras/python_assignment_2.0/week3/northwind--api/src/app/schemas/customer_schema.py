from marshmallow import Schema, fields, validate

from app.schemas.common import text


class CustomerSchema(Schema):
    company = fields.Str(required=True, validate=validate.Length(min=1, max=50))
    last_name = text(50)
    first_name = text(50)
    email_address = fields.Email(allow_none=True)
    job_title = text(50)
    business_phone = text(25)
    home_phone = text(25)
    mobile_phone = text(25)
    fax_number = text(25)
    address = text(255)
    city = text(50)
    state_province = text(50)
    zip_postal_code = text(15)
    country_region = text(50)
    web_page = text(255)
    notes = text(1000)
