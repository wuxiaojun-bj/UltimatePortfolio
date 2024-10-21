//
//  ContentView.swift
//  UltimatePortfolioMe
//
//  Created by 吴晓军 on 2024/10/9.
// github test

import SwiftUI

struct ContentView: View {
 //   @EnvironmentObject var dataController: DataController
    
    var body: some View {
        NavigationSplitView {
            SidebarView()
        } content: {
            ContentViewMe()
        } detail: {
            DetailView()
        }
    }
    
}

#Preview {
    ContentView()
        .environmentObject(DataController.preview)
}
