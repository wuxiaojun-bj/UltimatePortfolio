//
//  IssueView.swift
//  UltimatePortfolioMe
//
//  Created by 吴晓军 on 2024/10/16.
//

import SwiftUI

struct IssueView: View {
    @EnvironmentObject var dataController: DataController

    @ObservedObject var issue: Issue
    
    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading) {
                    TextField("Title", text: $issue.issueTitle, prompt: Text("Enter the issue title here"))
                        .font(.title)
                    
                    Text("**Modified:** \(issue.issueModificationDate.formatted(date: .long, time: .shortened))")
                        .foregroundStyle(.secondary)
                    
                    Text("**Status:** \(issue.issueStatus)")
                        .foregroundStyle(.secondary)
                }
                
                Picker("Priority", selection: $issue.priority) {
                    Text("Low").tag(Int16(0))
                    Text("Medium").tag(Int16(1))
                    Text("High").tag(Int16(2))
                }
                
                TagsMenuView(issue: issue)
            }
            
            Section {
                VStack(alignment: .leading) {
                    Text("Basic Information")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    
                    TextField(
                        "Description",
                        text: $issue.issueContent,
                        prompt: Text("Enter the issue description here"),
                        axis: .vertical
                    )
                }
            }
            
        }
        .disabled(issue.isDeleted)
        //发现更新后保存
        .onReceive(issue.objectWillChange) { _ in
            dataController.queueSave()
        }
        .onSubmit(dataController.save)
        .toolbar {
            IssueViewToolbar(issue: issue)
        }


//如果他们选择一个问题，然后调出侧边栏并删除所选问题，我们不应该让他们尝试进行任何进一步的更改。
//onReceive()修饰符自动排队保存，onSubmit()修饰符立即运行保存
    }
}

#Preview {
    IssueView(issue: .example)
        .environmentObject(DataController.preview)
}
