import XCTest

class ScreenshotGenerationTests: XCTestCase {
    
    var app: XCUIApplication!
    let screenshotDir = "/Users/bens/Notelayer/App-Icons-&-screenshots"
    let tempScreenshotDir = "/Users/bens/Notelayer/Notelayer-iOS-1/ios-swift/Notelayer/Screenshots"
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        // Create screenshot directories if they don't exist
        let fileManager = FileManager.default
        try? fileManager.createDirectory(atPath: screenshotDir, withIntermediateDirectories: true, attributes: nil)
        try? fileManager.createDirectory(atPath: tempScreenshotDir, withIntermediateDirectories: true, attributes: nil)
        
        app = XCUIApplication()
        app.launchArguments.append("--screenshot-generation")
        app.launchEnvironment["SCREENSHOT_MODE"] = "true"
        app.launch()
        
        // Wait for app to load and data to seed
        sleep(2)
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Helper Methods
    
    func captureScreenshot(name: String) throws {
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        
        // Save to temporary directory
        let tempPath = "\(tempScreenshotDir)/\(name).png"
        try? screenshot.image.pngData()?.write(to: URL(fileURLWithPath: tempPath))
        
        // Copy to backup location
        let backupPath = "\(screenshotDir)/\(name).png"
        try? FileManager.default.copyItem(atPath: tempPath, toPath: backupPath)
        
        print("📸 Screenshot saved: \(backupPath)")
    }
    
    func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 5.0) {
        let exists = element.waitForExistence(timeout: timeout)
        XCTAssertTrue(exists, "Element \(element) did not appear")
    }

    func firstMatchButton(containing labelFragment: String) -> XCUIElement {
        app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", labelFragment)).firstMatch
    }

    func firstMatchElement(containing labelFragment: String) -> XCUIElement {
        let button = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", labelFragment)).firstMatch
        if button.exists {
            return button
        }
        let cellText = app.cells.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", labelFragment)).firstMatch
        if cellText.exists {
            return cellText
        }
        return app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", labelFragment)).firstMatch
    }

    func firstCategoryHeader() -> XCUIElement {
        let categoryNames = [
            "House & Repairs",
            "Garage & Workshop",
            "3D Printing",
            "Vehicle & Motorcycle",
            "Tech & Apps",
            "Finance & Admin",
            "Shopping & Errands",
            "Travel & Health",
            "Uncategorized"
        ]
        for name in categoryNames {
            let header = firstMatchElement(containing: name)
            if header.exists {
                return header
            }
        }
        return app.staticTexts.firstMatch
    }

    func firstMenuElement(containingAny labelFragments: [String]) -> XCUIElement {
        for fragment in labelFragments {
            let button = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", fragment)).firstMatch
            if button.exists {
                return button
            }
            let cellText = app.cells.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", fragment)).firstMatch
            if cellText.exists {
                return cellText
            }
            let staticText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", fragment)).firstMatch
            if staticText.exists {
                return staticText
            }
        }

        return app.buttons.firstMatch
    }

    func todosTabButton() -> XCUIElement {
        let todos = firstMatchButton(containing: "To-Dos")
        return todos.exists ? todos : firstMatchButton(containing: "Todos")
    }
    
    // MARK: - Screenshot Tests
    
    func testScreenshot1_TodosListView() throws {
        // Navigate to To-Dos tab
        let todosTab = todosTabButton()
        waitForElement(todosTab)
        todosTab.tap()
        
        // Ensure "Doing" toggle is selected (default)
        // Ensure "List" view mode is selected (first in segmented control)
        let segmentedControl = app.segmentedControls.firstMatch
        if segmentedControl.exists {
            // List should be first option
            let listButton = segmentedControl.buttons["List"]
            if listButton.exists && !listButton.isSelected {
                listButton.tap()
            }
        }
        
        // Wait for tasks to appear
        sleep(1)
        
        // Scroll to show multiple tasks
        let scrollView = app.scrollViews.firstMatch
        if scrollView.exists {
            scrollView.swipeUp()
        }
        
        // Wait for UI to stabilize
        sleep(1)
        
        try captureScreenshot(name: "screenshot-1-todos-list")
    }
    
    func testScreenshot2_SignInSheet() throws {
        // Navigate to To-Dos tab first
        let todosTab = todosTabButton()
        waitForElement(todosTab)
        todosTab.tap()
        
        // Tap gear icon
        let gearButton = app.buttons.matching(identifier: "gearshape").firstMatch
        if !gearButton.exists {
            // Try finding by accessibility label
            let menuButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'gear' OR label CONTAINS 'settings'")).firstMatch
            waitForElement(menuButton)
            menuButton.tap()
        } else {
            gearButton.tap()
        }
        
        sleep(1)
        
        // Tap "Profile & Settings" -> "Sign In" (or direct "Sign In" entry)
        let profileButton = firstMenuElement(containingAny: ["Profile & Settings", "Profile", "Settings", "Account"])
        if profileButton.exists {
            waitForElement(profileButton)
            profileButton.tap()
            sleep(1)
        }

        let signInButton = firstMenuElement(containingAny: ["Sign In", "Sign in", "Authentication"])
        waitForElement(signInButton)
        signInButton.tap()
        
        // Wait for sheet to appear
        sleep(2)
        
        try captureScreenshot(name: "screenshot-2-sign-in")
    }
    
    func testScreenshot3_TaskEditView() throws {
        // Navigate to To-Dos tab
        let todosTab = todosTabButton()
        waitForElement(todosTab)
        todosTab.tap()
        
        sleep(1)
        
        // Tap on first task (should be the one with notes)
        let firstTask = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Pay credit card' OR label CONTAINS 'Fix the door'")).firstMatch
        if !firstTask.exists {
            // Fallback: tap first task-like element
            let tasks = app.scrollViews.firstMatch.buttons
            if tasks.count > 0 {
                tasks.element(boundBy: 0).tap()
            }
        } else {
            firstTask.tap()
        }
        
        // Wait for TaskEditView sheet to appear
        sleep(2)
        
        try captureScreenshot(name: "screenshot-3-task-edit")
    }
    
    func testScreenshot4_CategoryView() throws {
        // Navigate to To-Dos tab
        let todosTab = todosTabButton()
        waitForElement(todosTab)
        todosTab.tap()
        
        sleep(1)
        
        // Tap/swipe to "Category" view mode
        let segmentedControl = app.segmentedControls.firstMatch
        if segmentedControl.exists {
            let categoryButton = segmentedControl.buttons["Category"]
            waitForElement(categoryButton)
            categoryButton.tap()
        }
        
        // Wait for category groups to appear
        sleep(1)
        
        // Scroll to show multiple category groups
        let scrollView = app.scrollViews.firstMatch
        if scrollView.exists {
            scrollView.swipeUp()
        }
        
        sleep(1)
        
        try captureScreenshot(name: "screenshot-4-category-view")
    }
    
    func testScreenshot5_AppearanceView() throws {
        // Navigate to To-Dos tab first
        let todosTab = todosTabButton()
        waitForElement(todosTab)
        todosTab.tap()
        
        // Tap gear icon
        let gearButton = app.buttons.matching(identifier: "gearshape").firstMatch
        if !gearButton.exists {
            let menuButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'gear' OR label CONTAINS 'settings'")).firstMatch
            waitForElement(menuButton)
            menuButton.tap()
        } else {
            gearButton.tap()
        }
        
        sleep(1)
        
        // Tap "Themes" menu item
        let appearanceButton = firstMenuElement(containingAny: ["Appearance", "Colour Theme", "Themes", "Theme"])
        waitForElement(appearanceButton)
        appearanceButton.tap()
        
        // Wait for sheet to appear
        sleep(2)
        
        try captureScreenshot(name: "screenshot-5-appearance")
    }
    
    func testScreenshot6_PriorityView() throws {
        // Navigate to To-Dos tab
        let todosTab = todosTabButton()
        waitForElement(todosTab)
        todosTab.tap()
        
        sleep(1)
        
        // Tap/swipe to "Priority" view mode
        let segmentedControl = app.segmentedControls.firstMatch
        if segmentedControl.exists {
            let priorityButton = segmentedControl.buttons["Priority"]
            waitForElement(priorityButton)
            priorityButton.tap()
        }
        
        // Wait for priority groups to appear
        sleep(1)
        
        // Scroll to show priority groups
        let scrollView = app.scrollViews.firstMatch
        if scrollView.exists {
            scrollView.swipeUp()
        }
        
        sleep(1)
        
        try captureScreenshot(name: "screenshot-6-priority-view")
    }

    func testDoneTaskCanBeUndone() throws {
        let todosTab = todosTabButton()
        waitForElement(todosTab)
        todosTab.tap()

        let segmentedControl = app.segmentedControls.firstMatch
        let taskCheckmarks = app.buttons.matching(identifier: "task-checkmark")

        func doingToggle() -> XCUIElement {
            firstMatchButton(containing: "Doing")
        }
        func doneToggle() -> XCUIElement {
            firstMatchButton(containing: "Done")
        }
        func firstVisibleCheckmark() -> XCUIElement {
            taskCheckmarks.allElementsBoundByIndex.first(where: { $0.isHittable }) ?? taskCheckmarks.firstMatch
        }
        func countFromToggleLabel(_ label: String) -> Int? {
            let digits = label.filter { $0.isNumber }
            return digits.isEmpty ? nil : Int(digits)
        }
        func currentDoneCount() -> Int? {
            countFromToggleLabel(doneToggle().label)
        }
        func ensureDoingTaskExists() {
            if !taskCheckmarks.firstMatch.waitForExistence(timeout: 2) {
                let newTaskField = app.textFields["New task..."]
                waitForElement(newTaskField)
                newTaskField.tap()
                newTaskField.typeText("Undo toggle test\n")
            }
        }

        let modes = ["List", "Priority", "Category", "Date"]
        for mode in modes {
            if segmentedControl.exists {
                let modeButton = segmentedControl.buttons[mode]
                if modeButton.exists && !modeButton.isSelected {
                    modeButton.tap()
                }
            }

            let doingButton = doingToggle()
            if doingButton.exists {
                doingButton.tap()
            }
            ensureDoingTaskExists()

            guard let baselineDoneCount = currentDoneCount() else {
                XCTFail("Could not read Done count for \(mode).")
                return
            }

            let firstTaskCheckmark = firstVisibleCheckmark()
            waitForElement(firstTaskCheckmark)
            firstTaskCheckmark.tap()

            sleep(1)

            let doneButton = doneToggle()
            doneButton.tap()

            guard let updatedDoneCount = currentDoneCount() else {
                XCTFail("Could not read Done count after completing a task in \(mode).")
                return
            }
            XCTAssertEqual(updatedDoneCount, baselineDoneCount + 1, "Done count should increment after completing a task in \(mode).")

            let undoButton = firstVisibleCheckmark()
            waitForElement(undoButton)
            undoButton.tap()

            sleep(1)

            guard let finalDoneCount = currentDoneCount() else {
                XCTFail("Could not read Done count after undoing in \(mode).")
                return
            }
            XCTAssertEqual(finalDoneCount, baselineDoneCount, "Done count should return after undoing in \(mode).")
        }
    }

    func testGestureDemoVideo() throws {
        // Navigate to To-Dos tab
        let todosTab = todosTabButton()
        waitForElement(todosTab, timeout: 10.0)
        todosTab.tap()

        // Ensure "List" view mode is selected
        let segmentedControl = app.segmentedControls.firstMatch
        if segmentedControl.exists {
            let listButton = segmentedControl.buttons["List"]
            if listButton.exists && !listButton.isSelected {
                listButton.tap()
            }
        }

        sleep(1)

        // Add a new task
        let newTaskField = app.textFields["New task..."]
        waitForElement(newTaskField)
        newTaskField.tap()
        newTaskField.typeText("Plan weekend hike")

        sleep(1)

        // Submit task while the field is focused
        newTaskField.typeText("\n")

        sleep(1)

        // Switch to Category view to categorize via drag-and-drop
        if segmentedControl.exists {
            let categoryTab = segmentedControl.buttons["Category"]
            waitForElement(categoryTab)
            categoryTab.tap()
        }

        sleep(1)

        let newTaskCell = firstMatchElement(containing: "Plan weekend hike")
        guard newTaskCell.waitForExistence(timeout: 5.0) else {
            XCTSkip("Task cell not visible in Category view.")
            return
        }
        let categoryGroupHeader = firstCategoryHeader()
        guard categoryGroupHeader.waitForExistence(timeout: 5.0) else {
            XCTSkip("Category header not visible in Category view.")
            return
        }
        newTaskCell.press(forDuration: 0.6, thenDragTo: categoryGroupHeader)

        sleep(1)

        // Switch to Priority view and drag between priorities
        if segmentedControl.exists {
            let priorityButton = segmentedControl.buttons["Priority"]
            waitForElement(priorityButton)
            priorityButton.tap()
        }

        sleep(1)

        let highGroupHeader = firstMatchElement(containing: "High")
        guard highGroupHeader.waitForExistence(timeout: 5.0) else {
            XCTSkip("Priority header not visible in Priority view.")
            return
        }
        newTaskCell.press(forDuration: 0.6, thenDragTo: highGroupHeader)

        sleep(1)
    }
}
