//
//  DataControlle.swift
//  UltimatePortfolioMe
//
//  Created by 吴晓军 on 2024/10/9.
//

import CoreData

//用户需要能够选择如何对数据进行排序：是按创建日期还是按修改日期。
enum SortType: String {
    case dateCreated = "creationDate"
    case dateModified = "modificationDate"
}

//用户将能够按问题状态进行过滤：打开、关闭或任一者
enum Status {
    case all, open, closed
}

class DataController: ObservableObject {
    //使用CoreData加载和管理本地数据，还负责将该数据与iCloud同步，以便所有用户的设备都能为我们的应用程序共享相同的数据。
    let container: NSPersistentCloudKitContainer
    
    @Published var selectedFilter: Filter? = Filter.all
    
    @Published var selectedIssue: Issue?
    
    @Published var filterText = ""

    //为用户选择的令牌列表提供一些存储
    @Published var filterTokens = [Tag]()
    
    //我们需要跟踪用户是否想先对最新或最旧的数据进行排序，他们想要显示的问题优先级，以及这个新的过滤系统是否已启用或禁用，但这三个都是简单值——优先级为整数，其他两个为布尔值。
    @Published var filterEnabled = false
    //用-1作为特殊优先级，意思是“任何优先级”。
    @Published var filterPriority = -1
    @Published var sortNewestFirst = true
    @Published var filterStatus = Status.all
    @Published var sortType = SortType.dateCreated
    
    
    //创建一个新的属性来存储Task实例来处理我们的保存
    private var saveTask: Task<Void, Error>?

    //搜索令牌
    var suggestedFilterTokens: [Tag] {
        guard filterText.starts(with: "#") else {
            return []
        }

        let trimmedFilterText = String(filterText.dropFirst()).trimmingCharacters(in: .whitespaces)
        let request = Tag.fetchRequest()

        if trimmedFilterText.isEmpty == false {
            request.predicate = NSPredicate(format: "name CONTAINS[c] %@", trimmedFilterText)
        }

        return (try? container.viewContext.fetch(request).sorted()) ?? []
    }
    

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
    
    //解决方案在于NSPredicate是一个类，并且有一个名为NSCompoundPredicate的子类具有更高级的功能。因为它是一个子类，NSCompoundPredicate能够在我们需要的任何地方看起来像NSPredicate，这意味着我们可以根据用户的精确输入构建一组复杂的过滤器，并让核心数据将它们全部应用作为其获取请求的一部分。
    func issuesForSelectedFilter() -> [Issue] {
        
        let filter = selectedFilter ?? .all
        var predicates = [NSPredicate]()
//添加一个谓词，即问题的tags属性包含用户已删除的标签，或使用我们按修改日期过滤的原始谓词。无论哪种方式，这些都需要进入我们作为NSCompoundPredicate附加的数组
        if let tag = filter.tag {
        //谓词tags CONTAINS %@意味着“相关问题的标签关系必须包含特定标签”——在我们的案例中，这就是当前选择的标签。
            let tagPredicate = NSPredicate(format: "tags CONTAINS %@", tag)
            predicates.append(tagPredicate)
        } else {
            let datePredicate = NSPredicate(format: "modificationDate > %@", filter.minModificationDate as NSDate)
            predicates.append(datePredicate)
        }
        
        let trimmedFilterText = filterText.trimmingCharacters(in: .whitespaces)

        if trimmedFilterText.isEmpty == false {
            //CONTAINS[c]谓词格式，该格式进行不区分大小写的比较
            let titlePredicate = NSPredicate(format: "title CONTAINS[c] %@", trimmedFilterText)
            let contentPredicate = NSPredicate(format: "content CONTAINS[c] %@", trimmedFilterText)
            let combinedPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [titlePredicate, contentPredicate])
            predicates.append(combinedPredicate)
        }

        //确保返回的问题包含用户选择的所有标签
        if filterTokens.isEmpty == false {
            for filterToken in filterTokens {
                let tokenPredicate = NSPredicate(format: "tags CONTAINS %@", filterToken)
                predicates.append(tokenPredicate)
            }
        }
        
        //只有当较大的filterEnabled Boolean设置为true时，我们的优先级和状态过滤器才应被激活
        if filterEnabled {
            if filterPriority >= 0 {
                let priorityFilter = NSPredicate(format: "priority = %d", filterPriority)
                predicates.append(priorityFilter)
            }

            if filterStatus != .all {
                let lookForClosed = filterStatus == .closed
                let statusFilter = NSPredicate(format: "completed = %@", NSNumber(value: lookForClosed))
                predicates.append(statusFilter)
            }
        }

        
        let request = Issue.fetchRequest()
        
        //当我们创建完成的谓词时，我们使用NSCompoundPredicate，特别是其andPredicateWithSubpredicates初始化器。这需要我们的谓词数组，并确保所有谓词都必须为获取请求中的每个问题匹配。
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        //要排序的属性，以及它是升序还是降序。使用其rawValue属性将sortType值转换为底层属性名称.
        request.sortDescriptors = [NSSortDescriptor(key: sortType.rawValue, ascending: sortNewestFirst)]


        let allIssues = (try? container.viewContext.fetch(request)) ?? []
        
        return allIssues.sorted()
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
    
    //在延迟后保存我们的更改
    func queueSave() {
        saveTask?.cancel()
        //需要在主要演员身上运行身体的任务
        saveTask = Task { @MainActor in
            //延迟3秒钟
            try await Task.sleep(for: .seconds(3))
            save()
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
    
    //接受一个问题，并返回它缺少的所有标签的数组
    func missingTags(from issue: Issue) -> [Tag] {
        //内部加载所有可能存在的标签
        let request = Tag.fetchRequest()
        let allTags = (try? container.viewContext.fetch(request)) ?? []
        let allTagsSet = Set(allTags)
        
        //计算哪些标签当前没有分配给该问题,对称差异.
        let difference = allTagsSet.symmetricDifference(issue.issueTags)
        
       //对这些标签进行排序，然后发回
        return difference.sorted()
    }
    
  



}

