//
//  UltimatePortfolioUITests.swift
//  UltimatePortfolioUITests
//
//  Created by 吴晓军 on 2024/10/30.
//

import XCTest

extension XCUIElement {
    func clear() {
        guard let stringValue = self.value as? String else {
            XCTFail("Failed to clear text in XCUIElement")
            return
        }

        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        typeText(deleteString)
    }
}

final class UltimatePortfolioUITests: XCTestCase {
    //将应用程序作为测试用例的属性，然后在setUpWithError()中配置和启动它。
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
//创建、配置和启动应用程序
        app = XCUIApplication()
        app.launchArguments = ["enable-testing"]
        app.launch()
    }
    
//验证导航栏的存在
    func testAppStartsWithNavigationBar() throws {
        XCTAssertTrue(app.navigationBars.element.exists, "There should be a navigation bar when the app launches.")
    }
    
//测试验证我们的“过滤器”（后退按钮）、“过滤器”和“新问题”按钮是否都存在：
    func testAppHasBasicButtonsOnLaunch() throws {
        XCTAssertTrue(app.navigationBars.buttons["Filters"].exists, "There should be a Filters button on launch.")
        XCTAssertTrue(app.navigationBars.buttons["Filter"].exists, "There should be a Filters button on launch.")
        XCTAssertTrue(app.navigationBars.buttons["New Issue"].exists, "There should be a Filters button on launch.")
    }

    //将检查我们的问题列表默认为空,应用程序启动时没有单元格
    func testNoIssuesAtStart() {
        XCTAssertEqual(app.cells.count, 0, "There should be 0 list rows initially.")
    }

    //创建五个问题，并验证每个问题是否正确创建,我们实际上可以通过测试添加然后删除问题来进一步进行测试：添加所有五个，然后滑动删除所有五个，两次计算，我们都有正确的单元格数量。
    func testCreatingAndDeletingIssues() {
        for tapCount in 1...5 {
            app.buttons["New Issue"].tap()
            app.buttons["Issues"].tap()

            XCTAssertEqual(app.cells.count, tapCount, "There should be \(tapCount) rows in the list.")
        }

        for tapCount in (0...4).reversed() {
            app.cells.firstMatch.swipeLeft()
            app.buttons["Delete"].tap()

            XCTAssertEqual(app.cells.count, tapCount, "There should be \(tapCount) rows in the list.")
        }
    }

    //检查详细视图
    func testEditingIssueTitleUpdatesCorrectly() {
        XCTAssertEqual(app.cells.count, 0, "There should be no rows initially.")

        app.buttons["New Issue"].tap()

        app.textFields["Enter the issue title here"].tap()
        app.textFields["Enter the issue title here"].clear()
        app.typeText("My New Issue")

        app.buttons["Issues"].tap()
        XCTAssertTrue(app.buttons["My New Issue"].exists, "A My New Issue cell should now exists.")
    }

    func testEditingIssuePriorityShowsIcon() {
        app.buttons["New Issue"].tap()
        app.buttons["Priority, Medium"].tap()
        app.buttons["High"].tap()
        app.buttons["Issues"].tap()

        let identifier = "New issue High Priority"
        XCTAssert(app.images[identifier].exists, "A high-priority issue needs an icon next to it.")
    }

    //触发警报
    /*
    func testAllAwardsShowLockedAlert() {
        app.buttons["Filters"].tap()
        app.buttons["Show awards"].tap()

        for award in app.scrollViews.buttons.allElementsBoundByIndex {
            
            if app.windows.element.frame.contains(award.frame) == false {
                app.swipeUp()
            }

            award.tap()
            XCTAssertTrue(app.alerts["Locked"].exists, "There should be a Locked alert showing this award.")
            app.buttons["OK"].tap()
        }
    }
    */
}
