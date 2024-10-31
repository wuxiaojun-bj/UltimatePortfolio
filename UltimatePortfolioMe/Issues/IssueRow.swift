//
//  IssueRow.swift
//  UltimatePortfolioMe
//
//  Created by 吴晓军 on 2024/10/15.
//

import SwiftUI

struct IssueRow: View {
    @EnvironmentObject var dataController: DataController
    
    @ObservedObject var issue: Issue
    
    var body: some View {
        NavigationLink(value: issue) {
            HStack {
                Image(systemName: "exclamationmark.circle")
                    .imageScale(.large)
                    .opacity(issue.priority == 2 ? 1 : 0)
                    .accessibilityIdentifier(issue.priority == 2 ? "\(issue.issueTitle) High Priority" : "")
                //增加了一个仅用于测试的优先级标识符
                VStack(alignment: .leading) {
                    Text(issue.issueTitle)
                        .font(.headline)
                        .lineLimit(1)

                    Text(issue.issueTagsList)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text(issue.issueCreationDate.formatted(date: .numeric, time: .omitted))
                        .accessibilityLabel(issue.issueCreationDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline)

                    if issue.completed {
                        Text("CLOSED")
                            .font(.body.smallCaps())
                    }
                }
                .foregroundStyle(.secondary)

            }
        }
        .accessibilityHint(issue.priority == 2 ? "High priority" : "")
        .accessibilityIdentifier(issue.issueTitle)
//增加了一个仅用于测试的奖励标识符
    }
}

#Preview {
    IssueRow(issue: .example)

}
