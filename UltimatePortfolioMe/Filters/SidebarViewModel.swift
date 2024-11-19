//
//  SidebarViewModel.swift
//  UltimatePortfolioMe
//
//  Created by 吴晓军 on 2024/10/31.
//MVVM
//import SwiftUI
import CoreData
import Foundation


extension SidebarView {
    
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {

        var dataController: DataController
        
        private let tagsController: NSFetchedResultsController<Tag>

        @Published var tags = [Tag]()
        //标签的重命名
        //重命名哪个标签
        @Published var tagToRename: Tag?
        //重命名目前是否正在进行中
        @Published var renamingTag = false
        //新标签名称
        @Published var tagName = ""
        
        //将我们所有的标签转换为匹配的过滤器，并添加正确的图标。
        var tagFilters: [Filter] {
            tags.map { tag in
                Filter(id: tag.tagID, name: tag.tagName, icon: "tag", tag: tag)
            }
        }
        
        init(dataController: DataController) {
            self.dataController = dataController

            let request = Tag.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Tag.name, ascending: true)]

            tagsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: dataController.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )

            super.init()

            tagsController.delegate = self

            //执行获取请求并将其分配给tags属性来完成新的初始化器
            do {
                try tagsController.performFetch()
                tags = tagsController.fetchedObjects ?? []
            } catch {
                print("Failed to fetch tags")
            }
        }
        
        //当数据更改时，我们会收到通知。然后，我们可以拉出新更新的对象并将其分配给我们的tags数组，然后该数组将触发其@Published属性包装器来宣布我们UI的更新。
        func controllerDidChangeContent(_ controller: 
            NSFetchedResultsController<NSFetchRequestResult>) {
            if let newTags = controller.fetchedObjects as? [Tag] {
                tags = newTags
            }
        }
        
        func delete(_ offsets: IndexSet) {
            for offset in offsets {
                let item = tags[offset]
                dataController.delete(item)
            }
        }
        
        func delete(_ filter: Filter) {
            guard let tag = filter.tag else { return }
            dataController.delete(tag)
            dataController.save()
        }
        
        //启动和完成重命名过程
        func rename(_ filter: Filter) {
            tagToRename = filter.tag
            tagName = filter.name
            renamingTag = true
        }

        func completeRename() {
            tagToRename?.name = tagName
            dataController.save()
        }
    }
}
