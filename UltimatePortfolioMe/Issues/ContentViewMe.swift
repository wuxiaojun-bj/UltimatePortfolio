//
//  ContentViewMe.swift
//  UltimatePortfolioMe
//
//  Created by 吴晓军 on 2024/10/9.
//

import SwiftUI

struct ContentViewMe: View {
    //要求用户查看我们的应用程序
    @Environment(\.requestReview) var requestReview

    @StateObject var viewModel: ViewModel
    
    //与快捷方式集成Siri
    private let newIssueActivity = "com.bjwuxiaojun.UltimatePortfolioMe.newIssue"

    //添加此初始化器以实例化并存储视图模型状态对象
    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)
        _viewModel = StateObject(wrappedValue: viewModel)
    }


    var body: some View {
        List(selection: $viewModel.selectedIssue) {
            //这是一个方法调用，而不是属性访问。
            ForEach(viewModel.dataController.issuesForSelectedFilter()
            ) { issue in
                IssueRow(issue: issue)

            }
            .onDelete(perform: viewModel.delete)
        }
        .navigationTitle("Issues")
        .searchable(
            text: $viewModel.filterText,
            tokens: $viewModel.filterTokens,
            suggestedTokens: .constant(viewModel.suggestedFilterTokens),
            prompt: "Filter issues, or type # to add tags") { tag in
            Text(tag.tagName)
        }
        .toolbar(content: ContentViewToolbar.init)
        .onAppear(perform: askForReview)
        .onOpenURL(perform: viewModel.openURL)
        //告诉iOS何时触发此活动
        .userActivity(newIssueActivity) { activity in
            activity.isEligibleForPrediction = true
            activity.title = "New Issue"
        }
        //最后一步是将其连接到SwiftUI，以便在我们的活动触发时运行
        .onContinueUserActivity(newIssueActivity, perform: resumeActivity)

    }
    
    //当审查是一个好主意时调用requestReview()：
    func askForReview() {
        if viewModel.shouldRequestReview {
            requestReview()
        }
    }
    
   
    
    //响应正在触发的活动Siri
    func resumeActivity(_ userActivity: NSUserActivity) {
        viewModel.dataController.newIssue()
    }


}

#Preview {
    ContentViewMe(dataController: .preview)
}
