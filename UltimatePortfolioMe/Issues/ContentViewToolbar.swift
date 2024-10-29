//
//  ContentViewToolbar.swift
//  UltimatePortfolioMe
//
//  Created by 吴晓军 on 2024/10/27.
//

import SwiftUI

struct ContentViewToolbar: View {
    @EnvironmentObject var dataController: DataController
    
    var body: some View {
        Menu {
            Button(dataController.filterEnabled ? "Turn Filter Off" : "Turn Filter On") {
                dataController.filterEnabled.toggle()
            }

            Divider()

            Menu("Sort By") {
                Picker("Sort By", selection: $dataController.sortType) {
                    Text("Date Created").tag(SortType.dateCreated)
                    Text("Date Modified").tag(SortType.dateModified)
                }

                Divider()

                Picker("Sort Order", selection: $dataController.sortNewestFirst) {
                    Text("Newest to Oldest").tag(true)
                    Text("Oldest to Newest").tag(false)
                }
            }

            Picker("Status", selection: $dataController.filterStatus) {
                Text("All").tag(Status.all)
                Text("Open").tag(Status.open)
                Text("Closed").tag(Status.closed)
            }
        //如果过滤器被关闭，状态和优先级选择器都应该被禁用
            .disabled(dataController.filterEnabled == false)

            Picker("Priority", selection: $dataController.filterPriority) {
                Text("All").tag(-1)
                Text("Low").tag(0)
                Text("Medium").tag(1)
                Text("High").tag(2)
            }
            .disabled(dataController.filterEnabled == false)
        } label: {
            Label("Filter", systemImage: "line.3.horizontal.decrease.circle") .symbolVariant(dataController.filterEnabled ? .fill : .none)
        }
        
        Button(action: dataController.newIssue) {
            Label("New Issue", systemImage: "square.and.pencil")
        }

    }
}

#Preview {
    ContentViewToolbar()
        .environmentObject(DataController.preview)
}
