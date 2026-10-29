from datetime import datetime

from marshmallow import ValidationError, fields, validate


def text(max_length=255, **kwargs):
    """An optional text field (can also be null)."""
    return fields.Str(validate=validate.Length(max=max_length), allow_none=True, **kwargs)


def money(**kwargs):
    """A number that cannot be negative."""
    return fields.Float(validate=validate.Range(min=0), allow_none=True, **kwargs)


def whole_number(**kwargs):
    """A whole number that cannot be negative (strings like "5" are rejected)."""
    return fields.Int(strict=True, validate=validate.Range(min=0), allow_none=True, **kwargs)


def check_date(value):
    """Accepts 2006-01-15 or 2006-01-15 10:30:00 (or with a T between date and time)."""
    try:
        datetime.fromisoformat(value)
    except ValueError:
        raise ValidationError("Must be a date like 2006-01-15 or 2006-01-15 10:30:00.")


def date_field(**kwargs):
    return fields.Str(validate=check_date, allow_none=True, **kwargs)
