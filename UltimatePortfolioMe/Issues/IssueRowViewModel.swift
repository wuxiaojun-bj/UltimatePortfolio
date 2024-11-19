//
//  IssueRowViewModel.swift
//  UltimatePortfolioMe
//
//  Created by 吴晓军 on 2024/11/1.
//

import Foundation

extension IssueRow {
    //我们的@dynamicMemberLookup下标所做的是告诉Swift，Issue上的所有属性都可以看起来像存在于视图模型上。它们实际上并不存在——下标中的代码说“当用户要求密钥路径时，只需将其传递给问题并将其值发回”——但这意味着我们代码的其余部分要干净得多。

    @dynamicMemberLookup
    class ViewModel: ObservableObject {
        let issue: Issue
        
        init(issue: Issue) {
            self.issue = issue
        }
        
        //动态查找成员名称（即属性）。这是如何通过一个特殊的下标发生的,我们现在可以直接在视图模型上从issue中访问属性
        subscript<Value>(dynamicMember keyPath: KeyPath<Issue, Value>) -> Value {
            issue[keyPath: keyPath]
        }
       
        //修饰符中的三元条件
        var iconOpacity: Double {
            issue.priority == 2 ? 1 : 0
        }
        
        //图标的可访问性标识符
        var iconIdentifier: String {
            issue.priority == 2 ? "\(issue.issueTitle) High Priority" : ""
        }

        //
        var accessibilityHint: String {
            issue.priority == 2 ? "High priority" : ""
        }

        var accessibilityCreationDate: String {
            issue.issueCreationDate.formatted(date: .abbreviated, time: .omitted)
        }

        var creationDate: String {
            issue.issueCreationDate.formatted(date: .numeric, time: .omitted)
        }

    }
}
