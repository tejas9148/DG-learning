import logging
from unittest.mock import patch

from app.models import CustomerModel
from tests.conftest import make_customer


def test_unexpected_error_returns_500_and_is_logged(client, caplog):
    with patch.object(CustomerModel, "scan", side_effect=RuntimeError("database is down")), \
         caplog.at_level(logging.INFO, logger="northwind"):
        response = client.get("/customers")

    assert response.status_code == 500
    assert response.json == {"error": "Internal server error"}      # details are not leaked
    assert "Unexpected error on GET /customers" in caplog.text


def test_every_request_is_logged(client, caplog):
    with patch.object(CustomerModel, "get", return_value=make_customer()), \
         caplog.at_level(logging.INFO, logger="northwind"):
        client.get("/customers/1")

    assert "GET /customers/1 -> 200" in caplog.text


def test_unknown_route_returns_json_404(client):
    response = client.get("/nothing-here")

    assert response.status_code == 404
    assert "error" in response.json


def test_wrong_method_returns_json_405(client):
    response = client.delete("/customers/1")

    assert response.status_code == 405
    assert "error" in response.json
