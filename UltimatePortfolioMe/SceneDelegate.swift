//
//  SceneDelegate.swift
//  UltimatePortfolioMe
//
//  Created by 吴晓军 on 2024/11/15.
//

import SwiftUI


class SceneDelegate: NSObject, UIWindowSceneDelegate {
    
    func windowScene(
        _ windowScene: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        guard let url = URL(string: shortcutItem.type) else {
            completionHandler(false)
            return
        }

        windowScene.open(url, options: nil, completionHandler: completionHandler)
    }
    //处理冷启动
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        if let shortcutItem = connectionOptions.shortcutItem {
            if let url = URL(string: shortcutItem.type) {
                scene.open(url, options: nil)
            }
        }
    }
    
}

