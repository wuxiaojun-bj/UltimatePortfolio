//
//  DevelopmentTests.swift
//  UltimatePortfolioMeTests
//
//  Created by 吴晓军 on 2024/10/30.
//测试开发数据


import CoreData
import XCTest
@testable import UltimatePortfolioMe

final class DevelopmentTests: BaseTestCase {
    //第一个测试：当我们创建样本数据时，我们最终会有5个标签和50个问题吗？
    func testSampleDataCreationWorks() {
        dataController.createSampleData()

        XCTAssertEqual(dataController.count(for: Tag.fetchRequest()), 5, "There should be 5 sample tags.")
        XCTAssertEqual(dataController.count(for: Issue.fetchRequest()), 50, "There should be 5 sample issues.")
    }

    //确保deleteAll()方法确实会删除所有内容。
    func testDeleteAllClearsEverything() {
        dataController.createSampleData()
        dataController.deleteAll()

        XCTAssertEqual(dataController.count(for: Tag.fetchRequest()), 0, "deleteAll() should leave 0 sample tags.")
        XCTAssertEqual(dataController.count(for: Issue.fetchRequest()), 0, "deleteAll() should leave 0 sample issues.")
    }
    
//确保当我们的示例Tag创建时，它里面没有问题。
    func testExampleTagHasNoIssues() {
        let tag = Tag.example
        XCTAssertEqual(tag.issues?.count, 0, "The example tag should have 0 issues.")
    }

    //确保在创建我们的示例Issue时，它具有高度优先级
    func testExampleIssueIsHighPriority() {
        let issue = Issue.example
        XCTAssertEqual(issue.priority, 2, "The example issue should be high priority.")
    }
}
