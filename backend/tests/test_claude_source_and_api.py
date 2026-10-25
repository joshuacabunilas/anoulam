import asyncio
import json
from types import SimpleNamespace

import anthropic
import httpx2
import pytest
from fastapi.testclient import TestClient

from app.claude_source import ClaudeRecipeSource
from app.errors import RecipeGenerationError
from app.main import app, get_recipe_source

OMELETTE = {
    "name": "Tomato Omelette",
    "description": "Fluffy omelette with fresh tomato.",
    "cooking_time_minutes": 10,
    "servings": 1,
    "difficulty": "easy",
    "category": "egg",
    "used_ingredients": ["egg", "tomato"],
    "missing_ingredients": ["onion"],
    "steps": ["Beat the eggs.", "Cook with tomato.", "Fold and serve."],
}


def _message(text="", stop_reason="end_turn", stop_details=None):
    return SimpleNamespace(
        stop_reason=stop_reason,
        stop_details=stop_details,
        content=[SimpleNamespace(type="text", text=text)],
        _request_id="req_test",
    )


class _FakeClaude:
    """Stands in for AsyncAnthropic; records the last request."""

    def __init__(self, reply=None, error=None):
        self.reply, self.error, self.last_request = reply, error, None
        self.beta = SimpleNamespace(messages=SimpleNamespace(create=self._create))

    async def _create(self, **kwargs):
        self.last_request = kwargs
        if self.error:
            raise self.error
        return self.reply


def _status_error(cls, status, headers=None):
    request = httpx2.Request("POST", "https://api.anthropic.com/v1/messages")
    response = httpx2.Response(status, headers=headers or {}, request=request)
    return cls("error", response=response, body=None)


def _generate(fake, ingredients=("egg", "tomato")):
    return asyncio.run(ClaudeRecipeSource(client=fake).generate(list(ingredients)))


# --- ClaudeRecipeSource -------------------------------------------------------


def test_returns_recipes_with_server_ids():
    fake = _FakeClaude(_message(json.dumps({"recipes": [OMELETTE]})))

    recipes = _generate(fake)

    assert [r.name for r in recipes] == ["Tomato Omelette"]
    assert recipes[0].id.startswith("tomato-omelette-")
    assert recipes[0].missing_ingredients == ["onion"]


def test_sends_structured_output_effort_and_fallback():
    fake = _FakeClaude(_message(json.dumps({"recipes": []})))

    _generate(fake)

    req = fake.last_request
    assert req["model"] == "claude-opus-5-5"
    assert req["output_config"]["format"]["type"] == "json_schema"
    assert req["output_config"]["effort"] == "medium"
    assert req["fallbacks"] == "default"
    assert "server-side-fallback-2026-07-01" in req["betas"]
    assert '["egg", "tomato"]' in req["messages"][0]["content"]


@pytest.mark.parametrize(
    ("reply", "status"),
    [
        (_message(stop_reason="refusal"), 422),
        (_message(stop_reason="max_tokens"), 502),
        (_message(text="not json"), 502),
        (_message(text=json.dumps({"recipes": [{"name": "x"}]})), 502),
    ],
)
def test_unusable_replies_map_to_errors(reply, status):
    with pytest.raises(RecipeGenerationError) as exc:
        _generate(_FakeClaude(reply))
    assert exc.value.status_code == status


@pytest.mark.parametrize(
    ("error", "status"),
    [
        (_status_error(anthropic.RateLimitError, 429, {"retry-after": "12"}), 503),
        (_status_error(anthropic.AuthenticationError, 401), 500),
        (_status_error(anthropic.InternalServerError, 500), 502),
        (_status_error(anthropic.BadRequestError, 400), 502),
        (
            anthropic.APITimeoutError(
                request=httpx2.Request("POST", "https://api.anthropic.com")
            ),
            504,
        ),
    ],
)
def test_api_errors_map_to_statuses(error, status):
    with pytest.raises(RecipeGenerationError) as exc:
        _generate(_FakeClaude(error=error))
    assert exc.value.status_code == status


def test_rate_limit_passes_retry_after():
    error = _status_error(anthropic.RateLimitError, 429, {"retry-after": "12"})
    with pytest.raises(RecipeGenerationError) as exc:
        _generate(_FakeClaude(error=error))
    assert exc.value.retry_after == 12


# --- HTTP layer ------------------------------------------------------------


class _StubGenerator:
    def __init__(self, result=None, error=None):
        self.result, self.error, self.received = result or [], error, None

    async def generate(self, ingredients):
        self.received = ingredients
        if self.error:
            raise self.error
        return self.result


@pytest.fixture
def client_with():
    def make(stub):
        app.dependency_overrides[get_recipe_source] = lambda: stub
        return TestClient(app, raise_server_exceptions=False)

    yield make
    app.dependency_overrides.clear()


def test_generate_endpoint_returns_recipes(client_with):
    recipe = {"id": "tomato-omelette-abc123", **OMELETTE}
    stub = _StubGenerator(result=[recipe])

    res = client_with(stub).post(
        "/recipes/generate", json={"ingredients": [" Egg ", "egg", "Tomato"]}
    )

    assert res.status_code == 200
    assert res.json() == {
        "recipes": [{**recipe, "image_url": None, "image_credit": None}]
    }
    assert stub.received == ["Egg", "Tomato"]  # trimmed + de-duplicated


@pytest.mark.parametrize(
    "body",
    [
        {},
        {"ingredients": []},
        {"ingredients": ["   "]},
        {"ingredients": ["x" * 51]},
        {"ingredients": [f"item {i}" for i in range(31)]},
    ],
)
def test_generate_endpoint_rejects_bad_input(client_with, body):
    res = client_with(_StubGenerator()).post("/recipes/generate", json=body)
    assert res.status_code == 422


def test_generate_endpoint_returns_error_detail(client_with):
    stub = _StubGenerator(error=RecipeGenerationError(503, "Busy.", retry_after=7))

    res = client_with(stub).post("/recipes/generate", json={"ingredients": ["egg"]})

    assert res.status_code == 503
    assert res.json() == {"detail": "Busy."}
    assert res.headers["retry-after"] == "7"


def test_health(client_with):
    assert client_with(_StubGenerator()).get("/health").json() == {"status": "ok"}


def test_unexpected_errors_return_json_500(client_with):
    stub = _StubGenerator(error=TypeError("boom"))

    res = client_with(stub).post("/recipes/generate", json={"ingredients": ["egg"]})

    assert res.status_code == 500
    assert res.json() == {"detail": "Something went wrong. Please try again."}
