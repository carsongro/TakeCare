//
//  ProgressLists.swift
//  TakeCare
//
//  Created by Carson Gross on 10/21/23.
//

import SwiftUI

struct ProgressLists: View {
    @Environment(ProgressModel.self) private var progressModel
    
    var body: some View {
        @Bindable var progressModel = progressModel
        List {
            Section {
                if !progressModel.didFetchLists {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .listRowSeparator(.hidden, edges: .bottom)
                        .padding()
                        .listRowSeparator(.hidden)
                } else if progressModel.lists.isEmpty && progressModel.didFetchLists {
                    ContentUnavailableView(
                        "No Lists In Progress",
                        systemImage: "checklist.unchecked",
                        description: Text("You don't currently have any lists in progress.")
                    )
                    .listRowSeparator(.hidden)
                } else {
                    ProgressSearchResults()
                }
            }
        }
        .searchable(text: $progressModel.searchText)
        .listStyle(.plain)
        .refreshable {
            await progressModel.fetchLists()
        }
    }
}

#Preview {
    NavigationStack {
        ProgressLists()
            .environment(ProgressModel())
            .navigationTitle("In Progress")
    }
}
