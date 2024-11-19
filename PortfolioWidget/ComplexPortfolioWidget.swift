//
//  ComplexPortfolioWidget.swift
//  PortfolioWidgetExtension
//
//  Created by 吴晓军 on 2024/11/19.
//

import WidgetKit
import SwiftUI

//它符合TimelineProvider协议。这决定了如何获取我们小部件的数据。
struct ComplexProvider: TimelineProvider {
    func placeholder(in context: Context) -> ComplexEntry {
        ComplexEntry(date: .now, issues: [.example])
    }

    //获取快照
    func getSnapshot(in context: Context, completion: @escaping (ComplexEntry) -> Void) {
        let entry = ComplexEntry(date: Date.now, issues: loadIssues())
        completion(entry)
    }

    //需要随着时间的推移发回一系列值，以及一些关于iOS在值耗尽时应该做什么的说明——当当前系统日期超过我们发回的数组中的最后一个日期时。
    //获取时间线
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let entry = ComplexEntry(date: Date.now, issues: loadIssues())
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }

    
    //该方法创建一个DataController实例，为顶级问题创建获取请求，然后执行它并返回生成的数据
    func loadIssues() -> [Issue] {
        let dataController = DataController()
        let request = dataController.fetchRequestForTopIssues(count: 7)
        return dataController.results(for: request)
    }
}

//决定了我们小部件的数据是如何存储的。
struct ComplexEntry: TimelineEntry {
    let date: Date
    let issues: [Issue]

}

//决定了我们小部件的数据呈现方式
struct ComplexPortfolioWidgetEntryView: View {
    //这允许我们动态控制我们想要显示的内容。
    @Environment(\.widgetFamily) var widgetFamily
    //来监控大小类别
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    var entry: ComplexProvider.Entry
    
    var issues: ArraySlice<Issue> {
        let issueCount: Int

        switch widgetFamily {
        case .systemSmall:
            issueCount = 1
        case .systemLarge, .systemExtraLarge:
            if dynamicTypeSize < .xxLarge {
                issueCount = 6
            } else {
                issueCount = 5
            }
        default:
            if dynamicTypeSize < .xLarge {
                issueCount = 3
            } else {
                issueCount = 2
            }
        }

        return entry.issues.prefix(issueCount)
    }

    var body: some View {
        VStack(spacing: 10) {
            ForEach(issues) { issue in
                
                Link(destination: issue.objectID.uriRepresentation()) {
                    VStack(alignment: .leading) {
                        Text(issue.issueTitle)
                            .font(.headline)
                            .layoutPriority(1)
                        if issue.issueTags.isEmpty == false {
                            Text(issue.issueTagsList)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}

//决定了我们的小部件应该如何配置。
struct ComplexPortfolioWidget: Widget {
    let kind: String = "ComplexPortfolioWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ComplexProvider()) { entry in
            if #available(iOS 17.0, *) {
                ComplexPortfolioWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                ComplexPortfolioWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Up next…")
        .description("Your most important issues.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
        
    }
}

//决定了如何在Xcode中预览我们的小部件
#Preview(as: .systemSmall) {
    ComplexPortfolioWidget()
} timeline: {
    ComplexEntry(date: .now, issues: [.example])
    ComplexEntry(date: .now, issues: [.example])
}

