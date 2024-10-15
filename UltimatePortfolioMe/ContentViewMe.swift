//
//  ContentViewMe.swift
//  UltimatePortfolioMe
//
//  Created by 吴晓军 on 2024/10/9.
//

import SwiftUI

struct ContentViewMe: View {
    @EnvironmentObject var dataController: DataController

    var issues: [Issue] {
        let filter = dataController.selectedFilter ?? .all
        var allIssues: [Issue]

        if let tag = filter.tag {
            allIssues = tag.issues?.allObjects as? [Issue] ?? []
        } else {
            let request = Issue.fetchRequest()
            //这告诉Core Data仅匹配自我们过滤器的最小修改日期以来修改的问题。
            request.predicate = NSPredicate(format: "modificationDate > %@", filter.minModificationDate as NSDate)

            allIssues = (try? dataController.container.viewContext.fetch(request)) ?? []
        }

        return allIssues.sorted()
    }

    
    var body: some View {
        List {
            ForEach(issues) { issue in
                IssueRow(issue: issue)

            }
            .onDelete(perform: delete)
        }
        .navigationTitle("Issues")

    }
    
    func delete(_ offsets: IndexSet) {
        for offset in offsets {
            let item = issues[offset]
            dataController.delete(item)
        }
    }
}

#Preview {
    ContentViewMe()
        .environmentObject(DataController.preview)
}
