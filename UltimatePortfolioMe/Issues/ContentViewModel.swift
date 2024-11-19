//
//  ContentViewModel.swift
//  UltimatePortfolioMe
//
//  Created by 吴晓军 on 2024/11/1.
//

import Foundation

extension ContentViewMe {
    
    //动态会员查找.作为包装对象和外部世界之间的桥梁。
    @dynamicMemberLookup
    class ViewModel: ObservableObject {
        var dataController: DataController
        
        //为了最大限度地提高用户撰写正面评论的机会，您应该只在他们使用该应用程序一段时间后才询问。我们将检查他们至少创建了五个标签，这意味着他们已经购买了高级解锁。
        var shouldRequestReview: Bool {
            dataController.count(for: Tag.fetchRequest()) >= 5
        }

        init(dataController: DataController) {
            self.dataController = dataController
        }
        
        subscript<Value>(dynamicMember keyPath: KeyPath<DataController, Value>) -> Value {
            dataController[keyPath: keyPath]
        }

        subscript<Value>(dynamicMember keyPath: ReferenceWritableKeyPath<DataController, Value>) -> Value {
            get { dataController[keyPath: keyPath] }
            set { dataController[keyPath: keyPath] = newValue }
        }
        
        func delete(_ offsets: IndexSet) {
            let issues = dataController.issuesForSelectedFilter()
            
            for offset in offsets {
                let item = issues[offset]
                dataController.delete(item)
            }
        }
        
        //在我们的图标中添加快速操作
        func openURL(_ url: URL) {
            if url.absoluteString.contains("newIssue") {
                dataController.newIssue()
            } else if let issue = dataController.issue(with: url.absoluteString) {
                dataController.selectedIssue = issue
                dataController.selectedFilter = .all
            }
        }
        
    }
}
