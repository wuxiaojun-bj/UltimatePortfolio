//
//  DataController-Notifications.swift
//  UltimatePortfolioMe
//
//  Created by 吴晓军 on 2024/11/5.
//

import Foundation
import UserNotifications

extension DataController {
    
    func addReminder(for issue: Issue) async -> Bool {
        do {
            let center = UNUserNotificationCenter.current()
            let settings = await center.notificationSettings()

            switch settings.authorizationStatus {
                //当用户没有授予或拒绝通知权限时，它将接管
            case .notDetermined:
                let success = try await requestNotifications()

                if success {
                    try await placeReminders(for: issue)
                } else {
                    return false
                }
            //如果我们之前被授权显示通知，我们会立即调用placeReminders()
            case .authorized:
                try await placeReminders(for: issue)
            //如果状态不是未确定或授权的，我们认为它是失败的，并立即发回false
            default:
                return false
            }

            return true
        } catch {
            return false
        }
        
    }

    //每个托管对象都有一个objectID属性，可以转换为专门为归档设计的URL。我们将获取该问题的唯一ID，然后要求通知中心删除任何待处理的请求——已提交但尚未交付的请求。
    func removeReminders(for issue: Issue) {
        let center = UNUserNotificationCenter.current()
            let id = issue.objectID.uriRepresentation().absoluteString
            center.removePendingNotificationRequests(withIdentifiers: [id])

        
    }

    //该方法被标记为私有，因此我们不会意外地试图从其他地方调用它
    private func requestNotifications() async throws -> Bool {
        //UNUserNotificationCenter是UserNotifications框架的枢纽——它是负责读取和写入通知的部分。
        let center = UNUserNotificationCenter.current()
            return try await center.requestAuthorization(options: [.alert, .sound])
        
    }

    private func placeReminders(for issue: Issue) async throws {
        //决定我们要显示的内容
        let content = UNMutableNotificationContent()
        content.title = issue.issueTitle
        content.sound = UNNotificationSound.default
        if let issueContent = issue.content {
            content.subtitle = issueContent
        }
        
        //告诉iOS何时应该显示通知
       // let components = Calendar.current.dateComponents([.hour, .minute], from: issue.issueReminderTime)
      //  let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        //出于调试目的，告诉iOS在整整五秒内显示警报——然后我可以按Cmd+L锁定屏幕，并快速看到测试通知，而不是等待日历触发器触发。
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        //将这两条信息与唯一标识符一起包装
        let id = issue.objectID.uriRepresentation().absoluteString
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        //将其发送到iOS，以便在仔细处理响应时显示。
        return try await UNUserNotificationCenter.current().add(request)
    }
}
