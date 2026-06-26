# App Store Screenshot Guide

This guide provides step-by-step instructions for creating App Store screenshots for NoteLayer. All screenshots should be taken on **iPhone 17 Pro** simulator.

## Overview

We'll create 6 screenshots showcasing:
1. Main Todos List View - Core functionality
2. Sign-in Screen - Authentication options
3. Task Edit View - Task management details
4. Category View Mode - Category-based organization
5. Appearance View - Theme customization
6. Priority View Mode - Priority-based organization

---

## Simulator Setup

1. Open Xcode
2. Go to **Window > Devices and Simulators**
3. Select **iPhone 17 Pro** simulator
4. Ensure iOS version is latest (iOS 18+)
5. Before taking screenshots:
   - Set time to a clean time (e.g., 10:00 AM)
   - Disable notifications: **Settings > Notifications > Turn off all**
   - Set battery to 100%: **Settings > Battery**
   - Use light appearance for consistency (unless screenshot specifically needs dark mode)

---

## Dummy Data Setup

Before taking screenshots, create the following tasks in the app. These represent common, relatable tasks that users can identify with.

### Tasks to Create

Create these tasks with the specified details:

#### High Priority Tasks
1. **"Pay credit card bill"**
   - Category: Finance & Admin (📊)
   - Priority: High
   - Due Date: Today
   - Notes: "Due by end of day - $450 minimum payment"

2. **"Fix leaky faucet"**
   - Category: House & Repairs (🏠)
   - Priority: High
   - Due Date: Tomorrow
   - Notes: "Kitchen sink - need to buy washers first"

#### Medium Priority Tasks
3. **"Buy groceries"**
   - Category: Shopping & Errands (🛒)
   - Priority: Medium
   - Due Date: Tomorrow
   - Notes: (none)

4. **"Schedule dentist appointment"**
   - Category: Travel & Health (✈️)
   - Priority: Medium
   - Due Date: This week (3 days from today)
   - Notes: (none)

5. **"Update phone software"**
   - Category: Tech & Apps (💻)
   - Priority: Medium
   - Due Date: This week (4 days from today)
   - Notes: (none)

#### Low Priority Tasks
6. **"Organize garage"**
   - Category: Garage & Workshop (🔧)
   - Priority: Low
   - Due Date: Later (2 weeks from today)
   - Notes: (none)

7. **"Return library books"**
   - Category: Shopping & Errands (🛒)
   - Priority: Low
   - Due Date: No due date
   - Notes: (none)

#### Deferred Priority Tasks
8. **"Review app subscriptions"**
   - Category: Tech & Apps (💻)
   - Priority: Deferred
   - Due Date: No due date
   - Notes: (none)

### How to Create Tasks

1. Open the app in simulator
2. Navigate to **Todos** tab
3. Ensure you're on the **"Doing"** tab (not "Done")
4. For each task:
   - Tap the input field at the top
   - Type the task title
   - Expand the input (tap the text field)
   - Select the appropriate category chip
   - Select the appropriate priority button
   - If due date is needed, you'll need to create the task first, then edit it to add the due date
   - Press Enter or tap the arrow button to create
5. For tasks requiring due dates or notes:
   - Tap the task to open TaskEditView
   - Set the due date using the date picker
   - Add notes in the Notes section
   - Tap "Save"

---

## Screenshot 1: Main Todos List View

**Purpose:** Showcase the core todo functionality with tasks, categories, and priorities.

### Setup Steps:
1. Ensure simulator is set to **iPhone 17 Pro**
2. Create all 8 tasks listed above
3. Navigate to **Todos** tab
4. Ensure **"Doing"** toggle is selected (not "Done")
5. Ensure **"List"** view mode is selected (first tab in segmented control)
6. Scroll to show 5-7 tasks visible on screen
7. Ensure tasks show:
   - Checkboxes (unchecked)
   - Task titles
   - Category badges (colored chips with emoji icons)
   - Priority badges (High, Med, Low, Def)
   - Due dates where applicable

### What to Capture:
- Header showing "Todos" title
- "Doing" toggle with task count
- Segmented control showing "List" selected
- Multiple task cards showing:
  - Unchecked checkboxes
  - Task titles
  - Category chips (e.g., 🛒 Shopping & Errands, 📊 Finance & Admin)
  - Priority badges
  - Due dates (e.g., "Jan 25, 10:00 AM")

### What This Demonstrates:
- Clean, modern todo interface
- Category organization with visual chips
- Priority levels
- Due date tracking
- Easy task creation and management

---

## Screenshot 2: Sign-in Screen

**Purpose:** Showcase easy authentication options.

### Setup Steps:
1. Ensure simulator is set to **iPhone 17 Pro**
2. **Sign out** if currently signed in:
   - Tap gear icon (⚙️) in Todos view
   - Tap "Authentication"
   - Tap "Sign out" if available
3. Navigate to **Todos** tab
4. Tap gear icon (⚙️) in top right
5. Tap "Authentication"
6. Wait for sheet to fully appear (should show all auth options)

### What to Capture:
- Sheet title: "Sign into NoteLayer"
- Subtitle: "to sync everywhere"
- Apple Sign In button (black button with Apple logo)
- Google Sign In button (white button with Google logo)
- "Continue with Phone" button
- All buttons should be enabled and visible

### What This Demonstrates:
- Multiple authentication options
- Easy sign-in process
- Sync capability messaging

---

## Screenshot 3: Task Edit View

**Purpose:** Showcase comprehensive task management features.

### Setup Steps:
1. Ensure simulator is set to **iPhone 17 Pro**
2. Ensure all dummy tasks are created
3. Navigate to **Todos** tab
4. Tap on the task **"Fix leaky faucet"** (should have High priority, House & Repairs category, due tomorrow, and notes)
5. TaskEditView sheet should appear

### What to Capture:
- Navigation bar with "Task" title, "Cancel" and "Save" buttons
- Title section showing "Fix leaky faucet"
- Categories section showing:
  - House & Repairs (🏠) with checkmark selected
  - Other categories listed (some may be checked/unchecked)
- Priority section showing "High" selected
- Due Date section showing:
  - "Due Date" label
  - Date/time formatted (e.g., "Jan 25, 2025, 10:00 AM")
  - Calendar icon
- Notes section showing the task notes text
- Delete Task button at bottom (red)

### What This Demonstrates:
- Comprehensive task editing
- Category selection
- Priority management
- Due date setting
- Notes/descriptions
- Full task details in one view

---

## Screenshot 4: Category View Mode

**Purpose:** Showcase category-based organization.

### Setup Steps:
1. Ensure simulator is set to **iPhone 17 Pro**
2. Ensure all 8 dummy tasks are created
3. Navigate to **Todos** tab
4. Ensure **"Doing"** toggle is selected
5. Swipe or tap to select **"Category"** view mode (third tab in segmented control)
6. Scroll to show multiple category groups with tasks

### What to Capture:
- Header with "Todos" and "Doing" toggle
- Segmented control showing "Category" selected
- Multiple category group cards showing:
  - Category header with emoji icon and name (e.g., "🏠 House & Repairs", "🛒 Shopping & Errands")
  - Task count badge
  - Tasks listed under each category
  - Tasks showing checkboxes, titles, priorities, due dates
- At least 3-4 category groups visible

### What This Demonstrates:
- Tasks organized by category
- Visual category grouping
- Easy category-based navigation
- Multiple categories in use

---

## Screenshot 5: Appearance View

**Purpose:** Showcase theme customization options.

### Setup Steps:
1. Ensure simulator is set to **iPhone 17 Pro**
2. Navigate to **Todos** tab
3. Tap gear icon (⚙️) in top right
4. Tap "Appearance"
5. AppearanceView sheet should appear

### What to Capture:
- Navigation bar with "Appearance" title and "Done" button
- "Theme Mode" section showing:
  - Segmented control with options (Light/Dark/Auto)
  - One option selected
- "Palettes" section showing:
  - Grid of theme palette tiles (2 columns)
  - Each tile showing:
    - Color preview (background and accent color dot)
    - Theme name (e.g., "Cheetah", "Ocean", etc.)
    - Checkmark on selected theme
  - Multiple palette options visible (at least 4-6 tiles)

### What This Demonstrates:
- Theme customization
- Multiple appearance options
- Light/dark mode support
- Visual theme previews

---

## Screenshot 6: Priority View Mode

**Purpose:** Showcase priority-based organization.

### Setup Steps:
1. Ensure simulator is set to **iPhone 17 Pro**
2. Ensure all 8 dummy tasks are created (they have different priorities)
3. Navigate to **Todos** tab
4. Ensure **"Doing"** toggle is selected
5. Swipe or tap to select **"Priority"** view mode (second tab in segmented control)
6. Scroll to show priority groups

### What to Capture:
- Header with "Todos" and "Doing" toggle
- Segmented control showing "Priority" selected
- Priority group cards showing:
  - "High" priority group with tasks (e.g., "Pay credit card bill", "Fix leaky faucet")
  - "Medium" priority group with tasks (e.g., "Buy groceries", "Schedule dentist appointment", "Update phone software")
  - "Low" priority group with tasks (e.g., "Organize garage", "Return library books")
  - "Deferred" priority group with tasks (e.g., "Review app subscriptions")
- Each task showing checkbox, title, categories, due dates
- At least 3-4 priority groups visible

### What This Demonstrates:
- Tasks organized by priority
- Visual priority grouping
- Easy priority-based navigation
- Focus on high-priority tasks

---

## Technical Details

### Screenshot Specifications
- **Device**: iPhone 17 Pro
- **Resolution**: Check current iPhone 17 Pro resolution (typically 1290 x 2796 pixels or similar)
- **Format**: PNG (recommended) or JPEG
- **Color Space**: sRGB

### Best Practices
1. **Clean Status Bar**: 
   - Set time to 10:00 AM
   - Full battery (100%)
   - Good signal strength
   - No notifications

2. **Consistent Appearance**:
   - Use same theme/appearance for all screenshots (unless specifically showcasing themes)
   - Ensure consistent lighting/background

3. **Content Quality**:
   - Ensure text is readable
   - Avoid showing placeholder or empty states
   - Show realistic, relatable content
   - Ensure UI elements are properly aligned

4. **Navigation**:
   - Ensure proper navigation state (correct tab selected, correct view mode)
   - Close any unnecessary sheets/modals before taking screenshot
   - Ensure content is scrolled to best position

5. **Screenshot Capture**:
   - Use Xcode's screenshot tool: **Device > Screenshot** or **⌘ + S** in simulator
   - Or use simulator menu: **File > Save Screen Shot** (⌘ + S)
   - Or use simulator menu: **File > New Screen Recording** (then extract frame)
   - Save screenshots with descriptive names (e.g., `screenshot-1-todos-list.png`)

### Screenshot Save Location

**Default Location:**
- iOS Simulator screenshots are saved to your **Desktop** by default
- Files are named with timestamp format: `Screen Shot YYYY-MM-DD at HH.MM.SS AM.png`

**Changing Save Location:**
- **Option 1**: When saving, press **⌥ + ⌘ + S** (Option + Command + S) to choose a custom location
  - Check "Use this as the default location" to make it permanent
- **Option 2**: Set via Terminal (folder must exist first):
  ```bash
  defaults write com.apple.iphonesimulator ScreenShotSaveLocation ~/Desktop/Screenshots
  ```
- **Option 3**: Drag screenshots from the preview window that appears after capture to your desired location

**Recommended Workflow:**
1. Take screenshots (they'll save to Desktop)
2. Move or copy them to your project's screenshots folder (e.g., `ios-swift/Notelayer/Screenshots/`)
3. Rename them according to the naming convention below

### File Naming Convention
- `screenshot-1-todos-list.png`
- `screenshot-2-sign-in.png`
- `screenshot-3-task-edit.png`
- `screenshot-4-category-view.png`
- `screenshot-5-appearance.png`
- `screenshot-6-priority-view.png`

---

## Troubleshooting

### Tasks Not Appearing
- Ensure you're on "Doing" tab, not "Done"
- Check that tasks were created successfully
- Try refreshing the app

### Categories Not Showing
- Ensure default categories are initialized (should happen automatically)
- Check CategoryManagerView to verify categories exist

### View Mode Not Changing
- Use the segmented control at top of TodosView
- Or swipe left/right on the content area

### Sheet Not Appearing
- Wait a moment for sheet animation to complete
- Ensure you tapped the correct menu item
- Check that sheet presentation is working

### Authentication Sheet Issues
- Ensure you're signed out before taking screenshot
- Wait for sheet to fully appear (0.4 second delay built in)
- Check that auth buttons are enabled

---

## Summary Checklist

Before taking screenshots, ensure:
- [ ] iPhone 17 Pro simulator is running
- [ ] All 8 dummy tasks are created with correct details
- [ ] Status bar is clean (10:00 AM, 100% battery, good signal)
- [ ] Notifications are disabled
- [ ] Consistent theme/appearance is set
- [ ] You know which view/screen each screenshot needs
- [ ] Navigation state is correct for each screenshot
- [ ] Content is scrolled to best position
- [ ] No unnecessary sheets/modals are open

After taking screenshots:
- [ ] Verify all 6 screenshots are captured
- [ ] Check image quality and readability
- [ ] Ensure consistent appearance across screenshots
- [ ] Rename files according to convention
- [ ] Save in appropriate location for App Store submission
