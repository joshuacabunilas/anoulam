"""SQLite storage for recipes.

`data/recipes.json` is the source of truth. The database is created on first
use and reloaded from that file whenever the file changes, so editing the
JSON and restarting the server is all it takes to update recipes.
"""

import hashlib
import json
import sqlite3
from collections.abc import Iterator
from contextlib import contextmanager
from pathlib import Path

from .schemas import StoredRecipe

# Bump when the table layout changes; older databases are rebuilt.
_SCHEMA_VERSION = 2

_SCHEMA = """
CREATE TABLE IF NOT EXISTS recipes (
    id                   TEXT PRIMARY KEY,
    name                 TEXT NOT NULL,
    description          TEXT NOT NULL,
    cooking_time_minutes INTEGER NOT NULL,
    servings             INTEGER NOT NULL,
    difficulty           TEXT NOT NULL CHECK (difficulty IN ('easy', 'medium', 'hard')),
    category             TEXT NOT NULL,
    image_url            TEXT,
    image_credit         TEXT,
    steps                TEXT NOT NULL  -- JSON array of strings
);

CREATE TABLE IF NOT EXISTS recipe_ingredients (
    recipe_id TEXT NOT NULL REFERENCES recipes (id) ON DELETE CASCADE,
    position  INTEGER NOT NULL,
    name      TEXT NOT NULL,
    PRIMARY KEY (recipe_id, position)
);

CREATE TABLE IF NOT EXISTS meta (
    key   TEXT PRIMARY KEY,
    value TEXT NOT NULL
);
"""

_COLUMNS = (
    "id, name, description, cooking_time_minutes, servings, difficulty, "
    "category, image_url, image_credit, steps"
)


class RecipeDatabase:
    def __init__(self, db_path: Path, seed_path: Path | None = None):
        self._db_path = db_path
        db_path.parent.mkdir(parents=True, exist_ok=True)
        with self._connect() as conn:
            if conn.execute("PRAGMA user_version").fetchone()[0] != _SCHEMA_VERSION:
                conn.executescript(
                    "DROP TABLE IF EXISTS recipe_ingredients;"
                    "DROP TABLE IF EXISTS recipes;"
                    "DROP TABLE IF EXISTS meta;"
                )
                conn.execute(f"PRAGMA user_version = {_SCHEMA_VERSION}")
            conn.executescript(_SCHEMA)
        if seed_path is not None:
            self._sync_seed(seed_path)

    @contextmanager
    def _connect(self) -> Iterator[sqlite3.Connection]:
        # A short-lived connection per operation keeps this safe to use from
        # FastAPI's worker threads.
        conn = sqlite3.connect(self._db_path)
        conn.row_factory = sqlite3.Row
        conn.execute("PRAGMA foreign_keys = ON")
        try:
            with conn:  # commits on success, rolls back on error
                yield conn
        finally:
            conn.close()

    def _sync_seed(self, seed_path: Path) -> None:
        """Reload all recipes if the seed file changed since the last load."""
        raw = seed_path.read_bytes()
        digest = hashlib.sha256(raw).hexdigest()
        with self._connect() as conn:
            row = conn.execute(
                "SELECT value FROM meta WHERE key = 'seed_hash'"
            ).fetchone()
            if row is not None and row["value"] == digest:
                return
            conn.execute("DELETE FROM recipes")
            _insert(conn, _parse_seed(raw))
            conn.execute(
                "INSERT OR REPLACE INTO meta VALUES ('seed_hash', ?)", (digest,)
            )

    def add_many(self, recipes: list[StoredRecipe]) -> None:
        with self._connect() as conn:
            _insert(conn, recipes)

    def list_all(self) -> list[StoredRecipe]:
        with self._connect() as conn:
            rows = conn.execute(
                f"SELECT {_COLUMNS} FROM recipes ORDER BY name"
            ).fetchall()
            ingredients = _ingredients_by_recipe(conn)
        return [_to_recipe(row, ingredients.get(row["id"], [])) for row in rows]

    def get(self, recipe_id: str) -> StoredRecipe | None:
        with self._connect() as conn:
            row = conn.execute(
                f"SELECT {_COLUMNS} FROM recipes WHERE id = ?", (recipe_id,)
            ).fetchone()
            if row is None:
                return None
            ingredients = _ingredients_by_recipe(conn, recipe_id)
        return _to_recipe(row, ingredients.get(recipe_id, []))


def _insert(conn: sqlite3.Connection, recipes: list[StoredRecipe]) -> None:
    for r in recipes:
        conn.execute(
            f"INSERT INTO recipes ({_COLUMNS}) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
            (
                r.id,
                r.name,
                r.description,
                r.cooking_time_minutes,
                r.servings,
                r.difficulty,
                r.category,
                r.image_url,
                r.image_credit,
                json.dumps(r.steps),
            ),
        )
        conn.executemany(
            "INSERT INTO recipe_ingredients VALUES (?, ?, ?)",
            [(r.id, i, name) for i, name in enumerate(r.ingredients)],
        )


def _ingredients_by_recipe(
    conn: sqlite3.Connection, recipe_id: str | None = None
) -> dict[str, list[str]]:
    query = "SELECT recipe_id, name FROM recipe_ingredients"
    params: tuple = ()
    if recipe_id is not None:
        query += " WHERE recipe_id = ?"
        params = (recipe_id,)
    result: dict[str, list[str]] = {}
    for row in conn.execute(query + " ORDER BY recipe_id, position", params):
        result.setdefault(row["recipe_id"], []).append(row["name"])
    return result


def _to_recipe(row: sqlite3.Row, ingredients: list[str]) -> StoredRecipe:
    return StoredRecipe(
        id=row["id"],
        name=row["name"],
        description=row["description"],
        cooking_time_minutes=row["cooking_time_minutes"],
        servings=row["servings"],
        difficulty=row["difficulty"],
        category=row["category"],
        image_url=row["image_url"],
        image_credit=row["image_credit"],
        ingredients=ingredients,
        steps=json.loads(row["steps"]),
    )


def _parse_seed(raw: bytes) -> list[StoredRecipe]:
    return [StoredRecipe(**item) for item in json.loads(raw.decode("utf-8"))]
