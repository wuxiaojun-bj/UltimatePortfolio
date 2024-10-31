//
//  ExtensionTests.swift
//  UltimatePortfolioMeTests
//
//  Created by 吴晓军 on 2024/10/30.
//测试扩展
//添加评论,使用“给定(Given)，何时(When)，然后(Then)”评论。

import CoreData
import XCTest
@testable import UltimatePortfolioMe

final class ExtensionTests: BaseTestCase {
    //我们将编写测试issueTitle的getter和setter，确保两者都通过Core Data的title属性。
    func testIssueTitleUnwrap() {
        let issue = Issue(context: managedObjectContext)

        issue.title = "Example issue"
        XCTAssertEqual(issue.issueTitle, "Example issue", "Changing title should also change issueTitle.")

        issue.issueTitle = "Updated issue"
        XCTAssertEqual(issue.title, "Updated issue", "Changing issueTitle should also change title.")
    }

    func testIssueContentUnwrap() {
        //给定(Given)
        let issue = Issue(context: managedObjectContext)
        
        //何时(When)
        issue.content = "Example issue"
        
        //然后(Then)
        XCTAssertEqual(issue.issueContent, "Example issue", "Changing content should also change issueContent.")

        //何时(When)
        issue.issueContent = "Updated issue"
        
        //然后(Then)
        XCTAssertEqual(issue.content, "Updated issue", "Changing issueContent should also change content.")
    }

    func testIssueCreationDateUnwrap() {
        // Given
        let issue = Issue(context: managedObjectContext)
        let testDate = Date.now

        // When
        issue.creationDate = testDate

        // Then
        XCTAssertEqual(issue.issueCreationDate, testDate, "Changing creationDate should also change issueCreationDate.")
    }

    //着同时创建问题和标签，将一个添加到另一个，然后对结果做出断言
    func testIssueTagsUnwrap() {
        let tag = Tag(context: managedObjectContext)
        let issue = Issue(context: managedObjectContext)

        XCTAssertEqual(issue.issueTags.count, 0, "A new issue should have no tags.")

        issue.addToTags(tag)
        XCTAssertEqual(issue.issueTags.count, 1, "Adding 1 tag to an issue should result in issueTags having count 1.")
    }

    func testIssueTagsList() {
        let tag = Tag(context: managedObjectContext)
        let issue = Issue(context: managedObjectContext)

        tag.name = "My Tag"
        issue.addToTags(tag)

        XCTAssertEqual(issue.issueTagsList, "My Tag", "Adding 1 tag to an issue should make issueTagsList be My Tag.")
    }

    //排序顺序在未来不会意外改变
    func testIssueSortingIsStable() {
        let issue1 = Issue(context: managedObjectContext)
        issue1.title = "B Issue"
        issue1.creationDate = .now

        let issue2 = Issue(context: managedObjectContext)
        issue2.title = "B Issue"
        issue2.creationDate = .now.addingTimeInterval(1)

        let issue3 = Issue(context: managedObjectContext)
        issue3.title = "A Issue"
        issue3.creationDate = .now.addingTimeInterval(100)

        let allIssues = [issue1, issue2, issue3]
        let sorted = allIssues.sorted()
//排序问题数组应使用名称，然后使用创建日期
        XCTAssertEqual([issue3, issue1, issue2], sorted, "Sorting issue arrays should use name then creation date.")
    }

    func testTagIDUnwrap() {
        let tag = Tag(context: managedObjectContext)

        tag.id = UUID()
        XCTAssertEqual(tag.tagID, tag.id, "Changing id should also change tagID.")
    }

    func testTagNameUnwrap() {
        let tag = Tag(context: managedObjectContext)

        tag.name = "Example Tag"
        XCTAssertEqual(tag.tagName, "Example Tag", "Changing name should also change tagName.")
    }

    func testTagActiveIssues() {
        let tag = Tag(context: managedObjectContext)
        let issue = Issue(context: managedObjectContext)

        XCTAssertEqual(tag.tagActiveIssues.count, 0, "A new tag should have 0 active issues.")

        tag.addToIssues(issue)
        XCTAssertEqual(tag.tagActiveIssues.count, 1, "A new tag with 1 new issue should have 1 active issue.")

        issue.completed = true
        XCTAssertEqual(tag.tagActiveIssues.count, 0, "A new tag with 1 completed issue should have 0 active issues.")
    }
    
//排序标签数组应使用名称，然后是UUID字符串
    func testTagSortingIsStable() {
        let tag1 = Tag(context: managedObjectContext)
        tag1.name = "B Tag"
        tag1.id = UUID()

        let tag2 = Tag(context: managedObjectContext)
        tag2.name = "B Tag"
        tag2.id = UUID(uuidString: "FFFFFFFF-FFFF-4526-B53A-55F1B0B895A1")

        let tag3 = Tag(context: managedObjectContext)
        tag3.name = "A Tag"
        tag3.id = UUID()

        let allTags = [tag1, tag2, tag3]
        let sortedTags = allTags.sorted()

        XCTAssertEqual([tag3, tag1, tag2], sortedTags, "Sorting tag array should use name then UUID string.")
    }

    //捆绑加载Awards.json应该解码为非空数组。
    func testBundleDecodingAwards() {
        let awards = Bundle.main.decode("Awards.json", as: [Award].self)
        XCTAssertFalse(awards.isEmpty, "Awards.json should decode to a non-empty array.")
    }
    
//这测试了我们的扩展能够加载最简单的JSON——只有一个值
    func testDecodingString() {
        let bundle = Bundle(for: ExtensionTests.self)
        let data = bundle.decode("DecodableString.json", as: String.self)
        XCTAssertEqual(data, "Never ask a starfish for directions.", "The string must match DecodableString.json")
    }
    
//这将测试我们的扩展是否能够加载数据字典。
    func testDecodingDictionary() {
        let bundle = Bundle(for: ExtensionTests.self)
        let data = bundle.decode("DecodableDictionary.json", as: [String: Int].self)

        XCTAssertEqual(data.count, 3, "There should be three items decoded from DecodableDictionary.json")
        XCTAssertEqual(data["One"], 1, "The dictionary should contain the value 1 for the key One.")
    }
}
