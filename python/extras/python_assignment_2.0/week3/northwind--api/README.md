# Northwind REST API (Flask + DynamoDB on AWS Lambda)

A REST API over the Northwind data. It supports insert, update and select for
customers, products and orders, plus the order history of a customer.
It runs as a Flask app inside AWS Lambda behind API Gateway, stores data in
DynamoDB and writes its logs to CloudWatch.

## 1. Endpoints

| Method | URL | What it does |
|--------|-----|--------------|
| GET | `/customers` | list all customers |
| GET | `/customers/<id>` | get one customer |
| POST | `/customers` | insert a customer |
| PUT | `/customers/<id>` | update a customer (send only the fields to change) |
| GET | `/products` | list all products |
| GET | `/products/<id>` | get one product |
| POST | `/products` | insert a product |
| PUT | `/products/<id>` | update a product |
| GET | `/orders` | list all orders |
| GET | `/orders/<id>` | get one order (with its items) |
| POST | `/orders` | insert an order |
| PUT | `/orders/<id>` | update an order |
| GET | `/customers/<id>/orders` | order history of a customer, newest first |

## 2. Folder structure

```
northwind-api/
├── README.md                    these steps
├── template.yaml                AWS SAM template (API Gateway, Lambda, 3 DynamoDB tables, log group)
├── pytest.ini
├── requirements-dev.txt         libraries for running tests on your machine
├── data/
│   └── northwind-data.sql       the Northwind data you were given
├── scripts/
│   └── seed_dynamodb.py         loads the .sql data into DynamoDB
├── src/                         everything that gets deployed to Lambda
│   ├── lambda_handler.py        entry point that Lambda calls
│   ├── requirements.txt         libraries needed in Lambda
│   └── app/
│       ├── __init__.py          creates the Flask app, request logging, error handling
│       ├── config.py            table names, region, log level
│       ├── models/              M: ORM classes (PynamoDB) - customer, product, order
│       ├── schemas/             data validation rules (marshmallow)
│       ├── controllers/         C: routes and logic - customer, product, order
│       ├── views/               V: builds the JSON responses
│       └── utils/               small helpers (get-or-404, next id, errors, JSON reading)
└── tests/                       unit tests (all DynamoDB calls are mocked)
```

MVC in this project:
- **Model** = `src/app/models` (ORM classes that map to the DynamoDB tables)
- **View** = `src/app/views` (JSON output)
- **Controller** = `src/app/controllers` (receives the request, validates it, uses the models)

## 3. How the data is stored

Three DynamoDB tables, created by `template.yaml`:

| Table | Key | Notes |
|-------|-----|-------|
| `northwind-customers` | `id` | one item per customer |
| `northwind-products` | `id` | one item per product |
| `northwind-orders` | `id` | the order lines (Northwind's `order_details`) are stored inside the order as `items` |

`northwind-orders` also has an index on `customer_id`. This is what makes the
order history fast, because it avoids scanning the whole table.

## 4. Steps

### Step 1: Install what you need
- Python 3.12
- An AWS account
- AWS CLI, then run `aws configure` (access key, secret key and your region)
- AWS SAM CLI (check with `sam --version`)

### Step 2: Set up the project on your machine
Open a terminal in the `northwind-api` folder.

Windows (PowerShell):
```
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements-dev.txt
```
Mac/Linux:
```
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements-dev.txt
```

### Step 3: Run the unit tests
```
python -m pytest
```
All 41 tests should pass. They never call AWS: every DynamoDB call is mocked
(`unittest.mock`), and a safety check makes a test fail if it forgets to mock one.

### Step 4: Build
```
sam build
```

### Step 5: Deploy to AWS
```
sam deploy --guided
```
Answer the questions like this:
- Stack Name: `northwind-api`
- AWS Region: the same region you used in `aws configure`
- Confirm changes before deploy: `y`
- Allow SAM CLI IAM role creation: `y`
- "ApiFunction has no authentication, is this okay?": `y` (the assignment does not ask for authentication)
- Save arguments to configuration file: `y`

When it finishes, copy the `ApiUrl` value from the Outputs. This creates the
API Gateway, the Lambda function, the three DynamoDB tables and the CloudWatch log group.

### Step 6: Load the Northwind data into DynamoDB
```
python scripts/seed_dynamodb.py data/northwind-data.sql
```
It should print that 29 customers, 45 products and 48 orders were loaded.
(Use the same AWS account and region as the deployment.)

### Step 7: Try the API
Windows (PowerShell):
```
$api = "https://xxxxxxxx.execute-api.<region>.amazonaws.com"    # your ApiUrl

Invoke-RestMethod "$api/customers"
Invoke-RestMethod "$api/customers/4/orders"

Invoke-RestMethod -Method Post "$api/customers" -ContentType "application/json" -Body '{"company":"Acme","email_address":"hello@acme.com"}'
Invoke-RestMethod -Method Put  "$api/customers/30" -ContentType "application/json" -Body '{"city":"Pune"}'

Invoke-RestMethod -Method Post "$api/orders" -ContentType "application/json" -Body '{"customer_id":4,"items":[{"product_id":1,"quantity":3}]}'
```
Mac/Linux:
```
API=https://xxxxxxxx.execute-api.<region>.amazonaws.com
curl $API/customers/4/orders
curl -X POST $API/customers -H "Content-Type: application/json" -d '{"company":"Acme"}'
```
A wrong request (for example a customer without `company`) returns `400` with
the list of problems. An id that does not exist returns `404`.

### Step 8: Check the logs in CloudWatch
Command line:
```
sam logs --stack-name northwind-api --name ApiFunction --tail
```
Or in the AWS console: CloudWatch, then Log groups, then `/aws/lambda/<FunctionName>`
(the function name is in the deploy Outputs). Every request is logged like
`GET /customers/4 -> 200 (12.3 ms)`, and errors are logged with the full error details.

### Step 9: Clean up (so you are not charged)
```
sam delete --stack-name northwind-api
```

## 5. Validation rules (src/app/schemas)
- **Customer:** `company` is required. `email_address` must be a valid email. Text fields have maximum lengths.
- **Product:** `product_code`, `product_name` and `list_price` are required. Prices and stock levels cannot be negative.
- **Order:** `customer_id` and at least one item are required. The customer and every product must exist.
  Quantity must be above 0, discount between 0 and 1, `status_id` one of 0 to 3, dates like `2006-01-15`.
- Fields that are not in the schema are rejected, and the wrong type (for example text in a price) is rejected.

## 6. Good to know
- New ids are "highest id + 1", because DynamoDB has no auto-increment. This is fine for this assignment, but
  two inserts at the exact same moment could clash (the API then returns `409`, so just retry).
- Listing uses a table scan. That is fine for this small dataset.
- The API has no login, because the assignment does not ask for one.
- Only customers, products and orders (with their items) are loaded. The other Northwind tables are not needed here.
