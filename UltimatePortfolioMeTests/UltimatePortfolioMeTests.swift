//
//  UltimatePortfolioMeTests.swift
//  UltimatePortfolioMeTests
//
//  Created by 吴晓军 on 2024/10/30.
//

import CoreData
import XCTest
@testable import UltimatePortfolioMe

class BaseTestCase: XCTestCase {
    var dataController: DataController!
    var managedObjectContext: NSManagedObjectContext!

    override func setUpWithError() throws {
        dataController = DataController(inMemory: true)
        managedObjectContext = dataController.container.viewContext
    }
}
