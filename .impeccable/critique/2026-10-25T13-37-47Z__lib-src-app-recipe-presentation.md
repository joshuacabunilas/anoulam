---
target: lib/src/app/recipe/presentation
total_score: 25
max_score: 40
na_heuristics: 
p0_count: 0
p1_count: 2
target_identity: "file:C:\\Users\\IT\\Desktop\\Mobile\\lib\\src\\app\\recipe\\presentation"
timestamp: 2026-10-25T13-37-47Z
slug: lib-src-app-recipe-presentation
closed: true
---
Method: design review only (detector not applicable, native platform)

Target: lib/src/app/recipe/presentation (ingredients -> results -> recipe detail). Code review of all pages/blocs/widgets plus emulator screenshots from this session; Browse-ingredients checklist and results filters reviewed from code only (build failed: corrupted Gradle cache).

## Design Health Score
| # | Heuristic | Score | Key Issue |
|---|---|---|---|
| 1 | Visibility of System Status | 3 | Cold-start wait (~1 min on free hosting) shows only a spinner |
| 2 | Match System / Real World | 3 | Tagalog names work but UI never signals it |
| 3 | User Control and Freedom | 2 | Clear all wipes saved pantry, no undo; filters reset on back; can't edit query from results |
| 4 | Consistency and Standards | 2 | Popular "Egg/Tomato/Potato/Banana" vs checklist "Eggs/Tomatoes/Potatoes/Bananas" |
| 5 | Error Prevention | 2 | Plural pairs create duplicates; destructive clear; unmatched free text accepted silently |
| 6 | Recognition Rather Than Recall | 3 | Results page doesn't show searched ingredients; no autocomplete |
| 7 | Flexibility and Efficiency | 2 | No autocomplete, recents, favourites |
| 8 | Aesthetic and Minimalist Design | 3 | Ingredients page stacks 12 chips + list + 9 cards; 20 tall photo cards |
| 9 | Error Recovery | 3 | Clear messages + Retry; no-match state lacks specific guidance |
| 10 | Help and Documentation | 2 | Staples assumption and matching never explained |
| Total | | 25/40 | Acceptable |

## Design Specificity Verdict
Half-authored: palette, typography, credited photos, have/need honesty and category illustrations are specific; structure is generic Material list app. Biggest miss: Filipino fluency (PRODUCT.md differentiator) is invisible in the UI. Deterministic scan: not applicable (native platform).

## What's Working
1. Honest have/need split with icon+wording, not colour alone.
2. Low-typing, remembered input: Popular chips, 115-item checklist guaranteed to match, saved pantry.
3. Credited photos with illustrated fallback for loading/failure/no photo.

## Priority Issues
- [P1] Popular vs checklist singular/plural mismatch creates duplicates and inconsistent ticked state. Fix: one canonical name per ingredient (Popular sourced from IngredientHelper), plural-insensitive contains(), ticked state reflected everywhere. Command: /impeccable harden
- [P1] "Clear all" (and chip delete) destroys the persisted pantry with no undo. Fix: Material snackbar "Cleared N ingredients" with Undo. Command: /impeccable harden
- [P2] Results page doesn't show the query; editing means going back and loses filters. Fix: "Using: egg, rice, tomato +3 · Edit" row; preserve filter state. Command: /impeccable layout
- [P2] Ingredients page buries "Your ingredients" between Popular and categories; Popular chips vanish on tap, reflowing under the thumb. Fix: list directly under search; Popular as selectable chips that stay in place. Command: /impeccable layout
- [P2] Long backend cold-start wait looks like a hang. Fix: after ~5 s, "Waking up the recipe server..." message plus Cancel. Command: /impeccable clarify

## Persona Red Flags
Casey: Clear all in top-right with no undo; Popular chips reflow; filter wall at top. Jordan: "chocolate" -> "No recipes found" with no guidance; staples assumption unexplained. Riley: Egg + Eggs duplicate saved and sent; "asdf" accepted silently.

## Minor Observations
Up to 11 dish-type chips (>4 options); 20 tall cards = long scroll; kebab icon for every meat dish; filter preferences not remembered; no Material You dynamic colour (acceptable brand choice).

## Questions to Consider
Pantry as home screen with live results? What does visibly Filipino-fluent look like? Best 8 + Show more instead of 20?
