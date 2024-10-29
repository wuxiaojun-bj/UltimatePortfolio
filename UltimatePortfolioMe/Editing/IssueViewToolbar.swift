//
//  IssueViewToolbar.swift
//  UltimatePortfolioMe
//
//  Created by 吴晓军 on 2024/10/27.
//

import SwiftUI

struct IssueViewToolbar: View {
    @EnvironmentObject var dataController: DataController
    
    @ObservedObject var issue: Issue
    
    var openCloseButtonText: LocalizedStringKey {
        issue.completed ? "Re-open Issue" : "Close Issue"
    }

    var body: some View {
        Menu {
            Button {
                UIPasteboard.general.string = issue.title
            } label: {
                Label("Copy Issue Title", systemImage: "doc.on.doc")
            }

            Button {
                issue.completed.toggle()
                dataController.save()
            } label: {
                Label(openCloseButtonText, systemImage: "bubble.left.and.exclamationmark.bubble.right")
            }
        } label: {
            Label("Actions", systemImage: "ellipsis.circle")
        }

    }
}

#Preview {
    IssueViewToolbar(issue: Issue.example)

}
