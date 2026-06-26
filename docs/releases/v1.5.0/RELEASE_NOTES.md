---
title: Release Notes — v1.5.0
last_updated: 2026-06-06
status: active
scope: notelayer-ios
group: operations
---

# Release Notes — Notelayer 1.5.0

**Audience:** Internal / TestFlight testers  
**Date:** June 6, 2026

---

## What's New

### Streamlined Navigation
Two-tab interface — To-Dos and Insights. The Notes tab is removed from the bottom bar (code and data preserved, not deleted). Cleaner, more focused UX.

### All Features Now Standard
The Experimental Features toggle is gone from the gear menu. Voice input, task hierarchy, and full analytics are now available to all users without any gate. No "flask" icon, no toggle — everything is ready out of the box.

### Redesigned Onboarding
First-time users see a 4-step interactive flow:

1. **Welcome** — Hero splash, 60-second promise, Get Started CTA
2. **Category Selection** — Choose a preset (Everyday Balance / Life Admin / Growth & Projects) or start blank
3. **Add First Task** — Interactive task entry with optional category chip selection
4. **Celebration** — Checkmark animation, momentum-building closure

Onboarding is replayable at any time from gear menu → "Onboarding Guide."

### Actionable Insights
Category rows and Oldest Open Task rows in the Insights tab are now tappable:
- Tap a category → jumps to To-Dos in Category view, filtered to that category
- Tap a task → jumps to To-Dos and opens the task editor

Chevron icon (>) provides the tappable affordance.

---

## Testing Checklist

- [ ] Fresh install: onboarding auto-appears on first launch
- [ ] All 4 onboarding steps progress correctly
- [ ] Category preset selection works (tap toggles selection)
- [ ] Task entry in Step 3 works with optional category chips
- [ ] Task appears in To-Dos after onboarding completes
- [ ] Tab bar shows To-Dos + Insights only (no Notes)
- [ ] Voice input works (no gate — tap microphone)
- [ ] Insights tab always visible (no gate)
- [ ] Category rows in Insights → tap → jump to To-Dos category view
- [ ] Oldest task rows in Insights → tap → open task editor
- [ ] Gear menu "Onboarding Guide" replays the full flow
- [ ] Light mode: no glitches
- [ ] Dark mode: no glitches
- [ ] Smooth scrolling throughout
- [ ] No crashes

---

## Known Limitations

- Insights analytics are local to each device. Cross-device analytics not yet supported.
- Voice capture remains functional but UI refinements are ongoing.
- Subtask hierarchy is functional but collapsed/expanded display is unpolished.
