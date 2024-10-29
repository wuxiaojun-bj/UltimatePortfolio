//
//  DetailView.swift
//  UltimatePortfolioMe
//
//  Created by 吴晓军 on 2024/10/9.
//

import SwiftUI

struct DetailView: View {
    @EnvironmentObject var dataController: DataController
    
    var body: some View {
        VStack {
            if let issue = dataController.selectedIssue {
                IssueView(issue: issue)
            } else {
                NoIssueView()
            }
        }
        .navigationTitle("Details")
       // .navigationBarTitleDisplayMode(.inline)
    }
    
}


#Preview {
    DetailView()
        .environmentObject(DataController.preview)
}
