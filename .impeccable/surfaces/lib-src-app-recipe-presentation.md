---
version: 1
slug: "lib-src-app-recipe-presentation"
primary_target: "lib/src/app/recipe/presentation"
related_targets: []
---

MODE: operate (Android, Material 3; navigation and controls stay native)

THESIS: Cooking from what you have feels like shopping a fresh market: you fill a basket, and the basket tells you what you can make.

OWN-WORLD: Fresh market basket (chosen 2026-10-25 from the safer re-roll, replacing colour-field cookbook). Polished grocery-app warmth: white ground, deep green-black ink, leaf green for actions and selection, soft produce tints per pantry category, rounded cards with a gentle shadow, photos as the hero. Not dark, not childish, not a generic template.

STORY: Home: search with suggestions, your basket as green chips, then "Browse the market": nine tinted category tiles (a green count badge marks picks) that open a bottom sheet of tick chips. The dark basket bar pinned at the bottom shows category badges, the count and "See recipes". Results: rounded photo cards with a white status pill on the photo ("Ready to cook" / "+ N ingredients") and "Needs vinegar" under the name. Recipe: photo header with a rounded sheet edge, green "have" and red "need" pills, green numbered steps.

SIGNATURE MOVE: The basket bar: an always-visible dark bar with overlapping category-tinted badges of what you've added, the count, and the leaf-green "See recipes" button. Stacks (button below) at large text.

FORM: seed:1701717e383a4247 (safer register, grounded pick). Type: DM Sans 400/600/800; headings 800 at -0.02em. Radius 14 (fields, buttons, tiles), 18 (cards, sheets); chips are pills. Palette in ColorHelper; tints in FoodTints (theme extension), shared by pantry categories and recipe illustration fallbacks.

FINISH: AA contrast on every pair including all tints (tests enforce); 200% text keeps tiles (2 columns), cards and basket bar readable; dark theme with deepened tints; reduce-motion respected; photo credits stay.
