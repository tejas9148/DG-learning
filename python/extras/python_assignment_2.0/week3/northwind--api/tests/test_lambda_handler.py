import json
from unittest.mock import patch

from app.models import CustomerModel
from lambda_handler import handler
from tests.conftest import make_customer


def api_gateway_event(method, path):
    """A minimal HTTP API (payload v2) event, like the one API Gateway sends to Lambda."""
    return {
        "version": "2.0",
        "rawPath": path,
        "rawQueryString": "",
        "headers": {"host": "example.execute-api.us-east-1.amazonaws.com"},
        "requestContext": {"http": {"method": method, "path": path, "protocol": "HTTP/1.1", "sourceIp": "1.2.3.4"}},
        "isBase64Encoded": False,
    }


def test_lambda_handler_returns_api_gateway_response():
    with patch.object(CustomerModel, "get", return_value=make_customer()):
        result = handler(api_gateway_event("GET", "/customers/1"), None)

    assert result["statusCode"] == 200
    assert json.loads(result["body"])["company"] == "Company A"
