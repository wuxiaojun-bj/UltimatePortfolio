//
//  AssetTests.swift
//  UltimatePortfolioMeTests
//
//  Created by 吴晓军 on 2024/10/30.
//

import XCTest
@testable import UltimatePortfolioMe

final class AssetTests: XCTestCase {
    func testColorsExist() {
        let allColors = ["Dark Blue", "Dark Gray", "Gold", "Gray", "Green",
                         "Light Blue", "Midnight", "Orange", "Pink", "Purple", "Red", "Teal"]

        for color in allColors {
            XCTAssertNotNil(UIColor(named: color), "Failed to load color '\(color)' from asset catalog.")
        }
    }

    func testAwardsLoadCorrectly() {
        XCTAssertTrue(Award.allAwards.isEmpty == false, "Failed to load awards from JSON.")
    }
}

//将来，您将按Cmd+U运行所有测试，单击单个测试标记运行一个测试方法或其类，或使用有用的快捷方式Ctrl+Opt+Cmd+G仅运行之前的测试。
