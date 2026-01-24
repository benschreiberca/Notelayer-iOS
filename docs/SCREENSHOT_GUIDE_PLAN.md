# Screenshot Content Guide Plan

**Overall Progress:** `100%`

## TLDR
Create a comprehensive guide for taking App Store screenshots that showcases the app's key features: todo management with multiple view modes, authentication, task editing, category management, and appearance customization. The guide will specify exact simulator setup, data requirements, and view states for 6 screenshots.

## Critical Decisions
- **Screenshot Count**: 6 screenshots (standard App Store requirement) - covers main features without overwhelming
- **Device**: iPhone 17 Pro - modern device for showcasing UI details
- **View Selection**: Prioritize TodosView variations (main feature) + key supporting screens (auth, edit, categories, appearance)
- **Data Strategy**: Use realistic, common everyday tasks that users can relate to (grocery shopping, home repairs, work tasks, personal errands, etc.)
- **State Management**: Each screenshot shows a specific, meaningful state (e.g., tasks with categories, priority groups, etc.)

## Tasks:

- [ ] 🟩 **Step 1: Analyze Codebase and Identify Key Screens**
  - [ ] 🟩 Review TodosView.swift to understand view modes (List, Priority, Category, Date)
  - [ ] 🟩 Review SignInSheet.swift for authentication UI states
  - [ ] 🟩 Review TaskEditView.swift for task editing interface
  - [ ] 🟩 Review CategoryManagerView.swift for category management
  - [ ] 🟩 Review AppearanceView.swift for theme customization
  - [ ] 🟩 Review Models.swift to understand data structure (Task, Category, Priority)

- [ ] 🟩 **Step 2: Define Dummy Data Requirements**
  - [ ] 🟩 Create list of common, relatable tasks across different categories:
    - [ ] 🟩 Shopping & Errands: "Buy groceries", "Pick up dry cleaning", "Return library books"
    - [ ] 🟩 House & Repairs: "Fix leaky faucet", "Change air filter", "Organize garage"
    - [ ] 🟩 Tech & Apps: "Update phone software", "Backup photos", "Review app subscriptions"
    - [ ] 🟩 Finance & Admin: "Pay credit card bill", "File tax documents", "Review insurance policy"
    - [ ] 🟩 Travel & Health: "Schedule dentist appointment", "Book flight for vacation", "Renew passport"
    - [ ] 🟩 Vehicle & Motorcycle: "Get oil change", "Renew registration", "Check tire pressure"
  - [ ] 🟩 Assign realistic priorities (mix of High, Medium, Low, Deferred)
  - [ ] 🟩 Assign due dates (mix of today, tomorrow, this week, later, no date)
  - [ ] 🟩 Distribute tasks across categories to showcase category feature
  - [ ] 🟩 Include some tasks with notes for TaskEditView screenshot

- [ ] 🟩 **Step 3: Define Screenshot Requirements**
  - [ ] 🟩 Screenshot 1: Main Todos List View - Show active tasks with categories and priorities
  - [ ] 🟩 Screenshot 2: Sign-in Screen - Show authentication options (Apple, Google, Phone)
  - [ ] 🟩 Screenshot 3: Task Edit View - Show task details with categories, priority, due date
  - [ ] 🟩 Screenshot 4: Category View Mode - Show tasks organized by categories
  - [ ] 🟩 Screenshot 5: Appearance/Theme Selector - Show theme customization options
  - [ ] 🟩 Screenshot 6: Priority View Mode or Date View Mode - Show alternative organization view

- [ ] 🟩 **Step 4: Create Screenshot Guide Document**
  - [ ] 🟩 Create docs/SCREENSHOT_GUIDE.md with header and overview
  - [ ] 🟩 Document Screenshot 1: Main Todos List View
    - [ ] 🟩 Specify view: TodosView in List mode
    - [ ] 🟩 Specify state: "Doing" tab, 5-7 active tasks with varied priorities and categories
    - [ ] 🟩 Specify simulator: iPhone 17 Pro
    - [ ] 🟩 Specify data setup: Use common tasks from dummy data (e.g., "Buy groceries", "Fix leaky faucet", "Schedule dentist appointment")
    - [ ] 🟩 Document what it demonstrates: Core todo functionality, categories, priorities
  - [ ] 🟩 Document Screenshot 2: Sign-in Screen
    - [ ] 🟩 Specify view: SignInSheet (presented as sheet)
    - [ ] 🟩 Specify state: Fresh, not signed in, showing all auth options
    - [ ] 🟩 Specify simulator: iPhone 17 Pro
    - [ ] 🟩 Specify data setup: No user signed in, sheet ready state
    - [ ] 🟩 Document what it demonstrates: Easy authentication options
  - [ ] 🟩 Document Screenshot 3: Task Edit View
    - [ ] 🟩 Specify view: TaskEditView (presented as sheet)
    - [ ] 🟩 Specify state: Task with title, categories selected, priority set, due date set, notes
    - [ ] 🟩 Specify simulator: iPhone 17 Pro
    - [ ] 🟩 Specify data setup: Use realistic task from dummy data (e.g., "Fix leaky faucet" with House & Repairs category, High priority, due tomorrow, notes)
    - [ ] 🟩 Document what it demonstrates: Comprehensive task management
  - [ ] 🟩 Document Screenshot 4: Category View Mode
    - [ ] 🟩 Specify view: TodosView in Category mode
    - [ ] 🟩 Specify state: "Doing" tab, showing tasks grouped by categories
    - [ ] 🟩 Specify simulator: iPhone 17 Pro
    - [ ] 🟩 Specify data setup: Common tasks distributed across multiple categories (Shopping, House, Tech, Finance, etc.)
    - [ ] 🟩 Document what it demonstrates: Category-based organization
  - [ ] 🟩 Document Screenshot 5: Appearance View
    - [ ] 🟩 Specify view: AppearanceView (presented as sheet)
    - [ ] 🟩 Specify state: Showing theme mode picker and palette options
    - [ ] 🟩 Specify simulator: iPhone 17 Pro
    - [ ] 🟩 Specify data setup: Default appearance state
    - [ ] 🟩 Document what it demonstrates: Theme customization
  - [ ] 🟩 Document Screenshot 6: Priority View Mode
    - [ ] 🟩 Specify view: TodosView in Priority mode
    - [ ] 🟩 Specify state: "Doing" tab, showing tasks grouped by priority (High, Medium, Low, Deferred)
    - [ ] 🟩 Specify simulator: iPhone 17 Pro
    - [ ] 🟩 Specify data setup: Common tasks with different priorities (e.g., High: "Pay credit card bill", Medium: "Buy groceries", Low: "Organize garage")
    - [ ] 🟩 Document what it demonstrates: Priority-based organization

- [ ] 🟩 **Step 5: Add Setup Instructions**
  - [ ] 🟩 Add section for simulator setup (iPhone 17 Pro)
  - [ ] 🟩 Add section for dummy data creation with specific common tasks
    - [ ] 🟩 Provide exact task titles, categories, priorities, due dates
    - [ ] 🟩 Include step-by-step instructions for creating tasks in app
    - [ ] 🟩 Specify which tasks go in which categories
  - [ ] 🟩 Add step-by-step instructions for each screenshot
  - [ ] 🟩 Add notes about ensuring clean state, proper navigation, etc.

- [ ] 🟩 **Step 6: Add Technical Details**
  - [ ] 🟩 Specify iOS version requirements
  - [ ] 🟩 Add notes about screenshot dimensions for iPhone 17 Pro
  - [ ] 🟩 Add tips for best practices (clean status bar, no notifications, etc.)
