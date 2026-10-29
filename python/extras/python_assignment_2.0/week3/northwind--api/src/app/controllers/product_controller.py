from flask import Blueprint

from app.models import ProductModel
from app.schemas.product_schema import ProductSchema
from app.utils.db import get_or_404, next_id, save_new
from app.utils.validation import load_json
from app.views.responses import render_item, render_list

bp = Blueprint("products", __name__, url_prefix="/products")
schema = ProductSchema()


@bp.get("")
def list_products():
    products = sorted(ProductModel.scan(), key=lambda p: p.id)
    return render_list(products)


@bp.get("/<int:product_id>")
def get_product(product_id):
    return render_item(get_or_404(ProductModel, product_id, "Product"))


@bp.post("")
def create_product():
    data = load_json(schema)
    product = ProductModel(id=next_id(ProductModel), **data)
    save_new(product)
    return render_item(product, 201)


@bp.put("/<int:product_id>")
def update_product(product_id):
    data = load_json(schema, partial=True)
    product = get_or_404(ProductModel, product_id, "Product")
    for field, value in data.items():
        setattr(product, field, value)
    product.save()
    return render_item(product)
