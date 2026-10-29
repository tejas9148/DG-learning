class ApiError(Exception):
    """An error we want to send back to the caller with a specific status code."""

    status_code = 400

    def __init__(self, message, status_code=None):
        super().__init__(message)
        self.message = message
        if status_code:
            self.status_code = status_code


class NotFound(ApiError):
    status_code = 404


class Conflict(ApiError):
    status_code = 409
