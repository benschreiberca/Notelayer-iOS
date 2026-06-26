---
title: Testing
last_updated: 2026-06-25
status: active
scope: notelayer-ios
group: governance
tags: [testing, xcuitest, insights, validation]
related: [DEVELOPMENT_SETUP.md]
---

# Testing

---

## Unit Tests

**Target:** `NotelayerInsightsTests`

| Test file | Covers |
|-----------|--------|
| `InsightsAggregatorTests.swift` | Insights computation logic |
| `VoiceTaskParserTests.swift` | Voice NLP parsing rules |
| `SharedItemTests.swift` | Share extension data contract |

Run from Xcode: `⌘U` with scheme set to `Notelayer`.

---

## Insights Validation

Before shipping any Insights change, verify these manually:

**Data accuracy:**
- [ ] Completion rate matches manual count for test period
- [ ] Category breakdown percentages sum to 100%
- [ ] Streak count resets correctly after a missed day
- [ ] Oldest open tasks sorted by creation date (oldest first)
- [ ] "Most Active Hours" reflects actual task creation/completion times

**UI:**
- [ ] All chart axes have plain-English labels (no raw field names)
- [ ] Empty state shows when no data available (not a blank screen)
- [ ] Drilldown navigation returns to correct parent screen
- [ ] Category deep-link from Insights → Todos Category view works
- [ ] Bottom clearance correct — last row visible above floating tab

**Telemetry:**
- [ ] `insights_drilldown_opened` fires when drilling into any section
- [ ] Local telemetry store updated after task actions
- [ ] Insights history not corrupted after sign-out/sign-in

---

## Screenshot Tests

**Target:** `NotelayerScreenshotTests`

Automated screenshot generation for App Store assets. See `_archive/AUTOMATED_SCREENSHOT_USAGE.md` for setup.

Run:
```bash
xcodebuild test -workspace ios-swift/Notelayer/Notelayer.xcworkspace \
  -scheme NotelayerScreenshotTests \
  -destination "platform=iOS Simulator,name=iPhone 15 Pro Max"
```

---

## Auth Testing Checklist

Before any auth-related change:

- [ ] Tap Apple Sign-In immediately after sheet appears (< 100ms) — should not crash
- [ ] Tap Google Sign-In immediately after sheet appears — should not crash
- [ ] Rapidly tap both auth buttons — only one flow should start
- [ ] Dismiss sheet during phone verification — graceful, no crash
- [ ] Sign in → sign out → sign back in — data preserved
- [ ] Guest mode → sign in — local data merges, no duplication
- [ ] Test on slow network — loading states show, no timeout crash

---

## Share Extension Testing

- [ ] Share plain text from Safari → task created in Notelayer
- [ ] Share URL from any app → task created with URL in notes
- [ ] Share large text (> 10,000 chars) → truncated with warning
- [ ] Share from ChatGPT → parsed into multiple task drafts
- [ ] App group data available immediately on next app foreground
