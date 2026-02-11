# TestFlight Release Notes

## [2026-02-11] - The Tabs Learned Personal Space
- **What’s New**: The floating tab pill now keeps a consistent buffer at the bottom of Notes, To-Dos, Insights, and Insights drilldowns.
- **Why it matters**: The last card no longer gets sat on by navigation furniture.
- **What’s New**: “Features You’re Using in the App” now stays fully visible at the bottom of Insights when you scroll.
- **Why it matters**: The section stopped playing peekaboo.
- **What’s New**: Insights drilldown rows now follow one consistent pattern: name on the left, key number on the right, helpful detail underneath when needed.
- **Why it matters**: It’s easier to scan and compare without relearning each page.
- **What’s New**: The data-coverage card is now compact by default and expands when you tap it, and oldest open tasks have clearer dedicated views.
- **Why it matters**: Less visual noise up front, more detail only when you ask for it.

## [2026-02-10] - Your Dashboard Learned Manners
- **What’s New**: The floating bottom tabs now politely step aside when the keyboard appears, so typing fields stop playing hide-and-seek.
- **Why it matters**: You can edit without the UI sitting on top of your input.
- **What’s New**: Notes, To-Dos, and Insights now share a more consistent header rhythm with matching logo/settings behavior, while each tab keeps its own middle controls.
- **Why it matters**: The app feels less like three cousins and more like one product.
- **What’s New**: Insights now labels the section as `Features You're using in the App`, adds plain-language explainer text, and keeps the bottom card visible above the floating tab pill.
- **Why it matters**: You can tell what the numbers mean without decoding them like a puzzle hunt.
- **What’s New**: Behind the scenes, analytics tracking, docs structure, and Insights test coverage all got a substantial cleanup and expansion.
- **Why it matters**: Fewer regressions, clearer docs, better confidence when we ship fast.

## [2026-02-09] - Insights, but make it useful
- **What's New**: Added a full `Insights` tab after `To-Dos` with historical task trends, category analytics, feature usage, time-of-day patterns, and gap analysis.
- **Why it matters**: You can now see not just what tasks exist, but how you actually use Notelayer over time.
- **What's New**: Added progressive chart drill-downs (trend, category, usage, and gap detail), with Apple Health-style exploration flow and Swift Charts.
- **Why it matters**: You can move from overview to details without leaving context.
- **What's New**: Added local Insights telemetry storage with account scoping, retention/compaction, and category-attributed calendar/reminder events.
- **Why it matters**: Insights data stays consistent, avoids cross-account mixing, and scales as usage grows.

## [2026-02-08] - The Phone Took a Quiet Sabbatical
- **What's New**: Phone sign‑in has been removed from the UI. It’s not gone forever, it’s just not invited to this build.
- **Why it matters**: Fewer mysterious auth tantrums when you just want to get in.
- **What's New**: Email magic link is now the obvious front door again.
- **Why it matters**: You can sign in without a side quest.

## [2026-02-08] - The Auth Stopped Fainting (v1.4 build 2)
- **What's New**: Sign‑in and refresh now have their paperwork in order, so they stop collapsing on arrival.
- **Why it matters**: Fewer surprise exits when you just wanted to log in or sync.
- **What's New**: The manual refresh button took a graceful exit; syncing keeps itself in line.
- **Why it matters**: Less button mashing, more actual syncing.

## [2026-02-04 18:00 EST] - The App Started Keeping Receipts (v1.3 build 8)
- **What's New**: Notelayer now keeps a better diary of what you tap, where you roam, and which buttons you actually use.
- **Why it matters**: We can fix the right things faster instead of playing “guess what broke.”

## [2026-02-03] - The Analytics Now Confess
- **What's New**: Analytics stopped pretending and now actually reports in DebugView.
- **Why it matters**: You can verify events without guessing or yelling at the console.
- **What's New**: Build numbers march forward and the share extension finally matches the main app’s version.
- **Why it matters**: Shipping is less dramatic when everything agrees on the number.

## [2026-02-02] - The Theme Stopped Whispering
- **What's New**: Light themes now tint cards, groups, and backgrounds in the right order instead of only dyeing the accents.
- **Why it matters**: You can tell what's a card without squinting.
- **What's New**: Theme previews now respect the Light/Dark toggle instead of freelancing.
- **Why it matters**: The preview stopped dressing for midnight at noon.
- **What's New**: One theme keeps task cards crisp white for the clean‑linen crowd.
- **Why it matters**: Minimalism, now with fewer surprises.

## [2026-01-31] - The Great Category Shuffle
- **What's New**: Category groups can finally be dragged into the order you actually care about, in both the Categories tab and Manage Categories.
- **Why it matters**: Your important lists stop hiding behind the boring ones.
- **What's New**: “Uncategorized” now keeps its place across devices instead of wandering off.
- **Why it matters**: Your default bucket behaves like a grown-up.
- **What's New**: Task drag/drop feels more reliable, including dropping at the very end of a group.
- **Why it matters**: You can stop playing “guess the drop zone.”
- **What's New**: Phone sign‑in no longer shrugs you off from the Welcome screen, and auth errors speak human.
- **Why it matters**: You get in without drama.

## [2026-01-29] - The Share Sheet Finally Joined the Main Cast
- **What's New**: The Share Sheet now mirrors the Task Detail layout (standard iOS list, proper Notes + URL fields, same glassy feel), plus larger category chips.
- **Why it matters**: Shared tasks stop feeling like they were filed in a different universe.
- **What's New**: Theme selection now survives a force-quit, and dark themes finally got darker wallpapers.
- **Why it matters**: Your app stops waking up in the wrong outfit.
- **What's New**: Date/time pickers are consistent everywhere, and the "Add to Calendar" sheet stopped doing the open-close hokey-pokey.
- **Why it matters**: Scheduling no longer requires deep breathing.

## [2026-01-28] - The Share Sheet Grew a Spine
- **What's New**: When you share into Notelayer, you can now rename the task, pick categories, set priority, and add due dates or reminders before saving.
- **Why it matters**: Shared items arrive already organized instead of showing up as a blank shrug.

## [2026-01-27] - The AI Now Has a Personality
- **What's New**: We've given the internal "shipping" department a personality transplant. It has been instructed to stop sounding like a corporate robot and start sounding like a human with a slightly dry sense of humor.
- **Why it matters**: Your release notes will now be 15% more eccentric and 100% less boring. You're welcome.

## [2026-01-27] - Smoother Calendar Sync
- **What's New**: Fixed a pesky bug that caused the calendar to close unexpectedly when trying to save a task. Now, adding your tasks to your schedule is as smooth as it should be.
- **Why it matters**: You can now reliably export your tasks to your native iOS calendar without the app getting in your way.

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
