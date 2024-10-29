//
//  Filter.swift
//  UltimatePortfolioMe
//
//  Created by 吴晓军 on 2024/10/9.
//

import Foundation

struct Filter: Identifiable, Hashable {
    var id: UUID
    var name: String
    var icon: String
    var minModificationDate = Date.distantPast
    var tag: Tag?
    
    var activeIssuesCount: Int {
        tag?.tagActiveIssues.count ?? 0
    }
//String(localized: "Recent issues")
    static var all = Filter(
        id: UUID(),
        name: String(localized: "All Issues"),
        icon: "tray"
    )
    static var recent = Filter(
        id: UUID(),
        name: String(localized: "Recent issues"),
        icon: "clock",
        minModificationDate: .now.addingTimeInterval(86400 * -7)
    )

    //两种方法添加到Filter结构中，以便我们只使用id进行比较
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Filter, rhs: Filter) -> Bool {
        lhs.id == rhs.id
    }
}
