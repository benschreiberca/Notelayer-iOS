# Native iOS App - Implementation Plan

**Goal**: Get the app functioning as soon as possible, then build to full feature parity.

**Strategy**: MVP-first approach with incremental feature additions.

---

## Phase 0: Foundation & Quick Win (Current State)
**Status**: ✅ Complete  
**Goal**: Get basic app running with minimal functionality

### Completed
- Basic app structure (NotelayerApp, RootTabsView)
- Minimal data models (Note, Todo)
- Basic views (NotesView, TodosView)
- Local storage (UserDefaults)
- Share Extension structure

### Current Limitations
- Data models don't match web app
- No proper CRUD operations
- No edit capabilities
- No rich text editing
- No categories/priorities

---

## Phase 1: MVP - Working App (Priority 1)
**Goal**: Get a functional app that works end-to-end  
**Estimated Effort**: 2-3 days  
**Definition of Done**: Can create, view, edit, and delete both Notes and Todos

### 1.1 Fix Data Models (4-6 hours)
**Priority**: 🔴 CRITICAL - Must do first

#### Update Note Model
```swift
struct Note: Identifiable, Codable {
    let id: String                    // Match web app (not UUID)
    var title: String                 // Required (defaults to "Untitled Note")
    var content: String               // HTML content
    var plainText: String             // Extracted from content
    var isPinned: Bool                // Default: false
    var createdAt: Date
    var updatedAt: Date
}
```

#### Update Task Model (rename Todo → Task)
```swift
struct Task: Identifiable, Codable {
    let id: String                    // Match web app
    var title: String                 // Required
    var categories: [String]          // Array of category IDs
    var priority: Priority            // 'high' | 'medium' | 'low' | 'deferred'
    var dueDate: Date?                // Optional
    var completedAt: Date?            // Set when completed
    var taskNotes: String?            // Additional notes/details
    var createdAt: Date
    var updatedAt: Date
}

enum Priority: String, Codable, CaseIterable {
    case high, medium, low, deferred
}
```

#### Add Category Model
```swift
struct Category: Identifiable, Codable {
    let id: String
    var name: String
    var icon: String                  // Emoji
    var color: String                 // CSS class name
}
```

**Files to Update**:
- `ios-swift/Notelayer/Notelayer/Data/LocalStore.swift`

**Actions**:
1. Replace Note struct with proper fields
2. Replace Todo struct with Task struct (full model)
3. Add Category struct
4. Add Priority enum
5. Update LocalStore to handle new models

---

### 1.2 Enhanced LocalStore (4-6 hours)
**Priority**: 🔴 CRITICAL

#### Required Methods for Notes
- `addNote(_ note: Note) -> String` (returns ID)
- `updateNote(id: String, updates: Partial<Note>)`
- `deleteNote(id: String)`
- `deleteNotes(ids: [String])`
- `togglePinNote(id: String)`
- `loadNotes() -> [Note]`
- `getNote(id: String) -> Note?`

#### Required Methods for Tasks
- `addTask(_ task: Task) -> String`
- `updateTask(id: String, updates: Partial<Task>)`
- `deleteTask(id: String)`
- `completeTask(id: String)`
- `restoreTask(id: String)`
- `loadTasks() -> [Task]`
- `getTask(id: String) -> Task?`

#### Required Methods for Categories
- `loadCategories() -> [Category]`
- `addCategory(_ category: Category)`
- `updateCategory(id: String, updates: Partial<Category>)`
- `reorderCategories(orderedIds: [String])`
- Initialize with default categories if empty

**Files to Update**:
- `ios-swift/Notelayer/Notelayer/Data/LocalStore.swift`

**Actions**:
1. Implement all CRUD methods
2. Add default categories initialization
3. Update UserDefaults storage keys
4. Ensure proper Codable serialization

---

### 1.3 Basic Notes View & Editor (6-8 hours)
**Priority**: 🔴 CRITICAL

#### NotesView Updates
- Display notes sorted: pinned first, then by updatedAt (newest first)
- Show pinned/unpinned sections
- Add + button to create new note
- Tap note → open editor
- Swipe to delete
- Empty state message

#### NoteEditorView (New File)
- Title text field
- Content text editor (TextEditor - simple text first, rich text later)
- Auto-save on change (for existing notes)
- Back button saves and dismisses
- For new notes: save on back action
- Extract plainText from content

**Files to Create**:
- `ios-swift/Notelayer/Notelayer/Views/NoteEditorView.swift`

**Files to Update**:
- `ios-swift/Notelayer/Notelayer/Views/NotesView.swift`

**Implementation Notes**:
- Start with TextEditor (plain text) - add rich text in Phase 2
- Use NavigationStack for navigation
- Use @StateObject for LocalStore
- Extract plainText using simple text extraction

---

### 1.4 Basic Todos View & Editor (6-8 hours)
**Priority**: 🔴 CRITICAL

#### TodosView Updates
- List view of tasks (filtered by "Doing"/"Done" toggle)
- TaskItem component showing: title, completion checkbox, priority, categories
- Add task input at top (simple text field)
- Tap task → open editor
- Checkbox toggles completion
- Empty state message
- "Doing" / "Done" toggle in toolbar

#### TaskEditView (New File)
- Title text field
- Priority selector (4 buttons: High, Medium, Low, Deferred)
- Categories multi-select (chips, for now just show - full management in Phase 2)
- Due date picker (optional)
- Notes text area
- Save button
- Delete button (destructive)
- Close button

**Files to Create**:
- `ios-swift/Notelayer/Notelayer/Views/TaskEditView.swift`
- `ios-swift/Notelayer/Notelayer/Views/TaskItem.swift`

**Files to Update**:
- `ios-swift/Notelayer/Notelayer/Views/TodosView.swift`

**Implementation Notes**:
- Start with List view only (other view modes in Phase 2)
- Use Sheet for TaskEditView
- Simple category display (full management in Phase 2)

---

### 1.5 Testing & Polish (2-4 hours)
**Priority**: 🟡 HIGH

**Actions**:
- Test all CRUD operations
- Test persistence (app restart)
- Fix any bugs
- Ensure UI is responsive
- Test on simulator
- Basic error handling

---

## Phase 2: Enhanced Features (Priority 2)
**Goal**: Add essential features for better UX  
**Estimated Effort**: 3-5 days  
**Prerequisites**: Phase 1 complete

### 2.1 Notes Enhancements (1-2 days)

#### Rich Text Editor
- Replace TextEditor with UITextView wrapper or use TextEditor with formatting
- Add formatting toolbar (Bold, Italic, Underline)
- Support lists (bullet, numbered)
- Extract HTML from attributed text (or store as attributed string)

#### Pin/Unpin
- Add pin/unpin button in editor
- Swipe action to pin/unpin
- Visual indicator for pinned notes

#### Select Mode
- Long-press to enter select mode
- Multi-select checkboxes
- Bulk delete
- Select all / Deselect all

**Files to Update**:
- `ios-swift/Notelayer/Notelayer/Views/NoteEditorView.swift`
- `ios-swift/Notelayer/Notelayer/Views/NotesView.swift`

---

### 2.2 Categories Management (1 day)

#### CategoryManagerView (New File)
- List of categories (draggable to reorder)
- Add category form
- Edit category (tap to edit)
- Default categories initialization
- Name validation (required, unique)
- Icon picker (emoji)
- Color picker (from predefined set)

#### Integration
- Categories displayed as chips in TaskEditView
- Category selector in TaskEditView
- Categories displayed on TaskItem

**Files to Create**:
- `ios-swift/Notelayer/Notelayer/Views/CategoryManagerView.swift`

**Files to Update**:
- `ios-swift/Notelayer/Notelayer/Views/TodosView.swift` (add menu item)
- `ios-swift/Notelayer/Notelayer/Views/TaskEditView.swift`
- `ios-swift/Notelayer/Notelayer/Views/TaskItem.swift`

---

### 2.3 Todos View Modes (1-2 days)

#### List View (Enhanced)
- Drag & drop reordering
- Update orderIndex on reorder

#### Priority View
- Grouped by priority (4 sections: High, Medium, Low, Deferred)
- TaskInput in each section
- Drag between sections updates priority
- Sort within each priority by createdAt

#### Category View
- Grouped by category
- TaskInput in each section
- Drag between sections updates categories
- Sort by priority then createdAt

#### Date View
- Grouped by date buckets (Overdue, Today, Tomorrow, This Week, Later, No Due Date)
- TaskInput only in Today section
- Drag between sections updates dueDate
- Sort by priority then createdAt

#### View Tabs
- Segmented control at top
- Switch between 4 view modes
- Swipe left/right to change views (optional)

**Files to Create**:
- `ios-swift/Notelayer/Notelayer/Views/PriorityTaskView.swift`
- `ios-swift/Notelayer/Notelayer/Views/CategoryTaskView.swift`
- `ios-swift/Notelayer/Notelayer/Views/DateTaskView.swift`

**Files to Update**:
- `ios-swift/Notelayer/Notelayer/Views/TodosView.swift`

---

### 2.4 Bulk Operations (0.5-1 day)

#### Bulk Selection
- Select mode in TodosView
- Multi-select tasks
- Selected count display
- Bulk category editing sheet
- Bulk delete

**Files to Update**:
- `ios-swift/Notelayer/Notelayer/Views/TodosView.swift`
- Create bulk operations sheet

---

## Phase 3: Full Feature Parity (Priority 3)
**Goal**: Match all features from web app  
**Estimated Effort**: 3-5 days  
**Prerequisites**: Phase 2 complete

### 3.1 Supabase Integration (2-3 days)

#### Setup
- Add Supabase Swift SDK dependency
- Create SupabaseConfig.swift (template)
- Configure Supabase client

#### Sync Service
- `loadNotesFromSupabase()` - Query and map to Note objects
- `loadTasksFromSupabase()` - Query and map to Task objects
- `syncNote(_ note: Note)` - Insert/update to Supabase
- `syncTask(_ task: Task)` - Insert/update to Supabase
- `deleteNoteFromSupabase(id: String)`
- `deleteTaskFromSupabase(id: String)`
- Optimistic UI updates
- Async sync (fire-and-forget pattern)
- Conflict resolution (LWW using updated_at)

#### Integration
- Load on app launch/foreground
- Sync on create/update/delete
- Sync queue for offline support

**Files to Update**:
- `ios-swift/Notelayer/Notelayer/Data/SyncService.swift`
- Add Supabase client file
- Update LocalStore to trigger sync

---

### 3.2 Share Extension Enhancement (0.5-1 day)

#### Updates
- Ensure App Groups configured
- Create TODO from share (not Note)
- Better text extraction
- Handle URLs, images, text
- Test share extension

**Files to Update**:
- `ios-swift/Notelayer/Notelayer/ShareExtension/ShareViewController.swift`
- Share Extension target configuration

---

### 3.3 Advanced Features (1-2 days)

#### Notes
- Task creation from note selection
- QuickTaskSheet integration
- Linked notes in tasks

#### Tasks
- Parent/child relationships (nested tasks)
- Drag to nest functionality
- Attachments support (future)

---

## Phase 4: Polish & Optimization (Priority 4)
**Goal**: Production-ready app  
**Estimated Effort**: 2-3 days

### 4.1 UI/UX Polish
- Consistent styling
- Animations and transitions
- Loading states
- Error messages
- Empty states
- Accessibility

### 4.2 Performance
- Optimize data loading
- Efficient list rendering
- Cache management
- Background sync

### 4.3 Testing
- Unit tests for data models
- UI tests for critical flows
- Integration tests for sync
- Test on devices

---

## Quick Start Guide (Getting to MVP)

To get the app functioning as soon as possible, follow this order:

### Day 1: Data Models & Storage
1. ✅ Update Note model (2 hours)
2. ✅ Update Task model (2 hours)
3. ✅ Add Category model (1 hour)
4. ✅ Implement LocalStore CRUD methods (3-4 hours)

### Day 2: Notes Feature
1. ✅ Update NotesView (2 hours)
2. ✅ Create NoteEditorView (4 hours)
3. ✅ Test Notes CRUD (1 hour)

### Day 3: Todos Feature
1. ✅ Update TodosView (2 hours)
2. ✅ Create TaskEditView (4 hours)
3. ✅ Create TaskItem component (1 hour)
4. ✅ Test Todos CRUD (1 hour)

### Day 4: Testing & Bug Fixes
1. ✅ End-to-end testing
2. ✅ Bug fixes
3. ✅ Basic polish

**Result**: Working MVP in ~4 days

---

## Implementation Priority Matrix

| Feature | Phase | Priority | Effort | Dependencies |
|---------|-------|----------|--------|--------------|
| Fix Data Models | 1.1 | 🔴 Critical | 4-6h | None |
| Enhanced LocalStore | 1.2 | 🔴 Critical | 4-6h | 1.1 |
| Notes View & Editor | 1.3 | 🔴 Critical | 6-8h | 1.1, 1.2 |
| Todos View & Editor | 1.4 | 🔴 Critical | 6-8h | 1.1, 1.2 |
| Testing & Polish | 1.5 | 🟡 High | 2-4h | 1.3, 1.4 |
| Rich Text Editor | 2.1 | 🟡 High | 1-2d | 1.3 |
| Pin/Unpin | 2.1 | 🟡 High | 0.5d | 1.3 |
| Categories Management | 2.2 | 🟡 High | 1d | 1.2 |
| Todos View Modes | 2.3 | 🟡 High | 1-2d | 1.4 |
| Bulk Operations | 2.4 | 🟢 Medium | 0.5-1d | 2.3 |
| Supabase Integration | 3.1 | 🟢 Medium | 2-3d | 1.5 |
| Share Extension | 3.2 | 🟢 Medium | 0.5-1d | 1.5 |
| Advanced Features | 3.3 | 🟢 Low | 1-2d | 2.x |
| UI/UX Polish | 4.1 | 🟢 Low | 1-2d | 3.x |
| Performance | 4.2 | 🟢 Low | 1d | 3.x |
| Testing | 4.3 | 🟡 High | 1d | All |

---

## Key Decisions

1. **ID Generation**: Use string IDs (match web app `Math.random().toString(36).slice(2, 11)`) or UUID?  
   → **Recommendation**: Use UUID initially (simpler), convert to string format if needed for sync

2. **Rich Text Storage**: Store as HTML (like web app) or NSAttributedString?  
   → **Recommendation**: Start with plain text (Phase 1), add HTML support in Phase 2

3. **Date Format**: Store as Date objects, convert to ISO strings for sync  
   → **Recommendation**: Use Date objects in Swift, convert to ISO strings for Supabase

4. **Local Storage**: Continue with UserDefaults or migrate to SQLite/SwiftData?  
   → **Recommendation**: UserDefaults for MVP (Phase 1), consider migration if performance issues

---

## Success Criteria

### Phase 1 (MVP) Complete When:
- ✅ Can create, view, edit, delete Notes
- ✅ Can create, view, edit, delete Tasks
- ✅ Data persists across app restarts
- ✅ Basic UI is functional and responsive
- ✅ App builds and runs without crashes

### Phase 2 Complete When:
- ✅ All Phase 1 criteria met
- ✅ Rich text editing works
- ✅ Pin/unpin functionality works
- ✅ Categories can be managed
- ✅ Multiple Todo view modes work
- ✅ Drag & drop works

### Phase 3 Complete When:
- ✅ All Phase 2 criteria met
- ✅ Supabase sync works
- ✅ Share extension creates TODOs
- ✅ Feature parity with web app achieved

---

## Notes

- This plan prioritizes getting a working app quickly (Phase 1)
- Each phase builds on the previous one
- Features can be implemented incrementally
- Testing should happen continuously, not just at the end
- Adjust timeline based on actual progress
