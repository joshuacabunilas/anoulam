import os
from dataclasses import dataclass
from pathlib import Path

from dotenv import load_dotenv

# Reads backend/.env if present. Real environment variables take precedence.
load_dotenv()

_DATA_DIR = Path(__file__).resolve().parent.parent / "data"


@dataclass(frozen=True)
class Settings:
    # Where recipes come from: "database" (free, default) or "claude" (paid AI).
    recipe_source: str = os.getenv("RECIPE_SOURCE", "database")
    max_recipes: int = int(os.getenv("MAX_RECIPES", "20"))

    # Database source
    db_path: Path = Path(os.getenv("RECIPE_DB_PATH", str(_DATA_DIR / "recipes.db")))
    seed_path: Path = _DATA_DIR / "recipes.json"
    images_dir: Path = _DATA_DIR / "images"

    # Claude source (only used when RECIPE_SOURCE=claude). ANTHROPIC_API_KEY
    # is read by the Anthropic SDK itself; it is never stored here or logged.
    claude_model: str = os.getenv("CLAUDE_MODEL", "claude-opus-5-5")
    # low | medium | high | xhigh | max. Higher = better recipes but slower.
    claude_effort: str = os.getenv("CLAUDE_EFFORT", "medium")
    # Kept lower than MAX_RECIPES: each AI recipe costs time and money.
    claude_max_recipes: int = int(os.getenv("CLAUDE_MAX_RECIPES", "6"))
    # Seconds to wait for Claude before giving up on one request.
    claude_timeout: float = float(os.getenv("CLAUDE_TIMEOUT", "90"))


settings = Settings()
