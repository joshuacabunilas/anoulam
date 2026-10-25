class RecipeGenerationError(Exception):
    """A failure the API should report to the client.

    `status_code` is the HTTP status to return; `message` is safe to show
    to app users. `retry_after` (seconds) is set for rate limits.
    """

    def __init__(
        self, status_code: int, message: str, retry_after: int | None = None
    ):
        super().__init__(message)
        self.status_code = status_code
        self.message = message
        self.retry_after = retry_after
