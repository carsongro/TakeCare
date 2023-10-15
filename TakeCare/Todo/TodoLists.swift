//
//  TodoLists.swift
//  TakeCare
//
//  Created by Carson Gross on 10/14/23.
//

import SwiftUI

struct TodoLists: View {
    @Environment(TodoModel.self) private var todoModel
    
    var body: some View {
        List {
            Section {
                if !todoModel.didFetchLists {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .listRowSeparator(.hidden, edges: .bottom)
                        .padding()
                } else if todoModel.lists.isEmpty && todoModel.didFetchLists {
                    ContentUnavailableView(
                        "You have no todo lists",
                        systemImage: "list.bullet"
                    )
                    .listRowSeparator(.hidden)
                } else {
                    TodoSearchResults()
                }
            }
            .listRowBackground(Color(.systemBackground))
        }
        .scrollContentBackground(.hidden)
        .listStyle(.grouped)
        .refreshable {
            await todoModel.fetchLists()
        }
    }
}

#Preview {
    NavigationStack {
        TodoLists()
            .environment(TodoModel())
            .navigationTitle("Todo")
            #if os(macOS)
            .frame(width: 700, height: 300, alignment: .center)
            #endif
    }
}
