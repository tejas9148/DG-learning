from datetime import datetime, timezone

from flask import Blueprint
from pynamodb.exceptions import DoesNotExist

from app.models import CustomerModel, OrderItem, OrderModel, ProductModel
from app.schemas.order_schema import OrderSchema
from app.utils.db import get_or_404, next_id, save_new
from app.utils.errors import ApiError
from app.utils.validation import load_json
from app.views.responses import render_item, render_list

bp = Blueprint("orders", __name__)
schema = OrderSchema()


def check_customer_exists(customer_id):
    try:
        CustomerModel.get(customer_id)
    except DoesNotExist:
        raise ApiError(f"Customer {customer_id} does not exist", 400)


def build_items(items):
    """Checks every product exists and fills in the price from the product if not sent."""
    order_items = []
    for item in items:
        try:
            product = ProductModel.get(item["product_id"])
        except DoesNotExist:
            raise ApiError(f"Product {item['product_id']} does not exist", 400)
        order_items.append(OrderItem(
            product_id=item["product_id"],
            quantity=item["quantity"],
            unit_price=item.get("unit_price", product.list_price),
            discount=item.get("discount", 0),
        ))
    return order_items


@bp.get("/orders")
def list_orders():
    orders = sorted(OrderModel.scan(), key=lambda o: o.id)
    return render_list(orders)


@bp.get("/orders/<int:order_id>")
def get_order(order_id):
    return render_item(get_or_404(OrderModel, order_id, "Order"))


@bp.post("/orders")
def create_order():
    data = load_json(schema)
    check_customer_exists(data["customer_id"])
    data["items"] = build_items(data["items"])
    data.setdefault("order_date", datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S"))
    data.setdefault("status_id", 0)   # 0 = New

    order = OrderModel(id=next_id(OrderModel), **data)
    save_new(order)
    return render_item(order, 201)


@bp.put("/orders/<int:order_id>")
def update_order(order_id):
    data = load_json(schema, partial=True)
    order = get_or_404(OrderModel, order_id, "Order")

    if "customer_id" in data:
        check_customer_exists(data["customer_id"])
    if "items" in data:
        data["items"] = build_items(data["items"])

    for field, value in data.items():
        setattr(order, field, value)
    order.save()
    return render_item(order)


@bp.get("/customers/<int:customer_id>/orders")
def order_history(customer_id):
    """All orders of one customer, newest first."""
    get_or_404(CustomerModel, customer_id, "Customer")
    orders = sorted(OrderModel.customer_index.query(customer_id),
                    key=lambda o: o.order_date or "", reverse=True)
    return render_list(orders, customer_id=customer_id)
