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
            return NSLocalizedString("Closed", comment: "This issue has been resolved by the user.")
        //    return String(localized: "Closed")
        //    return "Closed"
        } else {
            return NSLocalizedString("Open", comment: "This issue is currently unresolved.")
          //  return String(localized: "Open")
           // return "Open"
        }
    }
    
    var issueTags: [Tag] {
        let result = tags?.allObjects as? [Tag] ?? []
        return result.sorted()
    }
    
    var issueTagsList: String {
        let noTags = NSLocalizedString("No tags", comment: "The user has not created any tags yet")
        
        guard let tags else { return noTags }

        if tags.count == 0 {
            return noTags
            //return "No tags"
        } else {
            return issueTags.map(\.tagName).formatted()
        }
    }
    
    var issueReminderTime: Date {
        get { reminderTime ?? .now }
        set { reminderTime = newValue }
    }

    
    static var example: Issue {
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext

        let issue = Issue(context: viewContext)
        //String(localized: "Example Issue")
        //String(localized: "This is an example issue.")
        issue.title = String(localized: "Example Issue")
        issue.content = String(localized: "This is an example issue.")
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

