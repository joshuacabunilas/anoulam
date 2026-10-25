import os
import tempfile
from pathlib import Path

# Must run before `app` is imported: settings are read at import time.
# Tests use a throwaway database and the free source by default.
_tmp = Path(tempfile.mkdtemp())
os.environ["RECIPE_DB_PATH"] = str(_tmp / "test_recipes.db")
os.environ["RECIPE_SOURCE"] = "database"
