# UI Consistency Exceptions Registry

**Last Updated:** January 27, 2026  
**Project:** NoteLayer iOS

This file tracks intentional custom styling that should NOT be flagged by the `/ui-consistency` command.

---

## Active Exceptions

### Custom App Icon for Website Link
**Location:** `ios-swift/Notelayer/Notelayer/Views/ProfileSettingsView.swift` - About section, website link  
**Custom Element:** Custom HStack with Image("AppIcon") instead of Label with system icon  
**Reason:** Brand consistency - using the actual NoteLayer app icon instead of generic globe icon strengthens brand identity and makes the link more recognizable  
**Platform Standard Would Be:** `Label("Visit getnotelayer.com", systemImage: "globe")`  
**Approved By:** Ben on January 27, 2026  
**Status:** Active

---

## Deprecated Exceptions

*(Exceptions that are no longer needed - will be flagged on next consistency review)*

---

## Review Schedule

Review this file quarterly to ensure exceptions are still valid and necessary.
