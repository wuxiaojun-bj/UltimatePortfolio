//
//  NoIssueView.swift
//  UltimatePortfolioMe
//
//  Created by 吴晓军 on 2024/10/16.
//

import SwiftUI

struct NoIssueView: View {
    @EnvironmentObject var dataController: DataController
    
    var body: some View {
        Text("No Issue Selected")
                 .font(.title)
                 .foregroundStyle(.secondary)

        Button("New Issue", action: dataController.newIssue)
    }
}

#Preview {
    NoIssueView()
        .environmentObject(DataController.preview)
    
}
