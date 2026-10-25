import pytest

from app.matching import match_recipes, normalize
from app.schemas import StoredRecipe


def _recipe(id_, ingredients, minutes=10):
    return StoredRecipe(
        id=id_,
        name=id_.replace("-", " ").title(),
        description="Test recipe.",
        cooking_time_minutes=minutes,
        servings=2,
        difficulty="easy",
        ingredients=ingredients,
        steps=["Cook."],
    )


@pytest.mark.parametrize(
    ("raw", "expected"),
    [
        ("Eggs", "egg"),
        ("  TOMATOES ", "tomato"),
        ("potatoes", "potato"),
        ("berries", "berry"),
        ("bay leaves", "bay leaf"),
        ("2 chicken breasts", "chicken"),
        ("ground beef", "beef"),
        ("pork belly", "pork"),
        ("garlic cloves", "garlic"),
        ("Spaghetti", "pasta"),
        ("scallions", "green onion"),
        ("red onion", "onion"),
        ("cheddar", "cheese"),
        ("coconut milk", "coconut milk"),
        ("glass", "glass"),
        ("glutinous rice", "glutinous rice"),
        ("hummus", "hummus"),
        ("chillies", "chili"),
        ("prawns", "shrimp"),
        ("tokwa", "tofu"),
        ("kalabasa", "squash"),
        ("pechay", "bok choy"),
        ("hot dogs", "hotdog"),
        ("heavy cream", "cream"),
        ("chicken stock", "chicken broth"),
    ],
)
def test_normalize(raw, expected):
    assert normalize(raw) == expected


def test_only_recipes_using_an_ingredient_are_returned():
    recipes = [_recipe("omelette", ["egg", "onion"]), _recipe("toast", ["bread"])]

    result = match_recipes(recipes, ["eggs"], limit=5)

    assert [r.id for r in result] == ["omelette"]
    assert result[0].used_ingredients == ["egg"]
    assert result[0].missing_ingredients == ["onion"]


def test_ranks_by_fewest_missing_then_most_used_then_quickest():
    recipes = [
        _recipe("two-missing", ["egg", "flour", "sugar"]),
        _recipe("none-missing-slow", ["egg", "milk"], minutes=30),
        _recipe("none-missing-fast", ["egg", "milk"], minutes=5),
        _recipe("one-missing", ["egg", "rice"]),
        _recipe("none-missing-one-used", ["egg"]),
    ]

    result = match_recipes(recipes, ["egg", "milk"], limit=10)

    assert [r.id for r in result] == [
        "none-missing-fast",
        "none-missing-slow",
        "none-missing-one-used",
        "one-missing",
        "two-missing",
    ]


def test_pantry_staples_are_never_missing_or_matching():
    recipes = [_recipe("fried-egg", ["egg", "oil", "salt"]), _recipe("salad", ["lettuce"])]

    result = match_recipes(recipes, ["egg", "salt"], limit=5)

    assert [r.id for r in result] == ["fried-egg"]
    assert result[0].missing_ingredients == []
    assert match_recipes(recipes, ["salt", "water"], limit=5) == []


def test_does_not_confuse_compound_ingredients():
    recipes = [_recipe("curry", ["coconut milk", "chicken"])]

    assert match_recipes(recipes, ["milk"], limit=5) == []


def test_respects_limit():
    recipes = [_recipe(f"r{i}", ["egg"]) for i in range(10)]

    assert len(match_recipes(recipes, ["egg"], limit=3)) == 3


def test_prefers_recipes_using_more_of_your_ingredients():
    recipes = [
        _recipe("sinangag", ["rice", "garlic"]),
        _recipe("adobo", ["chicken", "soy sauce", "vinegar", "garlic", "bay leaf"]),
    ]

    result = match_recipes(
        recipes, ["chicken breast", "soy sauce", "vinegar", "garlic"], limit=5
    )

    assert [r.id for r in result] == ["adobo", "sinangag"]


def test_can_cook_now_always_comes_first():
    recipes = [
        _recipe("big-but-missing-one", ["egg", "milk", "flour", "sugar", "butter"]),
        _recipe("complete-small", ["egg"]),
    ]

    result = match_recipes(recipes, ["egg", "milk", "flour", "sugar"], limit=5)

    assert [r.id for r in result] == ["complete-small", "big-but-missing-one"]
