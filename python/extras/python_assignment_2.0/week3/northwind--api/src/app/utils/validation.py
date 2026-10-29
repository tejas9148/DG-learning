from flask import request
from marshmallow import ValidationError


def load_json(schema, partial=False):
    """Reads the JSON body and checks it against a schema.

    partial=True is used for updates: only the fields that are sent are checked and changed.
    Raises marshmallow's ValidationError, which the app turns into a 400 response.
    """
    body = request.get_json(silent=True)
    if not isinstance(body, dict):
        raise ValidationError({"_body": ["Request body must be a JSON object"]})

    data = schema.load(body, partial=partial)   # unknown fields are rejected
    if partial and not data:
        raise ValidationError({"_body": ["Send at least one field to update"]})
    return data
