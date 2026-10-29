from pynamodb.exceptions import DoesNotExist, PutError

from app.utils.errors import Conflict, NotFound


def get_or_404(model, item_id, label):
    """Gets one item by id or raises a 404 error."""
    try:
        return model.get(item_id)
    except DoesNotExist:
        raise NotFound(f"{label} {item_id} not found")


def next_id(model):
    """DynamoDB has no auto-increment, so the new id is (highest id + 1)."""
    ids = [item.id for item in model.scan(attributes_to_get=["id"])]
    return int(max(ids, default=0)) + 1


def save_new(item):
    """Saves a new item, but refuses to overwrite an existing one with the same id."""
    try:
        item.save(condition=type(item).id.does_not_exist())
    except PutError as error:
        if error.cause_response_code == "ConditionalCheckFailedException":
            raise Conflict(f"An item with id {item.id} already exists, please try again")
        raise
