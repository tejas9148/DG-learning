import logging
import time

from flask import Flask, g, request
from marshmallow import ValidationError
from werkzeug.exceptions import HTTPException

from app.config import Config
from app.controllers import customer_controller, order_controller, product_controller
from app.utils.errors import ApiError
from app.views.responses import render_error

logger = logging.getLogger("northwind")


def create_app():
    app = Flask(__name__)
    app.url_map.strict_slashes = False

    # In Lambda the root logger already sends everything to CloudWatch Logs;
    # basicConfig only matters when running on your own machine.
    logging.basicConfig(format="%(asctime)s %(levelname)s %(name)s %(message)s")
    logging.getLogger().setLevel(Config.LOG_LEVEL)

    app.register_blueprint(customer_controller.bp)
    app.register_blueprint(product_controller.bp)
    app.register_blueprint(order_controller.bp)

    register_request_logging(app)
    register_error_handlers(app)
    return app


def register_request_logging(app):
    @app.before_request
    def start_timer():
        g.start = time.perf_counter()

    @app.after_request
    def log_request(response):
        took_ms = (time.perf_counter() - g.start) * 1000
        logger.info("%s %s -> %s (%.1f ms)", request.method, request.path, response.status_code, took_ms)
        return response


def register_error_handlers(app):
    @app.errorhandler(ValidationError)
    def handle_validation_error(error):
        logger.warning("Validation failed on %s %s: %s", request.method, request.path, error.messages)
        return render_error("Validation failed", 400, error.messages)

    @app.errorhandler(ApiError)
    def handle_api_error(error):
        logger.warning("%s on %s %s", error.message, request.method, request.path)
        return render_error(error.message, error.status_code)

    @app.errorhandler(HTTPException)
    def handle_http_error(error):
        return render_error(error.description, error.code)

    @app.errorhandler(Exception)
    def handle_unexpected_error(error):
        logger.exception("Unexpected error on %s %s", request.method, request.path)
        return render_error("Internal server error", 500)
