# Native iOS Parity Map

This document defines the feature parity requirements between the web app (v2.0-native) and the native iOS app.

## Table of Contents
1. [Screens](#screens)
2. [Features](#features)
3. [Data Models](#data-models)
4. [Event/Behavior Rules](#eventbehavior-rules)
5. [Acceptance Criteria](#acceptance-criteria)

---

## Screens

### 1. Root Navigation
- **Layout**: Tab bar at bottom with 2 tabs: "Notes" and "To-Dos"
- **Default Route**: `/` redirects to `/notes`
- **Navigation**: 
  - Bottom tab bar (fixed at bottom, safe-area aware)
  - Two tabs: Notes (FileText icon), To-Dos (CheckSquare icon)
  - Active tab highlighted with primary color

### 2. Notes Page (`/notes`)
- **Header**: 
  - Title: "Notes"
  - Subtitle: "{count} note(s)"
  - Menu button (MoreVertical) with dropdown: "Select Notes", "Select All", "Appearance"
  - In select mode: count display, delete button, cancel button
- **Content**:
  - List of notes sorted: pinned first, then by `updatedAt` (newest first)
  - Two sections: "Pinned" and "Notes" (if pinned exist)
  - Empty state: centered message "No notes yet" with prompt to tap + button
  - Floating + button (fixed bottom-right, above tab bar)
- **Interactions**:
  - Tap note → Opens note editor
  - Long-press → Enter select mode (iOS native)
  - Swipe gestures → Delete/pin actions (SwipeableNoteItem)
  - + button → Creates new note (opens editor with 'new' state)
  - Select mode → Multi-select, bulk delete

### 3. Note Editor
- **Header**: 
  - Back button (ArrowLeft)
  - Title field (editable)
  - Create task button (ListPlus) - opens QuickTaskSheet
  - More menu (MoreHorizontal)
- **Content**:
  - Title input (text field)
  - Content area (contentEditable/rich text):
    - Supports: Bold, Italic, Underline, Headings, Lists (bullet/numbered), Dividers
    - Auto-formatting: "- " → bullet list, "N. " → numbered list
    - Long-press on selection → Create task from text
- **Behavior**:
  - Auto-save on input (existing notes only)
  - New notes: save on back action
  - Formatting toolbar appears above keyboard when content focused
  - Back button saves and returns to list

### 4. Todos Page (`/todos`)
- **Header**:
  - Title: "To-Dos"
  - Toggle: "Doing" / "Done" switch (controls `showDoneTasks`)
  - Menu button (ChevronDown) with dropdown: "Manage categories", "Select" / "Cancel"
- **View Tabs**: 
  - 4 view modes: List, Priority, Category, Date
  - Tabs styled as segmented control (rounded pill)
  - Swipe left/right to change views
- **Content** (varies by view):
  - **List View**: Task input at top (when Doing), draggable list, empty state
  - **Priority View**: 4 sections (High, Medium, Low, Deferred), each with TaskInput and GroupedTaskList
  - **Category View**: One section per category, each with TaskInput and GroupedTaskList
  - **Date View**: 6 sections (Overdue, Today, Tomorrow, This Week, Later, No Due Date), each with TaskInput (only in Today section) and GroupedTaskList
- **Bulk Mode**:
  - Activated via menu → "Select"
  - Shows selected count
  - "Edit Categories" button (enabled when selection > 0)
  - Bulk category editing sheet

### 5. Task Edit Sheet
- **Header**: "Edit Task", buttons: Add to Calendar, Share, Close
- **Fields**:
  - Title (text input)
  - Categories (multi-select chips with "Manage" link)
  - Priority (4 buttons: High, Medium, Low, Deferred)
  - Due Date (quick options + calendar picker)
  - Notes & Details (textarea)
  - Linked Note (if exists, display-only)
  - Delete button (bottom, destructive style)
- **Behavior**: Save on close button, delete on delete button

### 6. Category Manager Dialog
- **Header**: "Manage Categories"
- **Content**:
  - Form (when adding/editing): Name, Icon (emoji), Color picker
  - List of categories (draggable, tap to edit)
  - "Add Category" button
- **Interactions**:
  - Drag to reorder
  - Tap category → Edit mode
  - Form: Name required, unique, Icon defaults to 🏷️, Color from existing pool or default

---

## Features

### Notes Feature
- **CRUD Operations**:
  - Create: + button → new note editor
  - Read: List view, open editor
  - Update: Editor auto-saves, title/content/plainText
  - Delete: Swipe or select mode + delete
- **Pin/Unpin**: Swipe action or menu, pinned notes appear first
- **Rich Text**: Formatting toolbar, lists, headings, etc.
- **Task Creation**: Long-press selection or ListPlus button → QuickTaskSheet
- **Supabase Sync**: Load on mount, sync on create/update/delete

### Todos Feature
- **CRUD Operations**:
  - Create: TaskInput (List view) or TaskInput per section (grouped views)
  - Read: List/grouped views
  - Update: TaskEditSheet
  - Delete: TaskEditSheet → Delete button
- **Completion Toggle**: 
  - "Doing" ↔ "Done" switch in header
  - Individual task completion via checkbox
  - `completedAt` date set/cleared
- **View Modes**:
  - **List**: Simple list, draggable reorder
  - **Priority**: Grouped by priority (4 sections), drag between sections updates priority
  - **Category**: Grouped by category, drag between sections updates categories
  - **Date**: Grouped by due date buckets, drag between sections updates dueDate
- **Grouping Logic**:
  - **Priority View**: Sort within each priority by createdAt (newest first)
  - **Category View**: Sort by priority then createdAt (within each category)
  - **Date View**: Sort by priority then createdAt (within each bucket)
- **Drag & Drop**:
  - **List View**: Reorder within list (updates `orderIndex`)
  - **Grouped Views**: 
    - Drop in section → Updates grouping field (priority/category/dueDate)
    - Drop on task → Creates parent/child relationship (`parentTaskId`)
- **Bulk Selection**: Select mode, bulk category editing
- **Task Input**:
  - Expanded when focused
  - Categories (chips), Priority (buttons)
  - Defaults: medium priority, empty categories
  - Enter key submits
- **Supabase Sync**: Load on mount, sync on create/update/delete/reorder

### Categories Feature
- **CRUD Operations**:
  - Create: CategoryManagerDialog → Add Category
  - Read: Displayed in chips/selectors
  - Update: CategoryManagerDialog → Tap category → Edit
  - Delete: Not implemented (assumption: categories persist)
- **Reorder**: Drag in CategoryManagerDialog
- **Storage**: Local only (Zustand persist), NOT synced to Supabase
- **Default Categories**: 8 predefined (house, garage, printing, vehicle, tech, finance, shopping, travel)
- **Validation**: Name required, unique (case-insensitive)

---

## Data Models

### Note
```typescript
interface Note {
  id: string;                    // Generated: Math.random().toString(36).slice(2, 11)
  title: string;                 // Required (defaults to "Untitled Note")
  content: string;               // HTML content (contentEditable innerHTML)
  plainText: string;             // Extracted from content (textContent)
  isPinned?: boolean;            // Default: false
  createdAt: Date;               // Set on create
  updatedAt: Date;               // Updated on every change
}
```

**Supabase Table**: `notes`
- Columns: `id`, `title`, `content`, `plain_text`, `is_pinned`, `created_at`, `updated_at`, `data` (JSONB)

### Task
```typescript
interface Task {
  id: string;                    // Generated: Math.random().toString(36).slice(2, 11)
  title: string;                 // Required
  categories: CategoryId[];      // Array of category IDs
  priority: Priority;            // 'high' | 'medium' | 'low' | 'deferred' (default: 'medium')
  dueDate?: Date;                // Optional
  completedAt?: Date;            // Set when completed, undefined when restored
  parentTaskId?: string;         // For nested tasks (drag onto another task)
  attachments: Attachment[];     // Array (currently empty in web app)
  noteId?: string;               // Link to note
  noteLine?: number;             // Line number in note
  taskNotes?: string;            // Additional notes/details
  createdAt: Date;               // Set on create
  updatedAt: Date;               // Updated on every change
  inputMethod: 'text' | 'voice' | 'continuation';  // Default: 'text'
  orderIndex?: number;           // For sorting/reordering (internal, not in type)
}
```

**Supabase Table**: `tasks`
- Columns: `id`, `title`, `completed_at`, `order_index`, `created_at`, `updated_at`, `data` (JSONB)
- Note: Most fields stored in `data` JSONB column

### Category
```typescript
interface Category {
  id: CategoryId;                // String (defaults: 'house', 'garage', etc. or generated)
  name: string;                  // Required, unique (case-insensitive)
  icon: string;                  // Emoji (default: '🏷️')
  color: string;                 // CSS class name (e.g., 'category-house')
}
```

**Storage**: Local only (Zustand persist), NOT in Supabase
**Default Categories**: 8 predefined (see `DEFAULT_CATEGORIES` in `src/types/index.ts`)

### Priority
```typescript
type Priority = 'high' | 'medium' | 'low' | 'deferred';
```
- Order: High (0) > Medium (1) > Low (2) > Deferred (3)
- Sorting: Priority view uses `sortTasksByDate` (createdAt only), others use `sortTasksByPriorityThenDate`

---

## Event/Behavior Rules

### Notes

#### Create Note
1. User taps + button → Opens editor with `noteId = null`
2. User types title/content
3. User taps back → `addNote()` called
4. New note appears in list (pinned section if `isPinned`, otherwise unpinned)
5. Supabase: Insert row (optimistic UI, async sync)

#### Update Note
1. User opens note → Editor loads with existing content
2. User edits title/content → Auto-save (for existing notes only)
3. `updateNote()` called → Updates `updatedAt`
4. Supabase: Update row (optimistic UI, async sync)

#### Delete Note
1. Swipe action or select mode + delete
2. `deleteNote()` or `deleteNotes()` called
3. Note removed from list
4. Supabase: Delete row(s) (optimistic UI, async sync)

#### Pin/Unpin Note
1. Swipe action or menu
2. `togglePinNote()` called
3. Note moves to pinned/unpinned section
4. Supabase: Update row

#### Load Notes
1. On page mount: `loadNotesFromSupabase()`
2. Query: `SELECT * FROM notes ORDER BY is_pinned DESC, updated_at DESC`
3. Map rows to Note objects
4. Update state

### Todos

#### Create Task
1. **List View**: TaskInput at top
2. **Grouped Views**: TaskInput in section (defaults: priority/category/dueDate from section)
3. User enters title → Expands input → Selects categories/priority → Submit
4. `addTask()` called → Task appears in appropriate view
5. Supabase: Insert row (optimistic UI, async sync)

#### Complete/Restore Task
1. User taps checkbox on TaskItem
2. `completeTask()` → Sets `completedAt = new Date()`
3. OR `restoreTask()` → Sets `completedAt = undefined`
4. Task moves between "Doing" and "Done" lists
5. Supabase: Update row

#### Update Task
1. User taps task → Opens TaskEditSheet
2. User edits fields → Taps close
3. `updateTask()` called → Updates `updatedAt`
4. Supabase: Update row

#### Delete Task
1. TaskEditSheet → Delete button
2. `deleteTask()` called
3. Task removed from list
4. Supabase: Delete row

#### Reorder Tasks (List View)
1. User drags task to new position
2. `reorderTasks(orderedIds)` called
3. Updates `orderIndex` for each task (decreasing from `Date.now()`)
4. Supabase: Batch update rows

#### Group Task (Priority/Category/Date Views)
1. User drags task from one section to another
2. `onTaskRegrouped()` callback
3. Updates task's grouping field (priority/categories/dueDate)
4. Supabase: Update row

#### Nest Task (Grouped Views)
1. User drags task onto another task (middle third of task)
2. `onTaskNested()` callback
3. Sets `parentTaskId` on dragged task
4. Supabase: Update row

#### Load Tasks
1. On page mount: `loadTasksFromSupabase()`
2. Query: `SELECT * FROM tasks ORDER BY order_index DESC, created_at DESC`
3. Map rows to Task objects
4. Update state

### Categories

#### Create Category
1. CategoryManagerDialog → Add Category
2. Form appears: Name (required), Icon (default 🏷️), Color
3. Save → `addCategory()` called
4. Category added to list (local storage only)
5. NOT synced to Supabase

#### Update Category
1. CategoryManagerDialog → Tap category
2. Form appears with existing values
3. Edit → Save → `updateCategory()` called
4. Category updated (local storage only)
5. NOT synced to Supabase

#### Reorder Categories
1. CategoryManagerDialog → Drag category
2. `reorderCategories(orderedIds)` called
3. Categories reordered (local storage only)
4. NOT synced to Supabase

---

## Acceptance Criteria

### Must Match (Exact Parity)

1. **Navigation**
   - ✅ Two tabs: Notes, To-Dos
   - ✅ Bottom tab bar (safe-area aware)
   - ✅ Default route redirects to Notes

2. **Notes Screen**
   - ✅ List sorted: pinned first, then by updatedAt (newest first)
   - ✅ Pinned and unpinned sections (if pinned exist)
   - ✅ Create note via + button
   - ✅ Open note → Editor
   - ✅ Delete note (swipe or select mode)
   - ✅ Pin/unpin note
   - ✅ Rich text editor (formatting toolbar, lists, headings)
   - ✅ Auto-save on input (existing notes)
   - ✅ New notes save on back action

3. **Todos Screen**
   - ✅ Four view modes: List, Priority, Category, Date
   - ✅ View tabs (segmented control)
   - ✅ "Doing" / "Done" toggle switch
   - ✅ TaskInput at top (List view) or in sections (grouped views)
   - ✅ TaskInput expands on focus, shows categories/priority
   - ✅ Task completion toggle (checkbox)
   - ✅ TaskEditSheet with all fields
   - ✅ Drag & drop reordering (List view)
   - ✅ Drag & drop grouping (Priority/Category/Date views)
   - ✅ Drag & drop nesting (parent/child relationships)
   - ✅ Bulk selection mode
   - ✅ Bulk category editing

4. **Categories**
   - ✅ CategoryManagerDialog (add/edit/reorder)
   - ✅ Default 8 categories
   - ✅ Local storage only (NOT Supabase)
   - ✅ Name validation (required, unique)

5. **Data Models**
   - ✅ Same fields as TypeScript interfaces
   - ✅ Same Supabase table structure
   - ✅ Same ID generation (or compatible)
   - ✅ Same date handling (ISO strings ↔ Date objects)

6. **Supabase Integration**
   - ✅ Same tables: `notes`, `tasks`
   - ✅ Same column names and types
   - ✅ Same JSONB structure in `data` column
   - ✅ Load on mount/foreground
   - ✅ Optimistic UI updates
   - ✅ Async sync (fire-and-forget pattern)

7. **Share Extension**
   - ✅ Share Sheet integration
   - ✅ Supports text, URL, image
   - ✅ Creates TODO by default
   - ✅ Main app imports share payload on launch/foreground

### Implementation Notes

- **Offline-First**: Local persistence (SwiftData or SQLite), sync queue, conflict resolution (LWW using `updated_at`)
- **Share Extension**: App Group `group.com.notelayer.app`, bundle IDs: `com.notelayer.app`, `com.notelayer.app.NotelayerShare`
- **Categories**: Store in UserDefaults or local database, NOT Supabase
- **Priority Order**: High > Medium > Low > Deferred (same sorting logic)
- **Date Buckets**: Overdue, Today, Tomorrow, This Week, Later, No Due Date (same logic)

---

## Assumptions & Decisions

1. **Categories are local-only**: Web app stores categories in Zustand persist (localStorage), not Supabase. Native app should match this behavior.

2. **ID Generation**: Web app uses `Math.random().toString(36).slice(2, 11)`. Native app can use UUID or compatible format (must be unique string IDs).

3. **Supabase Sync**: Web app uses optimistic UI + fire-and-forget sync. Native app should match this pattern (offline-first with sync queue).

4. **Drag & Drop**: Web app uses HTML5 drag events. Native app should use SwiftUI drag gestures (long-press to drag).

5. **Rich Text**: Web app uses contentEditable. Native app should use UITextView with NSAttributedString or SwiftUI TextEditor with formatting toolbar.

6. **Share Extension**: Web app creates TODO from share. Native app should match this behavior (creates TODO, not Note).

7. **Gestures**: Web app uses swipe gestures for page navigation and note actions. Native app should match where applicable (but don't invent new gestures).

---

## Questions / Ambiguities

1. **Rich Text Formatting**: Web app uses HTML. Native app should store HTML or convert to NSAttributedString? → **Decision**: Store HTML in `content` field, render with NSAttributedString.

2. **Task Nesting**: Web app supports `parentTaskId` but UI doesn't show nested hierarchy. Native app should implement nested display or flat list? → **Decision**: Match web app (flat list, store relationship but don't display hierarchy).

3. **Share Extension Payload**: Web app expects `title` and `body`/`text` query params. Native app Share Extension should extract text/URL from share items and create TODO. → **Decision**: Extract text/URL, use as TODO title, create TODO with medium priority.

4. **Offline Sync Strategy**: Web app doesn't have explicit offline queue. Native app needs offline-first with sync queue. → **Decision**: Implement outbox queue, sync on launch/foreground, conflict resolution using `updated_at` (LWW).
