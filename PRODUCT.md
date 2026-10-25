# Product

<!-- impeccable:product-schema 1 -->

## Platform

android

## Users

Home cooks anywhere, with no specific age, region or skill level. They open the app at home when deciding what to cook, with a kitchen that already has some ingredients in it. The job: turn "what do I have?" into "what can I make?" quickly, then follow the recipe.

Filipino cooks are served especially well (see Positioning), but the app is not limited to them.

## Product Purpose

AnoUlam suggests dishes from the ingredients the user already has. The user lists or ticks ingredients, the app returns matching recipes, best match first, and shows for each one what they already have and what is still missing. Success is the user finding a dish they can cook now, or with one or two extra items, in a few taps, and cooking it from the steps in the app.

## Positioning

Compared with ingredient-first recipe finders such as Supercook:

- **Filipino-friendly:** strong coverage of Filipino dishes (adobo, sinigang, kare-kare, pancit, sisig, tinola and more) and understanding of local ingredient names (sibuyas, toyo, suka, kalabasa, tokwa, pechay, sitaw).
- **Recipes inside the app:** full ingredients and steps, with photos, are in the app. No sending the user out to other websites.
- **Free, no account:** no sign-up, ads or paid tier.
- **Simple and fast:** fewer options than Supercook, and fewer taps from opening the app to a dish.

## Operating Context

- Used on Android phones, typically in or near the kitchen.
- Main flow: ingredients screen (type, tap popular items, or tick items in a categorised checklist) → "Find recipes" → results (filters: ready to cook, under 30 min, easy, vegetarian, dish type) → recipe detail (have / still need, numbered steps).
- The user's ingredient list is saved on the phone and restored on the next open.

## Capabilities and Constraints

- Flutter app (Material 3), Android only. iOS is not planned for now.
- Backend: FastAPI REST API (`backend/`) backed by a local SQLite recipe database. It is free to run, with no paid services. An optional AI mode (`RECIPE_SOURCE=claude`) exists but is off by default because it costs money.
- Matching handles plurals, cuts and forms ("chicken breast" counts as chicken), alternative and Tagalog names, and assumes pantry staples (salt, pepper, oil, water).
- The app always uses the backend for recipes; there is no built-in mock data (removed 2026-10-25). Builds default to `ENV=dev` (local backend at 10.0.2.2:8000). Tests use a test-only fake in `test/helpers/`.
- Not decided yet: hosting for the backend (Render's free tier was suggested).
- The app is named **AnoUlam** (renamed from "What to Cook" on 2026-10-25), in the app bar and as the launcher label (`android:label`).

## Brand Commitments

- Name: **AnoUlam** (Tagalog for "what's the dish?"). Chosen by the owner on 2026-10-25. The name is the one deliberately Filipino element of the brand; the rest of the interface stays neutral as below.
- App icon: a bowl whose steam curls into a question mark, white on leaf green #17803F, with a small yellow dot. Splash: the same bowl on leaf green with the "AnoUlam" wordmark at the bottom, no tagline. Sources in `assets/brand/src/`; regenerate with `dart run flutter_launcher_icons` and `dart run flutter_native_splash:create`.
- Must stay free with no account, which rules out sign-up walls, ads and paywalls.
- The interface stays culturally neutral. Filipino fluency lives behind the scenes, in matching (Tagalog ingredient names) and in the recipe catalogue. It is not surfaced through Tagalog hints, "Pinoy" filters or sections. Decided 2026-10-25 after the first critique.

## Evidence on Hand

- 111 recipes in `backend/data/recipes.json`, written for this project.
- 106 recipe photos in `backend/data/images/`, all from Wikimedia Commons under free licences (public domain, CC0, CC BY, CC BY-SA). Credits are shown in the app and listed in `backend/data/images/CREDITS.md`. 5 recipes have no photo and use an illustrated header.
- There are no users, ratings, reviews, testimonials, download counts or press yet. Do not invent any.

## Product Principles

1. **Start from the kitchen, not the cookbook.** Every flow begins with what the user has, and results are ranked by what they can make now.
2. **Few taps to a dish.** Prefer fewer, clearer options over completeness, and keep the path from opening the app to cooking short.
3. **Honest about what's missing.** Always show which ingredients the user lacks. Never imply a recipe is ready when it isn't, and never show a wrong photo.
4. **Global, Filipino-fluent.** Work for anyone, while treating Filipino dishes and ingredient names as first-class.
5. **Free and accountless.** Nothing should require sign-up or payment.

## Accessibility & Inclusion

No user-specific requirement has been stated. The current implementation meets WCAG AA text contrast in light and dark themes, works at 200% system text size, and supports screen readers (labelled controls, headings, live announcements). Automated tests enforce this; keep it at least at this level.
