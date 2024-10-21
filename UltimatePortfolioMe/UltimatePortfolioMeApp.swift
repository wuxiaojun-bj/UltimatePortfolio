//
//  UltimatePortfolioMeApp.swift
//  UltimatePortfolioMe
//
//  Created by 吴晓军 on 2024/10/9.
//

import SwiftUI

@main
struct UltimatePortfolioMeApp: App {
    @StateObject var dataController = DataController()
    //观察场景相位变化
    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(dataController)
                .onChange(of: scenePhase) { 
                    phase in
                    if scenePhase != .active {
                        dataController.save()
                    }
                }
            //触发应用程序没有恢复活动状态的任何类型的相位变化的保存
        }
    }
}
