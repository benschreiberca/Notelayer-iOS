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
    
    // MARK: - Screenshot Tests
    
    func testScreenshot1_TodosListView() throws {
        // Navigate to Todos tab
        let todosTab = app.tabBars.buttons["Todos"]
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
        // Navigate to Todos tab first
        let todosTab = app.tabBars.buttons["Todos"]
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
        
        // Tap "Authentication" menu item
        let authButton = app.buttons["Authentication"]
        waitForElement(authButton)
        authButton.tap()
        
        // Wait for sheet to appear
        sleep(2)
        
        try captureScreenshot(name: "screenshot-2-sign-in")
    }
    
    func testScreenshot3_TaskEditView() throws {
        // Navigate to Todos tab
        let todosTab = app.tabBars.buttons["Todos"]
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
        // Navigate to Todos tab
        let todosTab = app.tabBars.buttons["Todos"]
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
        // Navigate to Todos tab first
        let todosTab = app.tabBars.buttons["Todos"]
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
        
        // Tap "Appearance" menu item
        let appearanceButton = app.buttons["Appearance"]
        waitForElement(appearanceButton)
        appearanceButton.tap()
        
        // Wait for sheet to appear
        sleep(2)
        
        try captureScreenshot(name: "screenshot-5-appearance")
    }
    
    func testScreenshot6_PriorityView() throws {
        // Navigate to Todos tab
        let todosTab = app.tabBars.buttons["Todos"]
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
}
