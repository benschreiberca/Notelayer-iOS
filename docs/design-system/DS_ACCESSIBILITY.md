---
title: Design System — Accessibility
last_updated: 2026-06-25
status: active
scope: all-platforms
group: design-system
tags: [accessibility, contrast, motion, published]
related: [DS_TOKENS.md, DS_COMPONENTS.md]
source_of_truth_for: [notelayer-ios, notelayer-web]
---

# DS Accessibility

Requirements for contrast, motion, and color usage across all Notelayer platforms.

---

## Contrast

- **Primary text** (`textPrimary`) must maintain WCAG AA contrast (4.5:1) against `backgroundBase` in both light and dark modes.
- **Secondary text** (`textSecondary`) must remain readable on elevated surfaces (`backgroundElevated1`).
- **Interactive elements** (`interactivePrimary`) must pass AA contrast against the background they appear on.
- **Category chips:** category color text must be legible against the chip's 12.5% opacity background.

---

## Color Blindness

- Never rely on color alone to convey state.
- Use fill + outline OR icon markers in addition to color:
  - Task completion: checkbox shape changes (filled vs. empty ring), not color alone
  - Priority: text label ("High", "Med", "Low", "Def") in addition to any color indicator
  - Category chips: text label always present

---

## Motion

- Prefer subtle animations — short durations, ease-in-out curves.
- Avoid animations that loop indefinitely without user action.
- Respect `UIAccessibility.isReduceMotionEnabled` — hook not yet implemented, flagged for future.
- Haptic feedback: use for task completion and deletion. Do not use for passive scrolling events.

---

## Touch Targets (iOS)

- Minimum touch target: 44×44pt (Apple HIG requirement).
- Checkbox: 24pt visual size, 44pt touch target via padding.
- Row taps: full row is tappable, not just the label.

---

## VoiceOver

- All interactive elements must have meaningful accessibility labels.
- Task cards: label should include title + priority + due date if set.
- Category chips: label should include category name.
- Destructive actions: announce as "destructive" in accessibility traits.

---

## Platform Notes

| Platform | Specific requirements |
|----------|-----------------------|
| iOS | Dynamic Type supported; avoid fixed font sizes in custom views |
| Mac | Keyboard navigation for all interactive elements; focus rings visible |
| Watch | Large text by default; no fine motor assumptions |
| Web | ARIA labels; keyboard navigable; `:focus-visible` states |
