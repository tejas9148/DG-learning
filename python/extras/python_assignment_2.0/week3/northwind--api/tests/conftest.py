import os
from unittest.mock import patch

# Fake settings so nothing can accidentally use real AWS credentials
os.environ.setdefault("AWS_DEFAULT_REGION", "us-east-1")
os.environ.setdefault("AWS_ACCESS_KEY_ID", "test")
os.environ.setdefault("AWS_SECRET_ACCESS_KEY", "test")

import pytest  # noqa: E402

from app import create_app  # noqa: E402
from app.models import CustomerModel, OrderItem, OrderModel, ProductModel  # noqa: E402


@pytest.fixture(autouse=True)
def block_real_aws_calls():
    """Every DynamoDB call goes through this method. If a test forgets to mock
    something, it fails loudly instead of talking to AWS."""
    with patch("pynamodb.connection.base.Connection._make_api_call",
               side_effect=AssertionError("A test tried to call real AWS - mock it")):
        yield


@pytest.fixture
def client():
    app = create_app()
    app.config["TESTING"] = True
    return app.test_client()


def make_customer(**overrides):
    values = {"id": 1, "company": "Company A", "last_name": "Bedecs", "first_name": "Anna", "city": "Seattle"}
    values.update(overrides)
    return CustomerModel(**values)


def make_product(**overrides):
    values = {"id": 1, "product_code": "NWTB-1", "product_name": "Chai", "list_price": 18, "discontinued": False}
    values.update(overrides)
    return ProductModel(**values)


def make_order(**overrides):
    values = {
        "id": 30, "customer_id": 1, "order_date": "2006-01-15 00:00:00", "status_id": 3,
        "items": [OrderItem(product_id=1, quantity=5, unit_price=18, discount=0)],
    }
    values.update(overrides)
    return OrderModel(**values)
