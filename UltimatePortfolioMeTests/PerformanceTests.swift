//
//  PerformanceTests.swift
//  UltimatePortfolioMeTests
//
//  Created by 吴晓军 on 2024/10/30.
//衡量性能

import XCTest
@testable import UltimatePortfolioMe

final class PerformanceTests: BaseTestCase {
    func testAwardCalculationPerformance() {
        for _ in 1...100 {
            dataController.createSampleData()
        }

        let awards = Array(repeating: Award.allAwards, count: 25).joined()
        XCTAssertEqual(awards.count, 500, "This checks the awards count is constant. Change this if you add awards.")

        measure {
            _ = awards.filter(dataController.hasEarned)
        }
    }
}

