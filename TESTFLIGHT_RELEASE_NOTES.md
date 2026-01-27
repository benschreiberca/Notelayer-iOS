# TestFlight Release Notes

## Version 1.1 - Build 4

---

## 🛠 UI POLISH & CONSISTENCY

We've tightened up the interface to make NoteLayer feel even more native to iOS.

**What's New:**
- **"The Big Red Button"**: Account deletion is now safely tucked into a droll accordion. No more accidental taps!
- **Cleaner Settings**: We've removed messy dividers in the Manage Account screen by grouping related information.
- **Dedicated Sign Out**: Sign Out now has its own home, making it easier to find without cluttering your data settings.
- **Pixel-Perfect Alignment**: Reminder icons now align perfectly with section headers for a cleaner, more symmetrical look.
- **Official Branding**: You'll now see the official NoteLayer logo on our website links.

---

## 🔔 NEW: Task Reminders

Never forget a task! Set reminders and get notifications right when you need them.

**What's New:**
- Set reminders with quick presets (30 mins, 90 mins, 3 hours, tomorrow 9 AM) or pick any date/time
- Get notified with task title and category icons
- Tap notifications to complete the task or open it instantly
- See all upcoming reminders in Settings → Reminders (swipe to cancel)
- Bell icon shows on tasks with reminders
- Edit reminders by tapping them in task details
- Reminders sync across your devices

**How to Use:**
- Long-press any task → "Set Reminder"
- OR open task details → Reminder section → "Set Reminder"
- Manage all reminders in Profile & Settings → Reminders

---

## Copy/Paste Options for TestFlight

### Option 1: Ultra-Short (280 characters)
```
🔔 NEW: Task Reminders! Set quick presets (30m, 90m, 3h, tomorrow 9AM) or custom times. Get notified with task title + categories. Tap notification to complete or open task. Manage all reminders in Settings. Long-press any task → "Set Reminder" to get started!
```

### Option 2: Short (500 characters)
```
🔔 Task Reminders are here! Never forget a task again.

✨ Quick presets: 30 mins, 90 mins, 3 hours, tomorrow 9 AM
✨ Custom date/time picker for precise control
✨ Notifications show task title + category icons
✨ Tap notification to complete or open the task
✨ Bell icon on tasks with reminders
✨ Manage all reminders in Settings → Reminders
✨ Syncs across your devices

Long-press any task → "Set Reminder" or open task details to get started!
```

### Option 3: Detailed (1000 characters)
```
🔔 TASK REMINDERS ARE HERE!

Never forget an important task. Set reminders and get notifications exactly when you need them.

FEATURES:
✨ Quick Presets: 30 mins, 90 mins, 3 hours, tomorrow 9 AM
✨ Custom Date/Time: Pick any future date and time
✨ Smart Notifications: Shows task title with category icons
✨ Notification Actions: Tap to complete task or open it instantly
✨ Visual Indicator: Bell icon on tasks with active reminders
✨ Easy Editing: Tap reminder in task details to adjust time
✨ Reminders Settings: View all upcoming reminders (soonest first), swipe to cancel
✨ Permission Handling: Clear prompts, easy access to settings if needed
✨ Cross-Device Sync: Reminders stored in Firebase, notifications fire locally on each device
✨ Smart Cleanup: Auto-cancel when task completed or deleted

HOW TO USE:
• Long-press any task → "Set Reminder"
• OR open task details → Reminder section → "Set Reminder"
• Manage all in Profile & Settings → Reminders

Please test and share feedback!
```

### Option 4: Tweet-Style (Very Short - 140 characters)
```
🔔 Task Reminders! Set quick times (30m, 90m, 3h, tomorrow 9AM) or custom. Get notified. Long-press task → "Set Reminder". Settings page too!
```

---

## Previous Features

### Calendar Export (Build [previous])
Export tasks to your calendar with all details (title, date, categories, notes, priority). Tap calendar icon in task details or long-press menu → "Add to Calendar".

### Improved Authentication & Onboarding (Build [previous])
- Welcome screen with animated logo
- Redesigned sign-in with Google, Apple, and Phone auth
- Profile & Settings page with sync status
- Cheetah theme with speckled wallpaper
- Dynamic header that squeezes on scroll
