# What to Cook API

FastAPI backend for the Flutter app. Suggests recipes from a list of
ingredients by matching them against a local SQLite recipe database. Free:
no API keys, no external services.

Optionally, set `RECIPE_SOURCE=claude` to generate recipes with Claude instead
(paid; needs an Anthropic API key).

## Setup (once)

```bash
cd backend
python -m venv .venv
.venv\Scripts\activate            # macOS/Linux: source .venv/bin/activate
pip install -r requirements.txt -r requirements-dev.txt
copy .env.example .env            # macOS/Linux: cp .env.example .env
```

The `.env` file is optional; the defaults work. It is git-ignored.

## Run

```bash
uvicorn app.main:app --reload --port 8000
```

- Interactive docs: http://localhost:8000/docs
- Android emulator reaches it at `http://10.0.2.2:8000`
- Physical phone on the same Wi-Fi: start with `--host 0.0.0.0` and run the
  app with `--dart-define=API_BASE_URL=http://<your-PC-LAN-IP>:8000`

Run the app against it:

```bash
flutter run --dart-define=ENV=dev
```

## API

`POST /recipes/generate`

```json
{ "ingredients": ["egg", "rice", "soy sauce"] }
```

Returns `200`:

```json
{
  "recipes": [
    {
      "id": "egg-fried-rice-3f9a1c",
      "name": "Egg Fried Rice",
      "description": "...",
      "cooking_time_minutes": 15,
      "servings": 2,
      "difficulty": "easy",
      "used_ingredients": ["egg", "rice", "soy sauce"],
      "missing_ingredients": ["green onion"],
      "steps": ["..."]
    }
  ]
}
```

Errors are `{"detail": "<message safe to show users>"}`:

| Status | When |
|---|---|
| 422 | Invalid input (1 to 30 ingredients, each 1 to 50 characters) |
| 500 | Unexpected server error |

No matches is not an error: you get `200 {"recipes": []}`. With
`RECIPE_SOURCE=claude` there are also 502/503/504 for AI service problems.

`GET /recipes` lists every stored recipe (with its full `ingredients` list).

`GET /recipes/{id}` returns one recipe, or `404 {"detail": "Recipe not found."}`.

`GET /health` returns `{"status": "ok"}`.

## How matching works

`app/matching.py` normalizes both sides before comparing:

- Case and plurals: "Eggs" = "egg", "tomatoes" = "tomato"
- Descriptors: "chicken breast" = "chicken", "ground beef" = "beef"
- Aliases: "spaghetti" = "pasta", "scallion" = "green onion", "talong" = "eggplant"
- Pantry staples (salt, pepper, oil, water) are assumed and never "missing"

Ranking: recipes you can cook right now come first; the rest by how many of
your ingredients they use minus how many they're missing.

## Adding recipes

Edit `data/recipes.json` (keep `id`s unique; ingredient names short,
lowercase, singular) and restart the server. The database reloads itself
when the file changes. `pytest` checks the file is valid.

Each recipe has a `category` (rice, noodles, soup, egg, meat, seafood,
vegetable, bread, dessert, drink, snack). The app shows a matching
illustration when there's no photo.

## Adding photos

1. Use a photo you're allowed to use (your own, or a free license such as
   CC0 / CC BY / CC BY-SA from Wikimedia Commons, Unsplash or Pexels).
2. Resize to about 800 px wide and save as `data/images/<recipe-id>.jpg`.
3. In `data/recipes.json`, set `"image_url": "/images/<recipe-id>.jpg"` and
   `"image_credit": "Photo: <author> (<license>)"`. The credit is required
   whenever there is a photo, and is shown in the app.
4. Add a line to `data/images/CREDITS.md` with the source link.

Photos are served at `GET /images/<file>`.

## Configuration

Set in `.env` or the environment:

| Variable | Default | Notes |
|---|---|---|
| `RECIPE_SOURCE` | `database` | `database` (free) or `claude` (paid) |
| `MAX_RECIPES` | `20` | The app filters these on the phone |
| `RECIPE_DB_PATH` | `data/recipes.db` | |
| `ANTHROPIC_API_KEY` | | Only for `claude` |
| `CLAUDE_MODEL` | `claude-opus-5-5` | Only for `claude` |
| `CLAUDE_EFFORT` | `medium` | Only for `claude` |
| `CLAUDE_MAX_RECIPES` | `6` | Only for `claude` |
| `CLAUDE_TIMEOUT` | `90` | Seconds, only for `claude` |

## Tests

```bash
pytest
```

Tests use a temporary database and a fake Claude client: no API key needed,
no cost.
