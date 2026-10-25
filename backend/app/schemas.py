"""Request/response shapes for the public API.

These match the Flutter app's `RecipeModel` (lib/src/app/recipe/data/model/).
Change both sides together.
"""

from typing import Annotated, Literal

from pydantic import BaseModel, Field, StringConstraints, field_validator

Ingredient = Annotated[
    str, StringConstraints(strip_whitespace=True, min_length=1, max_length=50)
]

MAX_INGREDIENTS = 30

# Drives the app's illustrated header when a recipe has no photo.
Category = Literal[
    "rice",
    "noodles",
    "soup",
    "egg",
    "meat",
    "seafood",
    "vegetable",
    "bread",
    "dessert",
    "drink",
    "snack",
]


class GenerateRecipesRequest(BaseModel):
    ingredients: list[Ingredient] = Field(
        min_length=1,
        max_length=MAX_INGREDIENTS,
        examples=[["egg", "rice", "soy sauce"]],
    )

    @field_validator("ingredients")
    @classmethod
    def dedupe(cls, value: list[str]) -> list[str]:
        """Drop case-insensitive duplicates, keeping the first spelling."""
        seen: set[str] = set()
        unique = []
        for item in value:
            key = item.lower()
            if key not in seen:
                seen.add(key)
                unique.append(item)
        return unique


class Recipe(BaseModel):
    id: str
    name: str
    description: str
    cooking_time_minutes: int = Field(ge=1)
    servings: int = Field(ge=1)
    difficulty: Literal["easy", "medium", "hard"]
    category: Category = "meat"
    # Absolute URL, or a path relative to the API's base URL (e.g.
    # "/images/chicken-adobo.jpg"). None when there is no photo yet.
    image_url: str | None = None
    # Who took the photo and its license, e.g. "Photo: Jane Doe, CC BY-SA 4.0".
    image_credit: str | None = None
    used_ingredients: list[str]
    missing_ingredients: list[str]
    steps: list[str]


class GenerateRecipesResponse(BaseModel):
    recipes: list[Recipe]


class StoredRecipe(BaseModel):
    """A recipe as kept in the database: its full ingredient list, not yet
    split into used/missing for a particular user."""

    id: str
    name: str
    description: str
    cooking_time_minutes: int = Field(ge=1)
    servings: int = Field(ge=1)
    difficulty: Literal["easy", "medium", "hard"]
    category: Category = "meat"
    # Absolute URL, or a path relative to the API's base URL (e.g.
    # "/images/chicken-adobo.jpg"). None when there is no photo yet.
    image_url: str | None = None
    # Who took the photo and its license, e.g. "Photo: Jane Doe, CC BY-SA 4.0".
    image_credit: str | None = None
    ingredients: list[str] = Field(min_length=1)
    steps: list[str] = Field(min_length=1)


class RecipeListResponse(BaseModel):
    recipes: list[StoredRecipe]


class ErrorResponse(BaseModel):
    detail: str
