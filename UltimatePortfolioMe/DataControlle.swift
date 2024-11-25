//
//  DataControlle.swift
//  UltimatePortfolioMe
//
//  Created by 吴晓军 on 2024/10/9.
//与Spotlight集成

import CoreData
//import UIKit
import StoreKit
import SwiftUI
import WidgetKit

//用户需要能够选择如何对数据进行排序：是按创建日期还是按修改日期。
enum SortType: String {
    case dateCreated = "creationDate"
    case dateModified = "modificationDate"
}

//用户将能够按问题状态进行过滤：打开、关闭或任一者
enum Status {
    case all, open, closed
}


/// 负责管理我们核心数据堆栈的环境单机，包括处理保存
/// 计算获取请求、跟踪奖励和处理样本数据。
class DataController: ObservableObject {
    //使用CoreData加载和管理本地数据，还负责将该数据与iCloud同步，以便所有用户的设备都能为我们的应用程序共享相同的数据。
    
    /// 唯一的CloudKit容器用于存储我们所有的数据
    let container: NSPersistentCloudKitContainer
    
    //首先，我们需要一个属性来存储一个活跃的Core Spotlight索引器。
    var spotlightDelegate: NSCoreDataCoreSpotlightDelegate?
    
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
    /// 我们为商店加载的StoreKit产品。扩展中不允许存储属性
    @Published var products = [Product]()

    
    
    //创建一个新的属性来存储Task实例来处理我们的保存
    private var saveTask: Task<Void, Error>?
    
    //我们需要创建并存储一个任务，在我们的应用程序启动后立即调用monitorTransactions()。这需要存储，以便只要整个应用程序都在运行，任务就会继续运行。
    private var storeTask: Task<Void, Never>?
    
    // 我们正在保存用户数据的UserDefaults套件.
    let defaults: UserDefaults


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
    
    //我们可以告诉它通过将其设为单人来加载我们的托管对象模型（即Main.momd文件）精确一次。
    static let model: NSManagedObjectModel = {
        guard let url = Bundle.main.url(forResource: "Main", withExtension: "momd") else {
            fatalError("Failed to locate model file.")
        }

        guard let managedObjectModel = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load model file.")
        }

        return managedObjectModel
    }()
    

    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        dataController.createSampleData()
        return dataController
    }()
    
    /// 初始化数据控制器，要么在内存中（用于测试和预览等临时用途）
    /// 或永久存储（用于常规应用程序运行。）
    ///
    /// 默认为永久存储。
    /// - Parameter inMemory: 是否将此数据存储在临时存储器中
    ///参数默认值：应存储用户数据的UserDefaults套件
    init(inMemory: Bool = false, defaults: UserDefaults = .standard) {
        self.defaults = defaults

        
        //这意味着实体将只加载一次，跨测试和真实代码，这将解决崩溃问题.
        container = NSPersistentCloudKitContainer(name: "Main", managedObjectModel: Self.model)
        
        //创建并存储一个任务，在我们的应用程序启动后立即调用monitorTransactions()。应用内购买。
        storeTask = Task {
            await monitorTransactions()
        }

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else {
            let groupID = "group.com.bjwuxiaojun.upa"

            if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID) {
                container.persistentStoreDescriptions.first?.url = url.appending(path: "Main.sqlite")
            }
        }

        //自动将发生在底层持久存储的任何更改应用于我们的视图上下文，以便两者保持同步，
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        //告诉Core Data如何处理合并本地和远程数据
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        
        //告诉Core Data，我们希望在商店更改时收到通知
        container.persistentStoreDescriptions.first?.setOption(
            true as NSNumber,
            forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey
        )
        
        //启用历史跟踪
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)

        //告诉系统在发生更改时调用我们的newremoteStoreChanged remoteStoreChanged()方法。
        NotificationCenter.default.addObserver(
            forName: .NSPersistentStoreRemoteChange,
            object: container.persistentStoreCoordinator,
            queue: .main,
            using: remoteStoreChanged
        )
        
        container.loadPersistentStores { [weak self] _, error in
            if let error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }
          //其次，在我们的初始化器中，我们需要配置持久历史跟踪。一旦我们的持久存储加载完毕，我们就可以这样做
            if let description = self?.container.persistentStoreDescriptions.first {
                description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
         //第三，我们需要创建索引委托，将其附加到我们的存储描述和核心数据容器的持久存储协调员中。
                if let coordinator = self?.container.persistentStoreCoordinator {
                    self?.spotlightDelegate = NSCoreDataCoreSpotlightDelegate(
                        forStoreWith: description,
                        coordinator: coordinator
                    )
           // 最后，我们需要告诉索引器开始工作
                    self?.spotlightDelegate?.startSpotlightIndexing()
                }
            }

            #if DEBUG
            if CommandLine.arguments.contains("enable-testing") {
                self?.deleteAll()
                UIView.setAnimationsEnabled(false)
            }
            #endif
        }    }
    
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
            let combinedPredicate = NSCompoundPredicate(
                orPredicateWithSubpredicates: [titlePredicate, contentPredicate]
            )
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
        
        return allIssues
    }

//方法将创建一堆问题和标签。这仅对测试和预览有用
    func createSampleData() {
        let viewContext = container.viewContext

        for tagCounter in 1...5 {
            let tag = Tag(context: viewContext)
            tag.id = UUID()
            tag.name = "Tag \(tagCounter)"

            for issueCounter in 1...10 {
                let issue = Issue(context: viewContext)
                issue.title = "Issue \(tagCounter)-\(issueCounter)"
                issue.content = "Description goes here"
                issue.creationDate = .now
                issue.completed = Bool.random()
                issue.priority = Int16.random(in: 0...2)
                tag.addToIssues(issue)
            }
        }

        try? viewContext.save()
    }
    
    /// 如果有变化，则保存我们的核心数据上下文。这默默地忽略了
    /// 保存引起的任何错误，但这应该没问题，因为我们所有的属性都是可选的。
    func save() {
        saveTask?.cancel()

        if container.viewContext.hasChanges {
            try? container.viewContext.save()
            
            //每当数据发生变化时，它应该自动刷新任何小部件。这将确保我们的主应用程序和小部件在用户数据变化时保持同步。
            WidgetCenter.shared.reloadAllTimelines()
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
        //在执行批量删除时，我们需要确保我们读回结果
        //然后将该结果的所有更改合并回我们的实时视图上下文中
        //以便两者保持同步。
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
    
    //创建Issue
    func newIssue() {
        
        let issue = Issue(context: container.viewContext)
      //  issue.title = "New issue"
        issue.title = String(localized: "New issue", comment: "Create a new issue")
        issue.creationDate = .now
        issue.priority = 1

        if let tag = selectedFilter?.tag {
            issue.addToTags(tag)
        }

        save()
        //将selectedIssue设置为我们刚刚创建的问题，这将立即触发它被选中——iOS将立即触发导航，以便用户开始编辑。
        selectedIssue = issue
    }

    //创建Tag,用户可以免费创建最多三个标签——之后将提示他们付款.
    func newTag() -> Bool {
        
        var shouldCreate = fullVersionUnlocked
        if shouldCreate == false {
            // 检查我们目前有多少个标签
            shouldCreate = count(for: Tag.fetchRequest()) < 3
        }
        
        guard shouldCreate else {
            return false
        }

        
        let tag = Tag(context: container.viewContext)
        tag.id = UUID()
        tag.name = String(localized: "New tag", comment: "Create a new tag")
       // tag.name = "New tag"
        save()
        return true
    }

    //计数获取请求
    func count<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
        (try? container.viewContext.count(for: fetchRequest)) ?? 0
    }
    
    

    //Spotlight中点击问题搜索结果,启动一个问题
    func issue(with uniqueIdentifier: String) -> Issue? {
        guard let url = URL(string: uniqueIdentifier) else {
            return nil
        }

        guard let id = container.persistentStoreCoordinator.managedObjectID(forURIRepresentation: url) else {
            return nil
        }

        return try? container.viewContext.existingObject(with: id) as? Issue
    }

    //它将创建一个获取请求，返回一些最高优先级的问题。获取一个未完成且优先级最高的Issue对象
    func fetchRequestForTopIssues(count: Int) -> NSFetchRequest<Issue> {
        let request = Issue.fetchRequest()
        request.predicate = NSPredicate(format: "completed = false")

        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Issue.priority, ascending: false)
        ]

        request.fetchLimit = count
        return request
    }

    //如果container或viewContext消失或被重命名，我们只需要更改一个方法，而不是所有调用站点。
    func results<T: NSManagedObject>(for fetchRequest: NSFetchRequest<T>) -> [T] {
        return (try? container.viewContext.fetch(fetchRequest)) ?? []
    }


}

