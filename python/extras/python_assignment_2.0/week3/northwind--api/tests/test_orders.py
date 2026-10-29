from unittest.mock import patch

from pynamodb.exceptions import DoesNotExist

from app.models import CustomerModel, OrderModel, ProductModel
from tests.conftest import make_customer, make_order, make_product

NEW_ORDER = {"customer_id": 1, "items": [{"product_id": 1, "quantity": 3}]}


def test_list_orders(client):
    with patch.object(OrderModel, "scan", return_value=[make_order(id=31), make_order(id=30)]):
        response = client.get("/orders")

    assert response.status_code == 200
    assert [o["id"] for o in response.json["items"]] == [30, 31]


def test_get_order(client):
    with patch.object(OrderModel, "get", return_value=make_order()):
        response = client.get("/orders/30")

    assert response.status_code == 200
    assert response.json["items"][0]["product_id"] == 1


def test_get_order_not_found(client):
    with patch.object(OrderModel, "get", side_effect=DoesNotExist()):
        response = client.get("/orders/999")

    assert response.status_code == 404


def test_create_order(client):
    with patch.object(CustomerModel, "get", return_value=make_customer()), \
         patch.object(ProductModel, "get", return_value=make_product(list_price=18)), \
         patch.object(OrderModel, "scan", return_value=[make_order(id=81)]), \
         patch.object(OrderModel, "save") as save:
        response = client.post("/orders", json=NEW_ORDER)

    assert response.status_code == 201
    assert response.json["id"] == 82
    assert response.json["status_id"] == 0                        # defaults to New
    assert response.json["order_date"]                            # filled in automatically
    assert response.json["items"][0]["unit_price"] == 18          # taken from the product
    save.assert_called_once()


def test_create_order_unknown_customer(client):
    with patch.object(CustomerModel, "get", side_effect=DoesNotExist()):
        response = client.post("/orders", json=NEW_ORDER)

    assert response.status_code == 400
    assert "Customer" in response.json["error"]


def test_create_order_unknown_product(client):
    with patch.object(CustomerModel, "get", return_value=make_customer()), \
         patch.object(ProductModel, "get", side_effect=DoesNotExist()):
        response = client.post("/orders", json=NEW_ORDER)

    assert response.status_code == 400
    assert "Product" in response.json["error"]


def test_create_order_needs_at_least_one_item(client):
    response = client.post("/orders", json={"customer_id": 1, "items": []})

    assert response.status_code == 400
    assert "items" in response.json["details"]


def test_create_order_quantity_must_be_positive(client):
    response = client.post("/orders", json={"customer_id": 1, "items": [{"product_id": 1, "quantity": 0}]})

    assert response.status_code == 400


def test_create_order_bad_status_and_date(client):
    response = client.post("/orders", json={**NEW_ORDER, "status_id": 9, "order_date": "yesterday"})

    assert response.status_code == 400
    assert "status_id" in response.json["details"]
    assert "order_date" in response.json["details"]


def test_update_order(client):
    with patch.object(OrderModel, "get", return_value=make_order()), \
         patch.object(OrderModel, "save") as save:
        response = client.put("/orders/30", json={"status_id": 2, "shipped_date": "2006-01-22"})

    assert response.status_code == 200
    assert response.json["status_id"] == 2
    assert response.json["shipped_date"] == "2006-01-22"
    save.assert_called_once()


def test_update_order_items_are_checked(client):
    with patch.object(OrderModel, "get", return_value=make_order()), \
         patch.object(ProductModel, "get", side_effect=DoesNotExist()):
        response = client.put("/orders/30", json={"items": [{"product_id": 999, "quantity": 1}]})

    assert response.status_code == 400


def test_update_order_not_found(client):
    with patch.object(OrderModel, "get", side_effect=DoesNotExist()):
        response = client.put("/orders/999", json={"status_id": 2})

    assert response.status_code == 404


def test_order_history_newest_first(client):
    orders = [
        make_order(id=30, order_date="2006-01-15 00:00:00"),
        make_order(id=34, order_date="2006-04-25 00:00:00"),
        make_order(id=31, order_date="2006-02-06 00:00:00"),
    ]
    with patch.object(CustomerModel, "get", return_value=make_customer()), \
         patch.object(OrderModel, "customer_index") as index:
        index.query.return_value = orders
        response = client.get("/customers/1/orders")

    assert response.status_code == 200
    assert response.json["customer_id"] == 1
    assert [o["id"] for o in response.json["items"]] == [34, 31, 30]
    index.query.assert_called_once_with(1)


def test_order_history_unknown_customer(client):
    with patch.object(CustomerModel, "get", side_effect=DoesNotExist()):
        response = client.get("/customers/99/orders")

    assert response.status_code == 404


def test_order_history_customer_without_orders(client):
    with patch.object(CustomerModel, "get", return_value=make_customer()), \
         patch.object(OrderModel, "customer_index") as index:
        index.query.return_value = []
        response = client.get("/customers/1/orders")

    assert response.status_code == 200
    assert response.json["count"] == 0
