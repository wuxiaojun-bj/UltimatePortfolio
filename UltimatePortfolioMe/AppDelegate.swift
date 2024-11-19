//
//  AppDelegate.swift
//  UltimatePortfolioMe
//
//  Created by 吴晓军 on 2024/11/15.
//将该AppDelegate类用于它目前无法处理的任何UIKit功能

import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let sceneConfiguration = UISceneConfiguration(name: "Default", sessionRole: connectingSceneSession.role)
        sceneConfiguration.delegateClass = SceneDelegate.self
        return sceneConfiguration
    }
    
}


