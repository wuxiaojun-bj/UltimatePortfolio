//
//  DataController-StoreKit.swift
//  UltimatePortfolioMe
//
//  Created by 吴晓军 on 2024/11/12.
//

import Foundation
import StoreKit

extension DataController {
    /// 我们高级解锁的产品ID.
    static let unlockPremiumProductID = "com.bjwuxiaojun.UltimatePortfolioMe.premiumUnlock"

    /// 加载并保存我们的高级解锁是否已购买
    var fullVersionUnlocked: Bool {
        get {
            defaults.bool(forKey: "fullVersionUnlocked")
        }
        
        set {
            defaults.set(newValue, forKey: "fullVersionUnlocked")
        }
    }
    
    //监控交易
    func monitorTransactions() async {
        // 检查之前的购买。
        //第一个循环查看用户的当前权利并处理它们。这意味着，如果他们使用同一Apple ID在另一台设备上购买了该应用程序，他们也会在这里自动解锁您
        for await entitlement in Transaction.currentEntitlements {
            if case let .verified(transaction) = entitlement {
                await finalize(transaction)
            }
        }

        // 留意未来的交易.这可能会在应用程序运行时再次发生，但可能不会。
        for await update in Transaction.updates {
            if let transaction = try? update.payloadValue {
                await finalize(transaction)
            }
        }
    }
    
    //负责触发整个购买流程，StoreKitProduct结构有一个内置的purchase()方法，可以启动整个过程，但我们确实需要捕捉其结果并将其传递到finalize()方法中，以处理提供内容。
   // 如果购买产品成功，请将交易读出并发送到finalize()方法以处理解锁。
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()

        if case let .success(validation) = result {
            try await finalize(validation.payloadValue)
        }
    }

    
    //编写一个知道如何处理StoreKit事务的方法，解锁。
    @MainActor
    func finalize(_ transaction: Transaction) async {
        //如果我们正在处理的交易是关于我们的解锁ID，那么我们首先宣布我们将对我们的fullVersionUnlocked属性进行更改。
        if transaction.productID == Self.unlockPremiumProductID {
            objectWillChange.send()
            //然后我们更新fullVersionUnlocked。如果我们正在处理退款，那么revocationDate将包含一个有效日期，因此，如果为零，这意味着我们可以解锁升级。
            fullVersionUnlocked = transaction.revocationDate == nil
            //然后，我们可以安全地调用交易上的finish()，因为我们已授予对内容的访问权限。
            await transaction.finish()
        }
    }
    
    ////加载应用内购买产品
    @MainActor
    func loadProducts() async throws {
        // 不要多次加载产品
        guard products.isEmpty else { return }

       // try await Task.sleep(for: .seconds(10.2))
    //测试用0.2
        try await Task.sleep(for: .seconds(5.2))
        products = try await Product.products(for: [Self.unlockPremiumProductID])
    }


}
