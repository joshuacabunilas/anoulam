"""Recipe source backed by the local recipe database (free, default)."""

from .config import settings
from .database import RecipeDatabase
from .matching import match_recipes
from .schemas import Recipe


class DatabaseRecipeSource:
    def __init__(self, database: RecipeDatabase):
        self._database = database

    async def generate(self, ingredients: list[str]) -> list[Recipe]:
        return match_recipes(
            self._database.list_all(), ingredients, limit=settings.max_recipes
        )
