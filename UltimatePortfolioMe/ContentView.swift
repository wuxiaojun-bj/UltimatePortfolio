//
//  ContentView.swift
//  UltimatePortfolioMe
//
//  Created by 吴晓军 on 2024/10/9.
// github test

import SwiftUI

struct ContentView: View {
    @StateObject var dataController = DataController()
    
    var body: some View {
        NavigationSplitView {
            SidebarView(dataController: dataController)
        } content: {
            ContentViewMe(dataController: dataController)
        } detail: {
            DetailView()
        }
    }
    
}

#Preview {
    ContentView()
        .environmentObject(DataController.preview)
}
