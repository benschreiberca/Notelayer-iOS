# Exploration: Notelayer Platform Expansion
**Date**: 2026-04-11
**Branch**: notelayer-variants
**Status**: Exploration — not yet ready for implementation planning

---

## Problem

Notelayer's capture and review loop currently only works when the user has their iPhone. Four high-value contexts go unserved:

1. **At a computer (browser)** — user reads something worth capturing but has to reach for their phone
2. **On their wrist (Apple Watch)** — user has a quick thought but their phone isn't in their hand
3. **On their wrist (Amazfit)** — same wrist use case, different hardware ecosystem
4. **At their Mac** — user is doing focused desktop work and wants task management without switching contexts to their phone

The ask is to extend Notelayer into all four of these contexts via a Chrome extension, an Apple Watch app, an Amazfit app, and a desktop app.

---

## What We're Trying to Solve

| Context | Pain | Goal |
|---|---|---|
| Browser | Capture friction — reading something useful requires switching to phone | Instant capture from the browser, no context switch |
| Wrist (Apple Watch) | Voice capture only works when phone is accessible | Quick-add tasks and see what's next from Watch |
| Wrist (Amazfit) | Same as Apple Watch, for a large and growing non-Apple wearable user base | Same wrist experience on Zepp OS hardware |
| Desktop | Phone-first UX doesn't map to keyboard + large screen | Native desktop task management with proper keyboard/mouse UX |

These are all **capture and review** problems. None requires the full iOS feature set on day one.

---

## Observations

- **Shared backend already exists**: Firebase/Firestore is the source of truth. All three platforms can read/write the same data with no additional backend work.
- **Firebase SDKs exist on all target platforms**: Firebase JS SDK (Chrome extension), Firebase Swift SDK (Watch), SwiftUI (macOS). Auth works everywhere.
- **The data model is clean**: `Task`, `Category`, `Note` are `Codable` structs. They can be used directly in a macOS SwiftUI target or a Watch target in the same Xcode project.
- **iOS code is SwiftUI-first**: Sharing model/service code with macOS and Watch is achievable. Sharing view code is more limited — Watch screen size and macOS idioms differ significantly.
- **The Share Extension is a precedent**: We've already done cross-app data sharing via App Group. The macOS and Watch targets can use the same App Group.

---

## Platform Options

### Platform 1: Chrome Extension

**What it is**: A browser extension popup that lets users capture tasks or notes while browsing. Could also offer a right-click context menu to "Save to Notelayer."

**Option A — Popup-only capture (MVP)**
A small popup (300×400px) with:
- A text field for quick task entry
- Category and priority selectors
- "Save" commits directly to Firestore
- Auth persisted in extension storage

Effort: Medium. Full separate codebase (HTML/CSS/JS + Firebase JS SDK). No code sharing with iOS.

**Option B — Full task view in popup**
Same as A, plus a scrollable list of today's tasks and done/not-done toggles.

Effort: High. Begins to feel like a full web app in a popup — risk of becoming a maintenance burden separate from the iOS source of truth.

**Option C — Sidebar panel (Chrome Side Panel API)**
Uses the Chrome Side Panel API (supported since Chrome 114) to open a full-height panel alongside any page — more space, better UX for reviewing a task list.

Effort: Medium-High. Better UX than popup but still separate codebase.

**Recommendation for Chrome**: Option A as MVP, with Option C as the natural next step. The goal is fast capture — a popup with a text field and Save is the right first unit. Avoid building a full task manager in the browser; that's the desktop app's job.

**Technical path**:
- Manifest V3 extension (required by Chrome)
- Firebase JS SDK v9 (modular, tree-shakeable — keeps extension bundle small)
- Firebase Auth with email/password or Google Sign-In (OAuth in extensions requires care with popup windows)
- Store auth token in `chrome.storage.local` (not `localStorage`)
- Write directly to Firestore `tasks` collection with the correct user ID

**Known complications**:
- Firebase Auth in Chrome extensions requires the extension to have its own OAuth redirect URI registered. Google Sign-In works but has quirks in MV3 — needs `chrome.identity` API.
- Firestore security rules must allow writes from the extension's auth token (they already do — any authenticated Firebase user can write).

---

### Platform 2: Apple Watch App

**What it is**: A watchOS companion that shows upcoming/active tasks and allows quick task creation via voice or text.

**Option A — Watch Connectivity (phone-tethered)**
Watch talks to the paired iPhone via `WCSession`. iPhone does all Firebase work. Data syncs via `WCSession.transferUserInfo` or `sendMessage`.

Pros: No separate Firebase setup on Watch. Uses existing iOS logic.
Cons: Requires iPhone to be in range and unlocked. Breaks if iPhone is off or out of Bluetooth range. `WCSession` is notoriously unreliable for real-time data.

**Option B — Independent Watch app (direct Firestore)**
Watch app has its own Firebase SDK and authenticates directly. Reads/writes tasks independently of the iPhone.

Pros: Works without iPhone. Reliable.
Cons: Requires Firebase Swift SDK on watchOS (supported since Firebase iOS SDK 8.x). Binary size impact. Auth tokens need to be shared from iPhone to Watch on first setup.

**Option C — Hybrid (local cache + WCSession sync)**
Watch maintains a local `[Task]` cache (persisted to UserDefaults). On launch, requests fresh data from iPhone via WCSession. Falls back to cached data if iPhone unavailable. Quick-add sends to iPhone queue; iPhone writes to Firestore.

Pros: Best UX — snappy on Watch, reliable for reads. Write queue handles offline.
Cons: More implementation work. Stale data risk if iPhone is off for extended periods.

**Recommendation for Watch**: Option C (hybrid). The dominant Watch use case is reading ("what's next?") not writing. Cached reads + WCSession sync + write queue gives a great wrist experience without the Firebase SDK complexity on watchOS.

**Feature scope for Watch MVP**:
- Glanceable task list: upcoming and in-progress tasks, sorted by priority/due date
- Tap to complete a task
- Quick-add via voice dictation (WKExtension speech framework)
- Complications: task count, next task title

**Technical path**:
- New watchOS target in the existing Xcode project
- Shared Swift package or framework for `Task`, `Category`, `Priority` models (already `Codable`)
- `WCSession` delegate in both iOS app and Watch extension
- `WKInterfaceController` or SwiftUI `@main` App on watchOS
- Write queue stored in Watch UserDefaults, flushed by iOS on WCSession activate

---

### Platform 3: Desktop App (macOS)

**What it is**: A native macOS application for Notelayer.

**Option A — Mac Catalyst**
Convert the existing iOS SwiftUI app to run on macOS via Mac Catalyst. Apple provides this as a checkbox in Xcode project settings.

Pros: Extremely fast — can have a running macOS app in hours. Shares 100% of iOS code.
Cons: Feels like an iPad app on a Mac. `UIKit` idioms don't translate: no menu bar extras, no keyboard shortcuts, popover UX is wrong, `UITabBar` looks out of place. Users notice.

**Option B — Native macOS SwiftUI (shared models, new views)**
New macOS target in Xcode. Shares: all data models, `LocalStore`, all Firebase service classes, `VoiceStateStore`, `InsightsAggregator`. New views written for macOS idioms: `NavigationSplitView` sidebar, `List`, `Table`, `NSMenu` integration, keyboard shortcuts.

Pros: Feels native. Shared business logic. Proper Mac UX.
Cons: New view layer — significant work. Roughly 60% code sharing (models + services), 40% new (views).

**Option C — Menu bar app only**
A lightweight macOS menu bar app (no Dock icon, lives in the menu bar). Clicking the icon opens a compact task list or quick-add popover.

Pros: Lowest friction for desktop capture. Always available. Smaller scope.
Cons: Not a "full" desktop experience. Doesn't replace the phone for power users.

**Option D — Electron / web app**
Build a web frontend that works in a browser and package it as an Electron app or progressive web app.

Pros: Code reuse with Chrome extension web layer.
Cons: Un-native UX. Heavy binary. No integration with macOS system features (Reminders, Calendar, Shortcuts). Inconsistent with the iOS app's design system.

**Recommendation for macOS**: Option B (native SwiftUI) with Option C (menu bar) as the first milestone. The menu bar is the fastest path to desktop value — always accessible, low friction, small scope. The full sidebar app follows once the menu bar foundation is solid. Option A (Catalyst) should be avoided — it produces a product that reflects poorly on the brand.

**Feature scope for macOS MVP (menu bar)**:
- Menu bar icon with unread/active task count badge
- Popover with scrollable task list
- Quick-add field
- Click task to open full edit in a native window
- Full macOS app window (sidebar + list) in subsequent milestone

---

### Platform 4: Amazfit App (Zepp OS)

**What it is**: A Mini Program for Amazfit watches running Zepp OS (GTR, GTS, T-Rex, Falcon series and others). Functionally similar to the Apple Watch app — glanceable task list, quick-add, complete from wrist.

**Runtime**: Zepp OS runs **JavaScript Mini Programs**, not Swift. This is a completely separate codebase from the Apple Watch target. The SDK is Zepp's own "Zeus" framework, with a React-like component model.

**How data gets to the watch**:

Zepp OS Mini Programs can communicate with the companion iOS app in two ways:

- **Option A — Side service (companion channel)**: A JavaScript "side service" runs on the phone and can make HTTP requests. The Mini Program on the watch sends messages to the side service, which calls Firebase directly. This keeps auth off the watch.
- **Option B — Cloud API**: Mini Program calls a backend HTTP endpoint (e.g., a Firebase Cloud Function) directly from the watch over Wi-Fi or phone's data connection. Simpler than Option A but requires a thin backend API layer.

**Recommendation for Amazfit**: Option A (side service). The Zepp side service can hold Firebase auth and make Firestore REST API calls on behalf of the watch. The watch itself sends simple message payloads (`{ action: "complete", taskId: "..." }`). This avoids managing auth tokens on the watch OS and mirrors the iOS WCSession pattern used for Apple Watch.

**Feature scope for Amazfit MVP**:
- Task list view (active tasks, sorted by priority)
- Tap to complete
- Quick-add via text input (Zepp OS has an on-device text entry widget for supported models; voice on others)
- Watch face widget / complication showing active task count

**Key constraints**:
- Zepp OS Mini Programs are published through the **Zepp App Store** (separate from Apple App Store) — requires a Zepp Developer account
- Mini Programs have limited local storage — task list must be refreshed from the phone
- UI is built with Zepp's own component library (`hmUI`) — no HTML/CSS, no SwiftUI
- Testing requires either physical Amazfit hardware or the Zepp OS Simulator (available in the Zepp Dev Tools)
- The side service JS runs on the paired iPhone inside the Zepp app sandbox — it cannot access iOS Keychain directly, so Firebase auth tokens must be passed from the Notelayer iOS app to the Zepp side service via a shared mechanism (likely UserDefaults in the same App Group if Zepp supports it, or a local HTTP server pattern)

**Honest complication**: The side service ↔ iOS app auth handoff is the hardest part of this integration. Zepp's companion protocol is less mature than WCSession. This platform has the most unknown implementation risk of the four.

---

## Recommended Sequencing

The three platforms are independent enough to be built in any order, but sequencing matters for effort and impact.

| Order | Platform | Rationale |
|---|---|---|
| 1 | **macOS** | Highest code sharing with existing iOS codebase. SwiftUI + Firebase Swift SDK — same stack. Immediate value for users who live in both iOS and Mac. Menu bar milestone is achievable quickly. |
| 2 | **Apple Watch** | Natural iOS companion. Models shareable. WCSession is a known pattern. Watch users are a high-intent subset of existing iOS users. |
| 3 | **Amazfit** | Same wrist use case as Apple Watch but separate codebase (JS + Zepp OS). Build after Apple Watch so the UX decisions are already made. Auth handoff complexity is the main risk — resolve that after the WCSession pattern is understood. |
| 4 | **Chrome Extension** | Completely separate codebase (JS). Different auth flow. Most useful for new user acquisition, but requires the iOS + Mac experience to already be solid. Best as a later growth move. |

**Note on wearables**: Apple Watch and Amazfit solve the same user problem. If forced to choose one wrist platform, Apple Watch comes first (same SDK ecosystem as iOS). Amazfit is additive — it expands reach to a large non-Apple wearable audience without competing with Watch users.

---

## PRD Delta

This expansion touches or requires new PRD documents in the following ways:

**New PRDs required (one per platform):**
- `PRD_09_macOS_App.md` — macOS target: menu bar MVP, full window milestone, shared model layer, auth flow
- `PRD_10_Apple_Watch_App.md` — watchOS target: WCSession sync, task list complications, quick-add, write queue
- `PRD_11_Amazfit_App.md` — Zepp OS Mini Program: side service auth pattern, task list, complete, quick-add, widget
- `PRD_12_Chrome_Extension.md` — MV3 extension: Firebase JS SDK, auth, popup capture, right-click context menu

**Existing PRDs affected:**
- `PRD_01_Experimental_Features_Framework.md` — The experimental features gate is iOS-specific. Does it apply to macOS/Watch? Probably not — macOS and Watch ship their own feature sets independently. Needs a decision.
- `PRD_04_Voice_Entry_Structured_Capture.md` — Voice capture on Watch uses a different mechanism (WKExtension vs iOS microphone). A Watch-specific voice section may be needed.
- `PRD_07_Share_To_Notelayer.md` — The Chrome extension is essentially a web-based share extension. The two PRDs should be aligned in intent.

**Shared infrastructure decisions needed (not currently in any PRD):**
- How are auth tokens shared from iOS to Watch? (First-time pairing flow)
- What Firestore security rules apply to extension-written tasks? (Currently covered but should be documented)
- Does the macOS app share the iOS App Group for UserDefaults, or use a separate one?
- Is there a cross-platform "last synced" timestamp visible to the user?

---

## Open Questions

1. **Is the macOS app a new product listing on the App Store or the same app (Universal Purchase)?** Universal Purchase (one purchase covers iOS + macOS) is the simpler path for paid apps. For free apps with in-app purchase, this needs a decision.

2. **What's the Watch's standalone story?** If a user doesn't have their iPhone, can they still see and complete tasks on Watch? Option C (hybrid) supports this if the local cache is populated. But initial setup always requires iPhone.

3. **Does the Chrome extension require its own Firebase project or reuse the iOS one?** It can reuse the same Firestore — but if you ever want to restrict extension writes separately, a separate project is cleaner. Recommendation: same project for now.

4. **What happens to voice task entry on macOS?** The iOS floating mic button doesn't translate. macOS has `NSSpeechRecognizer` or `SFSpeechRecognizer`. Does voice capture make sense on Mac? Could be a menu bar shortcut that starts a local recording.

5. **Is there a subscription or pricing model change implied by multi-platform?** Adding macOS, Watch, and Amazfit typically justifies a recurring subscription model rather than one-time purchase. This is a business decision, not a technical one, but it affects how the PRDs are framed.

6. **How does the Notelayer iOS app share auth state with the Zepp side service?** The Zepp side service runs in the Zepp app's sandbox on iPhone — it's not the same process as Notelayer. A local loopback HTTP approach or a shared Firestore custom token endpoint may be needed. This needs a proof-of-concept before committing to the Amazfit platform.

6. **What's the design system strategy?** The iOS app has a custom design system (DesignSystem.swift, ThemeManager, etc.). On macOS and Watch, the system appearance is less customizable. Does the custom theme system apply, or do macOS/Watch use system defaults?

---

## What's Ready

- **Backend**: Firebase/Firestore is ready for multi-platform. No backend changes needed.
- **Data models**: `Task`, `Category`, `Note`, `Priority` are all `Codable` and shareable across targets.
- **Firebase services**: `FirebaseBackendService`, `AuthService`, `LocalStore` logic can be refactored into a shared Swift package for reuse in macOS and Watch.
- **Concept**: All three platforms are clearly scoped at the MVP level.

## What's Still Ambiguous

- Auth sharing strategy between iOS and Watch
- macOS Universal Purchase vs separate listing decision
- Whether the experimental features gate applies to non-iOS platforms
- Design system scope for non-iOS surfaces
- Pricing model implications of multi-platform

---

## Next Implementation-Planning Step

Before any implementation planning begins, the following should be decided:

1. **Confirm sequencing** (macOS first, or a different order?)
2. **Decide macOS form factor for milestone 1** (menu bar only, or menu bar + window?)
3. **Answer the three auth/data questions** (App Group sharing, Firestore project, Watch standalone support)
4. **Write `PRD_09_macOS_App.md`** as the first concrete spec — it's the highest code-sharing, lowest-risk starting point

Once those four things are settled, the macOS target can move to implementation planning in a single focused session.
