"""Matches a user's ingredients against stored recipes."""

import re
from collections.abc import Iterable

from .schemas import Recipe, StoredRecipe

# Assumed to be in every kitchen; never required and never "missing".
PANTRY_STAPLES = {"salt", "pepper", "black pepper", "oil", "cooking oil", "water"}

# Words that describe a form or cut, not a different ingredient:
# "chicken breast" -> "chicken", "ground beef" -> "beef".
_DESCRIPTORS = {
    "fresh", "frozen", "canned", "dried", "ground", "minced", "chopped",
    "sliced", "diced", "large", "small", "ripe", "raw", "cooked", "leftover",
    "boneless", "skinless", "whole", "breast", "thigh", "leg", "wing",
    "drumstick", "fillet", "loin", "belly", "chop", "clove", "piece",
}

# Common alternative names -> the name used in recipes.
_ALIASES = {
    "scallion": "green onion",
    "spring onion": "green onion",
    "red onion": "onion",
    "white onion": "onion",
    "shallot": "onion",
    "aubergine": "eggplant",
    "talong": "eggplant",
    "spaghetti": "pasta",
    "penne": "pasta",
    "fettuccine": "pasta",
    "linguine": "pasta",
    "elbow macaroni": "macaroni",
    "white rice": "rice",
    "brown rice": "rice",
    "jasmine rice": "rice",
    "cheddar": "cheese",
    "mozzarella": "cheese",
    "parmesan": "cheese",
    "mayo": "mayonnaise",
    "tuna flake": "tuna",
    "oatmeal": "oat",
    "rolled oat": "oat",
    "pechay": "bok choy",
    "repolyo": "cabbage",
    "monggo": "mung bean",
    "sitaw": "string bean",
    "green bean": "string bean",
    "labanos": "radish",
    "water spinach": "kangkong",
    "egg noodle": "noodle",
    "pancit": "noodle",
    "bihon": "rice noodle",
    "vermicelli": "rice noodle",
    "sotanghon": "glass noodle",
    "capsicum": "bell pepper",
    "kalamansi": "calamansi",
    "laurel": "bay leaf",
    "all purpose flour": "flour",
    "all-purpose flour": "flour",
    "prawn": "shrimp",
    "hipon": "shrimp",
    "tokwa": "tofu",
    "bean curd": "tofu",
    "kalabasa": "squash",
    "pumpkin": "squash",
    "ampalaya": "bitter melon",
    "bitter gourd": "bitter melon",
    "chilli": "chili",
    "chile": "chili",
    "sili": "chili",
    "chili pepper": "chili",
    "bagoong": "shrimp paste",
    "hot dog": "hotdog",
    "sausage": "hotdog",
    "streaky bacon": "bacon",
    "sticky rice": "glutinous rice",
    "malagkit": "glutinous rice",
    "cocoa powder": "cocoa",
    "tablea": "cocoa",
    "yoghurt": "yogurt",
    "tanglad": "lemongrass",
    "courgette": "zucchini",
    "bun": "burger bun",
    "hamburger bun": "burger bun",
    "heavy cream": "cream",
    "whipping cream": "cream",
    "all purpose cream": "cream",
    "all-purpose cream": "cream",
    "graham": "graham cracker",
    "chicken stock": "chicken broth",
    "stock": "chicken broth",
    "broth": "chicken broth",
    "sweet corn": "corn",
    "garbanzo": "chickpea",
    "garbanzo bean": "chickpea",
    "chick pea": "chickpea",
    "corn starch": "cornstarch",
    "bread crumb": "breadcrumb",
    "panko": "breadcrumb",
    "nori": "seaweed",
    "saba": "banana",
    "mangga": "mango",
    "itlog": "egg",
    "manok": "chicken",
    "baboy": "pork",
    "baka": "beef",
    "kanin": "rice",
    "bawang": "garlic",
    "sibuyas": "onion",
    "kamatis": "tomato",
    "patatas": "potato",
    "luya": "ginger",
    "toyo": "soy sauce",
    "suka": "vinegar",
    "patis": "fish sauce",
    "gata": "coconut milk",
}

# Plural forms where simply dropping the "s" is wrong.
_IRREGULAR_SINGULARS = {
    "leaves": "leaf",
    "tomatoes": "tomato",
    "potatoes": "potato",
    "mangoes": "mango",
    "radishes": "radish",
    "peaches": "peach",
    "sandwiches": "sandwich",
    "noodles": "noodle",
    "chilies": "chili",
    "chillies": "chili",
    "chilis": "chili",
    "cookies": "cookie",
    "anchovies": "anchovy",
}


def normalize(ingredient: str) -> str:
    """Canonical form for matching: lowercase, singular, no descriptors,
    aliases resolved. `"2 Chicken Breasts"` -> `"chicken"`."""
    words = re.findall(r"[a-z]+(?:-[a-z]+)?", ingredient.lower())
    words = [_singular(w) for w in words]
    stripped = [w for w in words if w not in _DESCRIPTORS] or words
    name = " ".join(stripped)
    return _ALIASES.get(name, name)


def _singular(word: str) -> str:
    if word in _IRREGULAR_SINGULARS:
        return _IRREGULAR_SINGULARS[word]
    if len(word) > 4 and word.endswith("ies"):
        return word[:-3] + "y"
    # Not "ss" (glass) or "us" (glutinous, hummus, asparagus): not plurals.
    if len(word) > 3 and word.endswith("s") and not word.endswith(("ss", "us")):
        return word[:-1]
    return word


def match_recipes(
    recipes: Iterable[StoredRecipe], ingredients: list[str], limit: int
) -> list[Recipe]:
    """Recipes that use at least one of `ingredients`, best first.

    Recipes you can cook right now (nothing missing) come first. The rest are
    ranked by how many of your ingredients they use minus how many they're
    missing, so a dish using four of your items and missing two beats one
    using one and missing one. Ties go to fewer missing, then quicker.
    """
    have = {normalize(i) for i in ingredients} - PANTRY_STAPLES

    scored = []
    for recipe in recipes:
        needed = [i for i in recipe.ingredients if normalize(i) not in PANTRY_STAPLES]
        used = [i for i in needed if normalize(i) in have]
        if not used:
            continue
        missing = [i for i in needed if i not in used]
        scored.append(
            (
                (
                    0 if not missing else 1,
                    len(missing) - len(used),
                    len(missing),
                    recipe.cooking_time_minutes,
                ),
                Recipe(
                    **recipe.model_dump(exclude={"ingredients"}),
                    used_ingredients=used,
                    missing_ingredients=missing,
                ),
            )
        )

    scored.sort(key=lambda item: item[0])
    return [recipe for _, recipe in scored[:limit]]
