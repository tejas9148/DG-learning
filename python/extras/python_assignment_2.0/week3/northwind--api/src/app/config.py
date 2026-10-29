import os


class Config:
    # Lambda sets AWS_REGION itself. On your laptop it comes from `aws configure`.
    AWS_REGION = os.environ.get("AWS_REGION") or os.environ.get("AWS_DEFAULT_REGION")

    # Table names (the SAM template creates tables with the same names)
    TABLE_PREFIX = os.environ.get("TABLE_PREFIX", "northwind")
    CUSTOMERS_TABLE = f"{TABLE_PREFIX}-customers"
    PRODUCTS_TABLE = f"{TABLE_PREFIX}-products"
    ORDERS_TABLE = f"{TABLE_PREFIX}-orders"

    LOG_LEVEL = os.environ.get("LOG_LEVEL", "INFO")
