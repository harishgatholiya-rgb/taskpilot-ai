import XCTest

final class TaskPilotAIUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAppLaunchesToDashboard() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.tabBars.buttons["Dashboard"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.tabBars.buttons["Tasks"].exists)
    }

    func testQuickAddCreatesATask() throws {
        let app = XCUIApplication()
        app.launch()

        app.navigationBars.buttons["Quick Add Task"].tap()

        let titleField = app.textFields["Task title"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 5))
        titleField.tap()
        titleField.typeText("Buy milk")

        app.navigationBars.buttons["Save"].tap()

        app.tabBars.buttons["Tasks"].tap()
        XCTAssertTrue(app.staticTexts["Buy milk"].waitForExistence(timeout: 5))
    }
}
