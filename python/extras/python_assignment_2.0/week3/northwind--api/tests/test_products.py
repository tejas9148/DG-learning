from unittest.mock import patch

from pynamodb.exceptions import DoesNotExist

from app.models import ProductModel
from tests.conftest import make_product

NEW_PRODUCT = {"product_code": "X-1", "product_name": "Pen", "list_price": 2.5}


def test_list_products(client):
    with patch.object(ProductModel, "scan", return_value=[make_product(id=2), make_product(id=1)]):
        response = client.get("/products")

    assert response.status_code == 200
    assert [p["id"] for p in response.json["items"]] == [1, 2]


def test_get_product(client):
    with patch.object(ProductModel, "get", return_value=make_product()):
        response = client.get("/products/1")

    assert response.status_code == 200
    assert response.json["product_name"] == "Chai"
    assert response.json["discontinued"] is False


def test_get_product_not_found(client):
    with patch.object(ProductModel, "get", side_effect=DoesNotExist()):
        response = client.get("/products/99")

    assert response.status_code == 404


def test_create_product(client):
    with patch.object(ProductModel, "scan", return_value=[make_product(id=97)]), \
         patch.object(ProductModel, "save") as save:
        response = client.post("/products", json=NEW_PRODUCT)

    assert response.status_code == 201
    assert response.json["id"] == 98
    assert response.json["list_price"] == 2.5
    save.assert_called_once()


def test_create_product_missing_required_fields(client):
    response = client.post("/products", json={"product_name": "Pen"})

    assert response.status_code == 400
    assert "list_price" in response.json["details"]
    assert "product_code" in response.json["details"]


def test_create_product_negative_price(client):
    response = client.post("/products", json={**NEW_PRODUCT, "list_price": -5})

    assert response.status_code == 400
    assert "list_price" in response.json["details"]


def test_create_product_price_must_be_a_number(client):
    response = client.post("/products", json={**NEW_PRODUCT, "list_price": "cheap"})

    assert response.status_code == 400


def test_update_product(client):
    with patch.object(ProductModel, "get", return_value=make_product()), \
         patch.object(ProductModel, "save") as save:
        response = client.put("/products/1", json={"list_price": 20, "discontinued": True})

    assert response.status_code == 200
    assert response.json["list_price"] == 20
    assert response.json["discontinued"] is True
    save.assert_called_once()


def test_update_product_not_found(client):
    with patch.object(ProductModel, "get", side_effect=DoesNotExist()):
        response = client.put("/products/99", json={"list_price": 20})

    assert response.status_code == 404
