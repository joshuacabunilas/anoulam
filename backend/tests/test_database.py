import json

import pytest
from fastapi.testclient import TestClient

from app.config import settings
from app.database import RecipeDatabase
from app.database_source import DatabaseRecipeSource
from app.main import app, get_database, get_recipe_source
from app.matching import PANTRY_STAPLES, normalize


@pytest.fixture
def database(tmp_path):
    return RecipeDatabase(tmp_path / "recipes.db", seed_path=settings.seed_path)


def test_seed_file_is_valid_and_ids_are_unique():
    items = json.loads(settings.seed_path.read_text("utf-8"))
    ids = [item["id"] for item in items]

    assert len(items) >= 100
    assert len(ids) == len(set(ids))


def test_seed_ingredient_names_are_canonical():
    """Seed names must already be in normalized form, or user input that
    normalizes correctly would never match them."""
    items = json.loads(settings.seed_path.read_text("utf-8"))
    problems = [
        f"{item['id']}: {name!r} -> {normalize(name)!r}"
        for item in items
        for name in item["ingredients"]
        if normalize(name) != name or name in PANTRY_STAPLES
    ]
    assert problems == []


def test_seed_recipes_have_enough_steps():
    items = json.loads(settings.seed_path.read_text("utf-8"))
    assert all(len(item["steps"]) >= 2 for item in items)


def test_seeds_once_and_round_trips(database, tmp_path):
    seeded = json.loads(settings.seed_path.read_text("utf-8"))

    recipes = database.list_all()
    adobo = database.get("chicken-adobo")

    assert len(recipes) == len(seeded)
    assert adobo is not None
    assert adobo.ingredients[0] == "chicken"  # order preserved
    assert len(adobo.steps) == 5
    # Opening again doesn't duplicate the seed data.
    reopened = RecipeDatabase(tmp_path / "recipes.db", seed_path=settings.seed_path)
    assert len(reopened.list_all()) == len(seeded)


def test_get_unknown_recipe_returns_none(database):
    assert database.get("does-not-exist") is None


@pytest.fixture
def client(database):
    app.dependency_overrides[get_database] = lambda: database
    app.dependency_overrides[get_recipe_source] = lambda: DatabaseRecipeSource(
        database
    )
    yield TestClient(app, raise_server_exceptions=False)
    app.dependency_overrides.clear()


def test_list_recipes_endpoint(client):
    res = client.get("/recipes")

    assert res.status_code == 200
    names = [r["name"] for r in res.json()["recipes"]]
    assert names == sorted(names)
    assert "Chicken Adobo" in names


def test_get_recipe_endpoint(client):
    res = client.get("/recipes/tomato-omelette")

    assert res.status_code == 200
    assert res.json()["ingredients"] == ["egg", "tomato", "onion"]


def test_get_recipe_endpoint_404(client):
    res = client.get("/recipes/nope")

    assert res.status_code == 404
    assert res.json() == {"detail": "Recipe not found."}


def test_generate_from_database(client):
    res = client.post(
        "/recipes/generate", json={"ingredients": ["Eggs", "tomatoes", "onion"]}
    )

    assert res.status_code == 200
    recipes = res.json()["recipes"]
    assert recipes[0]["id"] == "tomato-omelette"
    assert recipes[0]["missing_ingredients"] == []
    assert len(recipes) <= settings.max_recipes


def test_generate_from_database_no_match(client):
    res = client.post("/recipes/generate", json={"ingredients": ["chocolate"]})

    assert res.status_code == 200
    assert res.json() == {"recipes": []}


def test_seed_categories_and_images_are_consistent():
    items = json.loads(settings.seed_path.read_text("utf-8"))
    for item in items:
        assert "category" in item, item["id"]
        url = item.get("image_url")
        if url is None:
            assert item.get("image_credit") is None, item["id"]
            continue
        assert url.startswith("/images/"), item["id"]
        assert (settings.images_dir / url.removeprefix("/images/")).is_file(), url
        assert item.get("image_credit"), f"{item['id']} has a photo but no credit"


def test_images_are_served(client):
    res = client.get("/images/chicken-adobo.jpg")

    assert res.status_code == 200
    assert res.headers["content-type"] == "image/jpeg"


def test_recipe_includes_image_fields(client):
    body = client.get("/recipes/chicken-adobo").json()

    assert body["category"] == "meat"
    assert body["image_url"] == "/images/chicken-adobo.jpg"
    assert body["image_credit"].startswith("Photo: ")
