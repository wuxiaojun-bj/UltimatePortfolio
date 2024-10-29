//
//  Issue-CoreDataHelpers.swift
//  UltimatePortfolioMe
//
//  Created by 吴晓军 on 2024/10/14.
//

import Foundation

extension Issue {
    
    var issueTitle: String {
        get { title ?? "" }
        set { title = newValue }
    }

    var issueContent: String {
        get { content ?? "" }
        set { content = newValue }
    }

    var issueCreationDate: Date {
        creationDate ?? .now
    }

    var issueModificationDate: Date {
        modificationDate ?? .now
    }
    
    var issueStatus: String {
        if completed {
            return String(localized: "Closed")
        //    return "Closed"
        } else {
            return String(localized: "Open")
           // return "Open"
        }
    }
    
    var issueTags: [Tag] {
        let result = tags?.allObjects as? [Tag] ?? []
        return result.sorted()
    }
    
    var issueTagsList: String {
        guard let tags else {  return String(localized: "No tags") }

        if tags.count == 0 {
            return String(localized: "No tags")
            //String(localized: "NAME")
            //return "No tags"
        } else {
            return issueTags.map(\.tagName).formatted()
        }
    }

    
    static var example: Issue {
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext

        let issue = Issue(context: viewContext)
        issue.title = "Example Issue"
        issue.content = "This is an example issue."
        issue.priority = 2
        issue.creationDate = .now
        return issue
    }

}

extension Issue: Comparable {
    public static func <(lhs: Issue, rhs: Issue) -> Bool {
        let left = lhs.issueTitle.localizedLowercase
        let right = rhs.issueTitle.localizedLowercase

        if left == right {
            return lhs.issueCreationDate < rhs.issueCreationDate
        } else {
            return left < right
        }
    }
}

