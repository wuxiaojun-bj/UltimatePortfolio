//
//  UltimatePortfolioMeApp.swift
//  UltimatePortfolioMe
//
//  Created by 吴晓军 on 2024/10/9.
//
import CoreSpotlight
import SwiftUI

@main
struct UltimatePortfolioMeApp: App {
    @StateObject var dataController = DataController()
    //观察场景相位变化
    @Environment(\.scenePhase) var scenePhase
    
    //告诉SwiftUI将该AppDelegate类用于它目前无法处理的任何UIKit功能
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                SidebarView(dataController: dataController)
            } content: {
                ContentViewMe(dataController: dataController)
            } detail: {
                DetailView()
            }
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
            .onChange(of: scenePhase) {
                phase in
                //触发应用程序没有恢复活动状态的任何类型的相位变化的保存
                if scenePhase != .active {
                    dataController.save()
                }
            }
            .onContinueUserActivity(CSSearchableItemActionType, perform: loadSpotlightItem)
            //这使我们的SwiftUI应用程序能够响应Spotlight应用程序的启动，因此现在当我们的应用程序被Spotlight激活时，我们只需要调用loadSpotlightItem()。这作为修饰符附加到任何SwiftUI视图中
        }
    }
    
    //该方法将接受任何类型的NSUserActivity，然后查看其数据，从Spotlight中找到唯一标识符,NSUserActivity有一个userInfo字典，我们需要在其中挖掘一个特定的Core Spotlight密钥，以读出我们问题的标识符。如果字典存在，如果密钥存在，并且其值是字符串，那么我们将使用它。
    func loadSpotlightItem(_ userActivity: NSUserActivity) {
        if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
            dataController.selectedIssue = dataController.issue(with: uniqueIdentifier)
            dataController.selectedFilter = .all
        }
    }
}
