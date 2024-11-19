//
//  IssueView.swift
//  UltimatePortfolioMe
//
//  Created by 吴晓军 on 2024/10/16.
//

import SwiftUI

struct IssueView: View {
    @EnvironmentObject var dataController: DataController
    //显示应用程序的设置是逻辑，最好从我们的视图中排除。因此，添加此新属性以访问打开的URL
     @Environment(\.openURL) var openURL

    @ObservedObject var issue: Issue
    //通知
    @State private var showingNotificationsError = false

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading) {
                    TextField("Title", text: $issue.issueTitle, prompt: Text("Enter the issue title here"))
                        .font(.title)
                    
                    Text("**Modified:** \(issue.issueModificationDate.formatted(date: .long, time: .shortened))")
                        .foregroundStyle(.secondary)
                    
                    Text("**Status:** \(issue.issueStatus)")
                        .foregroundStyle(.secondary)
                }
                
                Picker("Priority", selection: $issue.priority) {
                    Text("Low").tag(Int16(0))
                    Text("Medium").tag(Int16(1))
                    Text("High").tag(Int16(2))
                }
                
                TagsMenuView(issue: issue)
            }
            
            Section {
                VStack(alignment: .leading) {
                    Text("Basic Information")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    
                    TextField(
                        "Description",
                        text: $issue.issueContent,
                        prompt: Text("Enter the issue description here"),
                        axis: .vertical
                    )
                }
            }
            
            Section("Reminders") {
                Toggle("Show reminders", isOn: $issue.reminderEnabled.animation())

                if issue.reminderEnabled {
                   DatePicker(
                       "Reminder time",
                       selection: $issue.issueReminderTime,
                       displayedComponents: .hourAndMinute
                   )
                }
            }
            
        }
        .disabled(issue.isDeleted)
        //发现更新后保存
        .onReceive(issue.objectWillChange) { _ in
            dataController.queueSave()
        }
        .onSubmit(dataController.save)
        .toolbar {
            IssueViewToolbar(issue: issue)
        }
        //显示错误消息，并让用户有机会调整他们的设置。
        .alert("Oops!", isPresented: $showingNotificationsError) {
            Button("Check Settings", action: showAppSettings)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("There was a problem setting your notification. Please check you have notifications enabled.")
        }
        .onChange(of: issue.reminderEnabled) { _ in
            updateReminder()
        }
        .onChange(of: issue.reminderTime) { _ in
            updateReminder()
        }




//如果他们选择一个问题，然后调出侧边栏并删除所选问题，我们不应该让他们尝试进行任何进一步的更改。
//onReceive()修饰符自动排队保存，onSubmit()修饰符立即运行保存
    }
    
    func showAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openNotificationSettingsURLString) else {
            return
        }

        openURL(settingsURL)
    }
    
    func updateReminder() {
       //这总是会删除任何存在的通知，以避免单个问题的多次通知。然后，如果需要，我们会重新添加通知。
        dataController.removeReminders(for: issue)

        Task { @MainActor in
            if issue.reminderEnabled {
                let success = await dataController.addReminder(for: issue)

                if success == false {
                    issue.reminderEnabled = false
                    showingNotificationsError = true
                }
            }
        }
    }


}

#Preview {
    IssueView(issue: .example)
        .environmentObject(DataController.preview)
}
