from flask import Blueprint

from app.models import CustomerModel
from app.schemas.customer_schema import CustomerSchema
from app.utils.db import get_or_404, next_id, save_new
from app.utils.validation import load_json
from app.views.responses import render_item, render_list

bp = Blueprint("customers", __name__, url_prefix="/customers")
schema = CustomerSchema()


@bp.get("")
def list_customers():
    customers = sorted(CustomerModel.scan(), key=lambda c: c.id)
    return render_list(customers)


@bp.get("/<int:customer_id>")
def get_customer(customer_id):
    return render_item(get_or_404(CustomerModel, customer_id, "Customer"))


@bp.post("")
def create_customer():
    data = load_json(schema)
    customer = CustomerModel(id=next_id(CustomerModel), **data)
    save_new(customer)
    return render_item(customer, 201)


@bp.put("/<int:customer_id>")
def update_customer(customer_id):
    data = load_json(schema, partial=True)
    customer = get_or_404(CustomerModel, customer_id, "Customer")
    for field, value in data.items():
        setattr(customer, field, value)
    customer.save()
    return render_item(customer)
