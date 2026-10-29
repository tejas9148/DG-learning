"""The V of MVC: turns models and errors into JSON responses."""
from flask import jsonify


def render_item(model, status=200):
    return jsonify(model.to_simple_dict()), status


def render_list(models, **extra):
    items = [model.to_simple_dict() for model in models]
    return jsonify({**extra, "count": len(items), "items": items}), 200


def render_error(message, status, details=None):
    body = {"error": message}
    if details:
        body["details"] = details
    return jsonify(body), status
