//
//  Award.swift
//  UltimatePortfolioMe
//
//  Created by 吴晓军 on 2024/10/21.
//

import Foundation

struct Award: Decodable, Identifiable {
    var id: String { name }
    var name: String
    var description: String
    var color: String
    var criterion: String
    var value: Int
    var image: String

    static let allAwards = Bundle.main.decode("Awards.json", as: [Award].self)
    
    //为了使预览更容易，我们将添加一个静态example属性，该属性将在JSON中返回第一个奖励。
    static let example = allAwards[0]
}
