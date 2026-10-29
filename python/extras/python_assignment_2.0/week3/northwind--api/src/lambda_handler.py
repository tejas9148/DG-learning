from apig_wsgi import make_lambda_handler

from app import create_app

app = create_app()

# API Gateway calls this function; apig_wsgi translates the API Gateway event into a Flask request.
handler = make_lambda_handler(app)
