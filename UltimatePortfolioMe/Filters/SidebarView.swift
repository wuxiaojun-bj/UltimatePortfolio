//
//  SidebarView.swift
//  UltimatePortfolioMe
//
//  Created by 吴晓军 on 2024/10/9.
//

import SwiftUI

struct SidebarView: View {
    @StateObject private var viewModel: ViewModel
    let smartFilters: [Filter] = [.all, .recent]
    
    //该初始化器接受数据控制器并使用它来创建视图模型
    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List(selection: $viewModel.dataController.selectedFilter) {
            Section("Smart Filters") {
                ForEach(smartFilters, content: SmartFilterRow.init)
            }
            
            Section("Tags") {
                ForEach(viewModel.tagFilters) { filter in
                    UserFilterRow(filter: filter, 
                                  rename: viewModel.rename,
                                  delete: viewModel.delete)
                }
                .onDelete(perform: viewModel.delete)
            }
        }
        .toolbar(content: SidebarViewToolbar.init)
        .alert("Rename tag", isPresented: $viewModel.renamingTag) {
            Button("OK", action: viewModel.completeRename)
            Button("Cancel", role: .cancel) { }
            TextField("New name", text: $viewModel.tagName)
        }
        .navigationTitle("Filters")
    }
}

#Preview {
    SidebarView(dataController: DataController.preview)
}
