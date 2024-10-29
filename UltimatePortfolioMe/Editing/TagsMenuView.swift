//
//  TagsMenuView.swift
//  UltimatePortfolioMe
//
//  Created by 吴晓军 on 2024/10/27.
//

import SwiftUI

struct TagsMenuView: View {
    @EnvironmentObject var dataController: DataController
    
    @ObservedObject var issue: Issue
    
    var body: some View {
        Menu {
            // 首先显示选定的标签
            ForEach(issue.issueTags) { tag in
                Button {
                    issue.removeFromTags(tag)
                } label: {
                    Label(tag.tagName, systemImage: "checkmark")
                }
            }
            
            // 现在显示未选择的标签
            let otherTags = dataController.missingTags(from: issue)
            
            if otherTags.isEmpty == false {
                Divider()
                
                Section("Add Tags") {
                    ForEach(otherTags) { tag in
                        Button(tag.tagName) {
                            issue.addToTags(tag)
                        }
                    }
                }
            }
        } label: {
            Text(issue.issueTagsList)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .animation(nil, value: issue.issueTagsList)

        }
        
    }
}

#Preview {
    TagsMenuView(issue: .example)
        .environmentObject(DataController.preview)
      //  .environmentObject(DataController(inMemory: true))
}
