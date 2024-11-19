//
//  SidebarViewToolbar.swift
//  UltimatePortfolioMe
//
//  Created by 吴晓军 on 2024/10/27.
//

import SwiftUI

struct SidebarViewToolbar: View {
    @EnvironmentObject var dataController: DataController
    
    //跟踪奖励表是否显示
    @State private var showingAwards = false
    
    //添加一个新的属性来跟踪商店是否显示
    @State private var showingStore = false
    
    var body: some View {
        //在添加新标签失败时显示升级存储购买
        Button(action: tryNewTag) {
            Label("Add tag", systemImage: "plus")
        }
        .sheet(isPresented: $showingStore, content: StoreView.init)

        Button {
            showingAwards.toggle()
        } label: {
            Label("Show awards", systemImage: "rosette")
        }
        .sheet(isPresented: $showingAwards, content: AwardsView.init)
#if DEBUG
        Button {
            dataController.deleteAll()
            dataController.createSampleData()
        } label: {
            Label("ADD SAMPLES", systemImage: "flame")
        }
#endif
    }
    
    //运行newTag()，并在失败时显示存储购买
    func tryNewTag() {
        if dataController.newTag() == false {
            showingStore = true
        }
    }

}

#Preview {
    SidebarViewToolbar()
        .environmentObject(DataController.preview)

}
