# PRD 12 — Category Safety: Preserve Existing & Revert

**Created:** 2026-06-15  
**Updated:** 2026-06-15 — rewritten to match iOS WelcomeView.swift source and updated HTML mockup  
**Status:** Approved — ready to implement  
**Scope:** Onboarding flow + Category Manager  
**Reference mockup:** `PRD_12_Category_Safety_Onboarding_Example.html` (same folder)  
**iOS source:** `Notelayer-iOS/ios-swift/Notelayer/Notelayer/Views/WelcomeView.swift`

---

## Problems Being Fixed

1. The new user onboarding was showing 8 fixed default categories. The iOS app actually uses a **3-preset picker** — users choose their starting structure. The Chrome extension must match this.
2. Existing users with custom categories were being told "We've set up categories for you" — alarming and inaccurate.
3. Neither onboarding flow had a **Back button** — users were stuck if they tapped forward too fast.
4. There is no way to recover custom categories after a reset or bulk delete.

---

## Onboarding Flow — New User (empty categories)

Detected by: `categories.length === 0` at the moment onboarding triggers.

**Step 1 — Intro**
1. Title: "Quick Orientation"
2. Body: video placeholder box with play icon and caption
3. "Skip intro video →" link appears after 3 seconds
4. Nav bar: **Back** (disabled, nothing before step 1) | title "Get Started" | **Skip** (exits onboarding immediately)
5. Primary CTA: "Next"

**Step 2 — How It Works**
6. Title: "How Notelayer Works"
7. Three cue rows (icon + text):
   - Tasks can live in multiple categories at once
   - Switch views: List, Priority, Category, Date
   - Experimental features can be enabled later from settings
8. Nav bar: **Back** (returns to step 1) | title "How It Works" | **Skip**
9. Primary CTA: "Next"

**Step 3 — Choose Starting Categories**
10. Title: "Choose Starting Categories"
11. Three selectable preset cards — **Everyday Balance is pre-selected and marked "Recommended"**

| Preset | Categories |
|---|---|
| **Everyday Balance** *(Recommended)* | 🧠 Personal · 💼 Work · 🏠 Home · 🩺 Health · 📈 Finance and Investing · 🗂️ Someday |
| **Life Admin** | 📋 Personal Admin · 🛒 Errands · 👨‍👩‍👧‍👦 Family and Home · 🧘 Health and Wellness · 🏦 Banking and Bills · 🗂️ Someday |
| **Growth and Projects** | 🧱 Work Projects · 🛠️ Personal Projects · 📚 Learning · 🤝 Relationships · 📈 Finance and Investing · 🗂️ Someday |

12. Selected card: accent border + accent-dim background fill + filled circle indicator
13. Primary CTA label updates dynamically: **"Start with [Selected Preset Name]"**
14. Secondary link below CTA: **"Keep Current Categories"** (always visible — escape hatch)
15. Nav bar: **Back** (returns to step 2) | title "Starting Categories" | **Skip**
16. On primary CTA: apply the selected preset's categories to Firestore, then close onboarding
17. On "Keep Current Categories" or Skip: close onboarding without writing any categories

**Progress dots:** 3 dots, active dot expands to pill shape. Advance and retreat with steps.

---

## Onboarding Flow — Existing User (categories already present)

Detected by: `categories.length > 0` at the moment onboarding triggers.

**Step 1 — Welcome Back**
18. Title: "Welcome Back"
19. Body: "Your tasks, notes, and categories are exactly as you left them — nothing was changed on sign-in."
20. Four cue rows (right-click to save, 4 views, Insights, keyboard shortcut)
21. Nav bar: **Back** (disabled) | title "Get Started" | **Skip**
22. Primary CTA: "Next"

**Step 2 — Your Categories (preserved)**
23. Title: "Your Categories"
24. Green confirmation banner: checkmark icon + **"Your categories are ready"** (bold) + "We found your existing setup and kept it exactly as-is. Nothing was overwritten."
25. Section label: "Your current categories"
26. Display the user's actual live categories as pills (fetched from Firestore, not hardcoded)
27. Body note: "You can always add, edit, or reorder categories from ⋯ → Manage Categories."
28. Nav bar: **Back** (returns to step 1) | title "Your Categories" | **Skip**
29. Primary CTA: **"Continue"** — neutral label, implies no action was taken (never "Looks Good")

**Step 3 — Quick Tips**
30. Title: "Quick Tips"
31. Four tip rows: right-click to save · tap task to edit · pin notes · drag to reorder
32. Nav bar: **Back** (returns to step 2) | title "Quick Tips" | **Skip**
33. Primary CTA: "Start Using Notelayer"

**Progress dots:** same 3-dot behaviour as new user flow.

---

## Category Manager — Reset & Restore

**Snapshot behaviour**
34. Every time the user saves a category edit (create, rename, reorder, delete), write a snapshot of the full category list to `chrome.storage.local` key `notelayer_cat_snapshot`
35. Snapshot is a JSON array of the current `Category[]` before the change is applied — i.e. it captures the last known good state

**"Restore My Categories" button**
36. Appears at the bottom of the manager only when `notelayer_cat_snapshot` exists
37. Green styling (green-dim background, green border)
38. Label: **"Restore My Categories"** with subtext "Bring back your last saved category setup"
39. On tap: delete all current Firestore categories, write snapshot categories back to Firestore

**"Reset to Defaults" button**
40. Always visible, below Restore (or alone when no snapshot exists)
41. Neutral/red styling; no background until primed
42. Label: **"Reset to Defaults"** with subtext "Replace all categories with the 8 built-in defaults"
43. First tap: button turns red-tinted, text changes to "Tap again to confirm reset" — reverts after 3 seconds if not confirmed
44. Second tap (within 3 s): snapshot current categories first, then delete all, then re-seed 8 defaults
45. Note at bottom: "Categories auto-snapshotted on each edit" (or "Edit any category to create a restorable snapshot" when no snapshot exists yet)

---

## Codebase Impact

| File | Change |
|---|---|
| `OnboardingFlow.tsx` | Full rewrite: 3-step flow, `isExistingUser` prop branches both paths, Back button on all steps, preset picker with 3 cards on new-user step 3 |
| `App.tsx` | Compute `isExistingUser = categories.length > 0` before rendering `OnboardingFlow`; pass as prop. Remove `seedDefaultCategories()` auto-call — categories are now set only via preset selection |
| `CategoryManager.tsx` | Add snapshot read/write via `chrome.storage.local`; Restore button (conditional), Reset button (two-tap confirm with 3 s timeout) |
| `firestore.ts` | Add `applyPresetCategories(uid, categories)` — deletes existing and writes preset; add `resetToDefaultCategories(uid)` — deletes all, re-seeds 8 defaults |
| `types.ts` | No changes needed |

---

## Implementation Order

1. `firestore.ts` — add `applyPresetCategories` and `resetToDefaultCategories`
2. `OnboardingFlow.tsx` — full rewrite with both paths and Back buttons
3. `App.tsx` — pass `isExistingUser`, remove auto-seed call
4. `CategoryManager.tsx` — snapshot logic, Restore + Reset buttons
