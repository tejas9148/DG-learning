from unittest.mock import patch

from botocore.exceptions import ClientError
from pynamodb.exceptions import DoesNotExist, PutError

from app.models import CustomerModel
from tests.conftest import make_customer


def test_list_customers(client):
    with patch.object(CustomerModel, "scan", return_value=[make_customer(id=2), make_customer(id=1)]):
        response = client.get("/customers")

    assert response.status_code == 200
    assert response.json["count"] == 2
    assert [c["id"] for c in response.json["items"]] == [1, 2]      # sorted by id


def test_get_customer(client):
    with patch.object(CustomerModel, "get", return_value=make_customer()):
        response = client.get("/customers/1")

    assert response.status_code == 200
    assert response.json["company"] == "Company A"


def test_get_customer_not_found(client):
    with patch.object(CustomerModel, "get", side_effect=DoesNotExist()):
        response = client.get("/customers/99")

    assert response.status_code == 404
    assert "99" in response.json["error"]


def test_create_customer(client):
    with patch.object(CustomerModel, "scan", return_value=[make_customer(id=29)]), \
         patch.object(CustomerModel, "save") as save:
        response = client.post("/customers", json={"company": "Acme", "email_address": "a@acme.com"})

    assert response.status_code == 201
    assert response.json["id"] == 30                  # highest id (29) + 1
    assert response.json["company"] == "Acme"
    save.assert_called_once()


def test_create_customer_missing_company(client):
    response = client.post("/customers", json={"city": "Pune"})

    assert response.status_code == 400
    assert "company" in response.json["details"]


def test_create_customer_bad_email(client):
    response = client.post("/customers", json={"company": "Acme", "email_address": "not-an-email"})

    assert response.status_code == 400
    assert "email_address" in response.json["details"]


def test_create_customer_unknown_field_rejected(client):
    response = client.post("/customers", json={"company": "Acme", "favourite_colour": "blue"})

    assert response.status_code == 400
    assert "favourite_colour" in response.json["details"]


def test_create_customer_body_must_be_json_object(client):
    response = client.post("/customers", data="hello", content_type="text/plain")

    assert response.status_code == 400


def test_create_customer_id_clash_returns_409(client):
    clash = PutError("clash", ClientError({"Error": {"Code": "ConditionalCheckFailedException", "Message": "x"}}, "PutItem"))
    with patch.object(CustomerModel, "scan", return_value=[]), \
         patch.object(CustomerModel, "save", side_effect=clash):
        response = client.post("/customers", json={"company": "Acme"})

    assert response.status_code == 409


def test_update_customer_changes_only_sent_fields(client):
    with patch.object(CustomerModel, "get", return_value=make_customer()), \
         patch.object(CustomerModel, "save") as save:
        response = client.put("/customers/1", json={"city": "Pune"})

    assert response.status_code == 200
    assert response.json["city"] == "Pune"
    assert response.json["company"] == "Company A"    # untouched
    save.assert_called_once()


def test_update_customer_not_found(client):
    with patch.object(CustomerModel, "get", side_effect=DoesNotExist()):
        response = client.put("/customers/99", json={"city": "Pune"})

    assert response.status_code == 404


def test_update_customer_empty_body(client):
    response = client.put("/customers/1", json={})

    assert response.status_code == 400
