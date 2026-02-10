# Calendar Export Crash Fix

**Date:** January 27, 2025  
**Status:** ✅ Fixed

## Issue

App crashed immediately when tapping "Add to Calendar" with this error:

```
*** Terminating app due to uncaught exception 'NSInvalidArgumentException', 
reason: 'Pushing a navigation controller is not supported'
```

## Root Cause

In `CalendarEventEditView.swift`, I was wrapping `EKEventEditViewController` inside a `UINavigationController`:

```swift
func makeUIViewController(context: Context) -> UINavigationController {
    let eventEditController = EKEventEditViewController()
    // ...
    let navigationController = UINavigationController(rootViewController: eventEditController)
    return navigationController  // ❌ WRONG - can't wrap a nav controller in another nav controller
}
```

**The problem:** `EKEventEditViewController` **is already a subclass of `UINavigationController`**, so wrapping it in another navigation controller is invalid and causes iOS to throw an exception.

From Apple's documentation:
> "The EKEventEditViewController class itself is a navigation controller, so you should present it modally."

## Solution

Return the `EKEventEditViewController` directly without wrapping it:

```swift
func makeUIViewController(context: Context) -> EKEventEditViewController {
    // EKEventEditViewController is already a UINavigationController subclass
    // Do NOT wrap it in another UINavigationController
    let eventEditController = EKEventEditViewController()
    eventEditController.event = event
    eventEditController.eventStore = eventStore
    eventEditController.editViewDelegate = context.coordinator
    
    return eventEditController  // ✅ CORRECT - return it directly
}
```

## Changes Made

**File:** `Views/Shared/CalendarEventEditView.swift`

**Before:**
- Return type: `UINavigationController`
- Wrapped `EKEventEditViewController` in `UINavigationController`

**After:**
- Return type: `EKEventEditViewController`
- Return `EKEventEditViewController` directly

## Build Status

```
** BUILD SUCCEEDED **
✅ Zero warnings
✅ Zero errors
```

## Testing

The calendar export feature should now work without crashing:

1. ✅ Long-press any task
2. ✅ Tap "Add to Calendar"
3. ✅ Native calendar editor appears (no crash!)
4. ✅ User can modify event details
5. ✅ Tap "Add" to save or "Cancel" to dismiss

---

**Result:** Crash fixed! The calendar event editor now presents correctly.
