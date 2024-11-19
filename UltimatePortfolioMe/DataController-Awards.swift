//
//  DataController-Awards.swift
//  UltimatePortfolioMe
//
//  Created by 吴晓军 on 2024/11/18.
//

import Foundation

extension DataController {
    //评估奖励，解锁应用程序内购买奖励
    func hasEarned(award: Award) -> Bool {
        switch award.criterion {
        case "issues":
            // 如果他们添加了一定数量的问题，则返回true
            let fetchRequest = Issue.fetchRequest()
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value

        case "closed":
            // 如果他们关闭了一定数量的问题，则返回true
            let fetchRequest = Issue.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "completed = true")
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value

        case "tags":
            // 如果他们创建了一定数量的标签，则返回true
            let fetchRequest = Tag.fetchRequest()
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value
            
          //解锁应用程序内购买奖励
        case "unlock":
            return fullVersionUnlocked

        default:
            // 一个未知的奖励标准；这永远不应该被允许
            // fatalError("Unknown award criterion: \(award.criterion)")
            return false
        }
    }
    
}
