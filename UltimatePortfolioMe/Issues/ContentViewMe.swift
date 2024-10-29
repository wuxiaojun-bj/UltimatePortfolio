//
//  ContentViewMe.swift
//  UltimatePortfolioMe
//
//  Created by 吴晓军 on 2024/10/9.
//

import SwiftUI

struct ContentViewMe: View {
    @EnvironmentObject var dataController: DataController

    var body: some View {
        List(selection: $dataController.selectedIssue) {
            ForEach(dataController.issuesForSelectedFilter()
            ) { issue in
                IssueRow(issue: issue)

            }
            .onDelete(perform: delete)
        }
        .navigationTitle("Issues")
        .searchable(
            text: $dataController.filterText,
            tokens: $dataController.filterTokens,
            suggestedTokens: .constant(dataController.suggestedFilterTokens),
            prompt: "Filter issues, or type # to add tags") { tag in
            Text(tag.tagName)
        }
        .toolbar(content: ContentViewToolbar.init)

    }
    
    func delete(_ offsets: IndexSet) {
        let issues = dataController.issuesForSelectedFilter()
        
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
