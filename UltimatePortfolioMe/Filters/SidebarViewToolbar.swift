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
    
    var body: some View {
        Button(action: dataController.newTag) {
            Label("Add tag", systemImage: "plus")
        }
        
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
}

#Preview {
    SidebarViewToolbar()
        .environmentObject(DataController.preview)

}
