"""
Loads customers, products and orders (with their line items) from the Northwind
SQL dump into the DynamoDB tables.

Usage:
    python scripts/seed_dynamodb.py data/northwind-data.sql
"""
import os
import re
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "src"))

from app.models import CustomerModel, OrderItem, OrderModel, ProductModel  # noqa: E402

INSERT_START = re.compile(r"INSERT INTO `(\w+)` \((.*?)\) VALUES \(", re.S)


def convert(token):
    """Turns an unquoted SQL value (NULL, 12, 3.5) into a Python value."""
    if token.upper() == "NULL":
        return None
    try:
        number = float(token)
    except ValueError:
        return token
    return int(number) if number.is_integer() else number


def read_row(sql, i):
    """Reads one (...) group of values. i points just after the opening bracket."""
    values = []
    while True:
        while sql[i].isspace():
            i += 1
        if sql[i] == "'":                       # quoted text, '' means a single quote
            i += 1
            text = []
            while True:
                if sql[i] == "'":
                    if sql[i + 1] == "'":
                        text.append("'")
                        i += 2
                        continue
                    i += 1
                    break
                text.append(sql[i])
                i += 1
            values.append("".join(text))
        else:                                    # NULL or a number
            start = i
            while sql[i] not in ",)":
                i += 1
            values.append(convert(sql[start:i].strip()))
        while sql[i].isspace():
            i += 1
        if sql[i] == ",":
            i += 1
        elif sql[i] == ")":
            return values, i + 1


def read_inserts(sql):
    """Returns {table_name: [row_as_dict, ...]} for every INSERT in the file."""
    tables = {}
    for match in INSERT_START.finditer(sql):
        table = match.group(1)
        columns = [c.strip(" `\n") for c in match.group(2).split(",")]
        values, _ = read_row(sql, match.end())
        tables.setdefault(table, []).append(dict(zip(columns, values)))
    return tables


def without_empty(row, drop=()):
    return {k: v for k, v in row.items() if v is not None and k not in drop}


def build_customers(rows):
    return [CustomerModel(**without_empty(r, drop=("attachments",))) for r in rows]


def build_products(rows):
    products = []
    for r in rows:
        r = without_empty(r, drop=("attachments",))
        r["discontinued"] = bool(r.get("discontinued", 0))
        if "supplier_ids" in r:
            r["supplier_ids"] = str(r["supplier_ids"])
        products.append(ProductModel(**r))
    return products


def build_orders(order_rows, detail_rows):
    """Each order gets its order_details rows stored inside it as `items`."""
    items_by_order = {}
    for d in detail_rows:
        items_by_order.setdefault(d["order_id"], []).append(OrderItem(
            product_id=d["product_id"],
            quantity=d["quantity"],
            unit_price=d["unit_price"],
            discount=d["discount"] or 0,
        ))
    orders = []
    for r in order_rows:
        r = without_empty(r)
        r["items"] = items_by_order.get(r["id"], [])
        orders.append(OrderModel(**r))
    return orders


def save_all(model, items):
    with model.batch_write() as batch:
        for item in items:
            batch.save(item)
    print(f"Loaded {len(items)} items into {model.Meta.table_name}")


def main():
    if len(sys.argv) != 2:
        raise SystemExit("Usage: python scripts/seed_dynamodb.py data/northwind-data.sql")

    with open(sys.argv[1], encoding="utf-8") as f:
        tables = read_inserts(f.read())

    save_all(CustomerModel, build_customers(tables["customers"]))
    save_all(ProductModel, build_products(tables["products"]))
    save_all(OrderModel, build_orders(tables["orders"], tables["order_details"]))


if __name__ == "__main__":
    main()
