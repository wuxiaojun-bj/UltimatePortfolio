//
//  DataControlle.swift
//  UltimatePortfolioMe
//
//  Created by 吴晓军 on 2024/10/9.
//

import CoreData


class DataController: ObservableObject {
    //使用CoreData加载和管理本地数据，还负责将该数据与iCloud同步，以便所有用户的设备都能为我们的应用程序共享相同的数据。
    let container: NSPersistentCloudKitContainer
    
    @Published var selectedFilter: Filter? = Filter.all

    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        dataController.createSampleData()
        return dataController
    }()

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Main")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(filePath: "/dev/null")
        }

        //自动将发生在底层持久存储的任何更改应用于我们的视图上下文，以便两者保持同步，
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        //告诉Core Data如何处理合并本地和远程数据
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        
        //告诉Core Data，我们希望在商店更改时收到通知
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        //告诉系统在发生更改时调用我们的newremoteStoreChanged remoteStoreChanged()方法。
        NotificationCenter.default.addObserver(forName: .NSPersistentStoreRemoteChange, object: container.persistentStoreCoordinator, queue: .main, using: remoteStoreChanged)

        container.loadPersistentStores { storeDescription, error in
            if let error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }
        }
    }
//方法将创建一堆问题和标签。这仅对测试和预览有用
    func createSampleData() {
        let viewContext = container.viewContext

        for i in 1...5 {
            let tag = Tag(context: viewContext)
            tag.id = UUID()
            tag.name = "Tag \(i)"

            for j in 1...10 {
                let issue = Issue(context: viewContext)
                issue.title = "Issue \(i)-\(j)"
                issue.content = "Description goes here"
                issue.creationDate = .now
                issue.completed = Bool.random()
                issue.priority = Int16.random(in: 0...2)
                tag.addToIssues(issue)
            }
        }

        try? viewContext.save()
    }

    func save() {
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
        }
    }

    //所有核心数据类（包括Xcode为我们生成Issue和Tag类）都继承自名为NSManagedObject的父类。
    func delete(_ object: NSManagedObject) {
        objectWillChange.send()
        container.viewContext.delete(object)
        save()
    }

    //我们特别要求批量删除请求发回所有被删除的对象ID。
   // 该对象ID数组进入带有密钥NSDeletedObjectsKey的字典，如果无法读取，则使用默认的空数组。
   // 该字典进入mergeChanges()方法，这是用我们刚刚对持久存储所做的更改来更新我们的视图上下文。
   //我已将该方法标记为私有，因为我们将只在一个地方使用它：我们的测试方法删除我们存储的所有问题和标签。
    private func delete(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs

        if let delete = try? container.viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult {
            let changes = [NSDeletedObjectsKey: delete.result as? [NSManagedObjectID] ?? []]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [container.viewContext])
        }
    }

    func deleteAll() {
        let request1: NSFetchRequest<NSFetchRequestResult> = Tag.fetchRequest()
        delete(request1)

        let request2: NSFetchRequest<NSFetchRequestResult> = Issue.fetchRequest()
        delete(request2)

        save()
    }
    
    func remoteStoreChanged(_ notification: Notification) {
        objectWillChange.send()
    }

}

