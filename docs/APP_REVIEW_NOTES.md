# App Review Notes

## App Overview

NoteLayer is a task management and notes app that helps users organize their todos and notes with powerful organization features. The app supports multiple authentication methods and syncs data across devices using Firebase. Users can organize tasks by priority, category, or due date, and customize the app's appearance with various theme presets.

## Main Features

### Core Functionality
- **Task Management**: Create, edit, and delete tasks with titles, notes, priorities, categories, and due dates
- **Notes**: Simple notes management with text storage
- **Priorities**: Four priority levels (High, Medium, Low, Deferred)
- **Categories**: Create and manage custom categories with emoji icons and colors
- **Due Dates**: Set date and time for tasks with visual date grouping

### Organization & Views
- **Multiple View Modes**: 
  - List view (all tasks in one list)
  - Priority view (grouped by priority level)
  - Category view (grouped by category)
  - Date view (grouped by due date: Overdue, Today, Tomorrow, This Week, Later, No Due Date)
- **Drag & Drop**: Reorder tasks within and between groups
- **Doing/Done Toggle**: Switch between active tasks and completed tasks
- **Collapsible Groups**: Expand/collapse groups in Priority, Category, and Date views

### Customization
- **Theme Presets**: 17 color palette options (Barbie, Fast, Iridescent, Arctic, Ocean, Forest, Sunset, Lavender, Graphite, Sand, Mint, Ember, Berry, Citrus, Slate, Mono, Cheetah)
- **Theme Mode**: Light, Dark, or System (follows device setting)
- **Custom Categories**: Add, edit, reorder, and customize categories with emoji icons and colors

### Sync & Authentication
- **Firebase Sync**: Data syncs across devices when signed in
- **Sign in with Apple**: Native Apple authentication
- **Sign in with Google**: Google account authentication
- **Phone Authentication**: SMS-based phone number verification

### Additional Features
- **Share**: Share tasks and notes via iOS share sheet
- **Copy**: Copy task titles and note text to clipboard
- **Context Menus**: Long-press on tasks and notes for quick actions

## How to Test

### Sign in with Apple
1. Open the app
2. Navigate to Todos tab → Tap gear icon (⚙️) → Select "Authentication"
3. Tap "Sign in with Apple" button
4. Complete Apple ID authentication flow
5. **Expected**: Sign-in completes immediately and sheet dismisses. User email/ID appears in authentication sheet.

### Sign in with Google
1. Open the app
2. Navigate to Todos tab → Tap gear icon (⚙️) → Select "Authentication"
3. Tap "Sign in with Google" button
4. Complete Google account selection and authentication
5. **Expected**: Sign-in completes immediately and sheet dismisses. User email appears in authentication sheet.

### Sign in with Phone
1. Open the app
2. Navigate to Todos tab → Tap gear icon (⚙️) → Select "Authentication"
3. Tap "Continue with Phone" button
4. Enter phone number (include country code, e.g., +1 for US)
5. Tap "Send code"
6. Enter verification code received via SMS
7. Tap "Verify"
8. **Expected**: Verification code is received, sign-in completes, and sheet dismisses. **Note**: Phone authentication requires a real device (not simulator).

### Creating Tasks
1. Navigate to Todos tab
2. Tap in the task input field at the top of the list
3. Type a task title and press return/enter
4. **Expected**: Task appears in the list immediately
5. Tap on a task to open edit view
6. Modify title, select categories, change priority, set due date, add notes
7. Tap "Save"
8. **Expected**: Changes are saved and reflected in the task list

### Using Different View Modes
1. Navigate to Todos tab
2. Use the segmented control below the header to switch between views:
   - **List**: All tasks in a single list
   - **Priority**: Tasks grouped by priority (High, Medium, Low, Deferred)
   - **Category**: Tasks grouped by category (with "Uncategorized" group)
   - **Date**: Tasks grouped by due date (Overdue, Today, Tomorrow, This Week, Later, No Due Date)
3. **Expected**: Tasks reorganize according to selected view mode
4. Test drag & drop: Long-press a task and drag it to reorder within a group or move between groups
5. **Expected**: Tasks reorder smoothly with animation

### Categories Management
1. Navigate to Todos tab → Tap gear icon (⚙️) → Select "Manage Categories"
2. Tap "+" button to add a new category
3. Enter name, emoji icon, and select color
4. Tap "Add"
5. **Expected**: New category appears in the list
6. Tap an existing category to edit it
7. Modify name, icon, or color
8. Tap "Save"
9. **Expected**: Changes are saved
10. Use drag handles to reorder categories
11. **Expected**: Categories reorder and new order persists

### Theme Changes
1. Navigate to Todos tab → Tap gear icon (⚙️) → Select "Appearance"
2. Change "Theme Mode" between Light, Dark, and System
3. **Expected**: App appearance changes immediately (System follows device setting)
4. Tap different palette tiles to change color theme
5. **Expected**: Accent colors and background change according to selected preset
6. Navigate between tabs to see theme applied throughout the app
7. **Expected**: Theme is consistent across all views

## Test Account

**Not required.** All authentication providers (Apple, Google, Phone) work directly with the user's own accounts. Reviewers can use their own Apple ID, Google account, or phone number for testing.

## Special Instructions

- **Phone Authentication**: Phone number authentication requires a **real iOS device** and will not work on the iOS Simulator. The simulator cannot receive SMS verification codes or register for remote notifications required by Firebase Phone Auth.

- **First Launch**: On first launch, the app may take a moment to initialize Firebase. Authentication options will be available after the sheet fully presents (approximately 0.4 seconds).

- **Data Persistence**: Tasks, notes, and categories are stored locally and sync to Firebase when authenticated. Data persists between app launches.

- **View Mode State**: Group collapse/expand state (in Priority, Category, and Date views) is saved and persists between app launches.

- **Theme Persistence**: Selected theme preset and mode are saved and persist between app launches.
