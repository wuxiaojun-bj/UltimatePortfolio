//
//  SimplePortfolioWidget.swift
//  SimplePortfolioWidget
//
//  Created by 吴晓军 on 2024/11/18.
//

import WidgetKit
import SwiftUI

//它符合TimelineProvider协议。这决定了如何获取我们小部件的数据。
struct SimpleProvider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: .now, issues: [.example])
    }

    //获取快照
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date.now, issues: loadIssues())
        completion(entry)
    }

    //需要随着时间的推移发回一系列值，以及一些关于iOS在值耗尽时应该做什么的说明——当当前系统日期超过我们发回的数组中的最后一个日期时。
    //获取时间线
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let entry = SimpleEntry(date: Date.now, issues: loadIssues())
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }

    
    //该方法创建一个DataController实例，为顶级问题创建获取请求，然后执行它并返回生成的数据
    func loadIssues() -> [Issue] {
        let dataController = DataController()
        let request = dataController.fetchRequestForTopIssues(count: 1)
        return dataController.results(for: request)
    }
}

//决定了我们小部件的数据是如何存储的。
struct SimpleEntry: TimelineEntry {
    let date: Date
    let issues: [Issue]

}

//决定了我们小部件的数据呈现方式
struct SimplePortfolioWidgetEntryView: View {
    var entry: SimpleProvider.Entry

    var body: some View {
        VStack {
            Text("Up next…")
                .font(.title)

            if let issue = entry.issues.first {
                Text(issue.issueTitle)
            } else {
                Text("Nothing!")
            }
        }
    }
}

//决定了我们的小部件应该如何配置。
struct SimplePortfolioWidget: Widget {
    let kind: String = "SimplePortfolioWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SimpleProvider()) { entry in
            if #available(iOS 17.0, *) {
                SimplePortfolioWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                SimplePortfolioWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Up next…")
        .description("Your #1 top-priority issue.")
        .supportedFamilies([.systemSmall])
    }
}

//决定了如何在Xcode中预览我们的小部件
#Preview(as: .systemSmall) {
    SimplePortfolioWidget()
} timeline: {
    SimpleEntry(date: .now, issues: [.example])
    SimpleEntry(date: .now, issues: [.example])
}

