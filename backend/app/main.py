import logging
import os
from contextlib import asynccontextmanager
from functools import lru_cache
from typing import Protocol

from fastapi import Depends, FastAPI, HTTPException, Request
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles

from .config import settings
from .database import RecipeDatabase
from .database_source import DatabaseRecipeSource
from .errors import RecipeGenerationError
from .schemas import (
    ErrorResponse,
    GenerateRecipesRequest,
    GenerateRecipesResponse,
    Recipe,
    RecipeListResponse,
    StoredRecipe,
)

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class RecipeSource(Protocol):
    async def generate(self, ingredients: list[str]) -> list[Recipe]: ...


@lru_cache
def get_database() -> RecipeDatabase:
    return RecipeDatabase(settings.db_path, seed_path=settings.seed_path)


@lru_cache
def get_recipe_source() -> RecipeSource:
    if settings.recipe_source == "claude":
        # Imported here so the free default never needs the Anthropic SDK.
        from .claude_source import ClaudeRecipeSource

        return ClaudeRecipeSource()
    return DatabaseRecipeSource(get_database())


@asynccontextmanager
async def lifespan(_: FastAPI):
    logger.info("Recipe source: %s", settings.recipe_source)
    if settings.recipe_source == "claude" and not os.getenv("ANTHROPIC_API_KEY"):
        logger.warning(
            "RECIPE_SOURCE=claude but ANTHROPIC_API_KEY is not set; "
            "/recipes/generate will fail. Add the key to backend/.env."
        )
    get_database()  # create and seed the database at startup
    yield


app = FastAPI(
    title="What to Cook API",
    version="1.0.0",
    description="Suggests recipes from the ingredients a user has.",
    lifespan=lifespan,
)


# Recipe photos: GET /images/<file>. Recipes reference them as
# "/images/<file>" in image_url.
settings.images_dir.mkdir(parents=True, exist_ok=True)
app.mount("/images", StaticFiles(directory=settings.images_dir), name="images")


@app.exception_handler(RecipeGenerationError)
async def _recipe_error_handler(_, exc: RecipeGenerationError) -> JSONResponse:
    headers = {"Retry-After": str(exc.retry_after)} if exc.retry_after else None
    return JSONResponse(
        status_code=exc.status_code,
        content={"detail": exc.message},
        headers=headers,
    )


@app.exception_handler(Exception)
async def _unexpected_error_handler(request: Request, exc: Exception) -> JSONResponse:
    # Keep the {"detail": ...} shape the app expects; details go to the log.
    logger.exception("Unhandled error on %s %s", request.method, request.url.path)
    return JSONResponse(
        status_code=500, content={"detail": "Something went wrong. Please try again."}
    )


@app.get("/health", tags=["system"])
async def health() -> dict[str, str]:
    return {"status": "ok"}


@app.get(
    "/recipes",
    response_model=RecipeListResponse,
    tags=["recipes"],
    summary="List all stored recipes",
)
def list_recipes(
    database: RecipeDatabase = Depends(get_database),
) -> RecipeListResponse:
    return RecipeListResponse(recipes=database.list_all())


@app.get(
    "/recipes/{recipe_id}",
    response_model=StoredRecipe,
    tags=["recipes"],
    summary="Get one stored recipe",
    responses={404: {"model": ErrorResponse, "description": "No such recipe"}},
)
def get_recipe(
    recipe_id: str,
    database: RecipeDatabase = Depends(get_database),
) -> StoredRecipe:
    recipe = database.get(recipe_id)
    if recipe is None:
        raise HTTPException(status_code=404, detail="Recipe not found.")
    return recipe


@app.post(
    "/recipes/generate",
    response_model=GenerateRecipesResponse,
    tags=["recipes"],
    summary="Suggest recipes for a list of ingredients",
    description=(
        "Returns up to MAX_RECIPES recipes that use the given ingredients, "
        "best match first. Each recipe lists which of your ingredients it "
        "uses and what you'd still need."
    ),
    responses={
        422: {
            "model": ErrorResponse,
            "description": "Invalid ingredient list, or no recipes possible",
        },
        502: {"model": ErrorResponse, "description": "AI service error (claude)"},
        503: {"model": ErrorResponse, "description": "Busy or unavailable"},
        504: {"model": ErrorResponse, "description": "AI timed out (claude)"},
    },
)
async def generate_recipes(
    body: GenerateRecipesRequest,
    source: RecipeSource = Depends(get_recipe_source),
) -> GenerateRecipesResponse:
    recipes = await source.generate(body.ingredients)
    return GenerateRecipesResponse(recipes=recipes)
