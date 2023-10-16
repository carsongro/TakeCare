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
        @Bindable var todoModel = todoModel
        List {
            Section {
                if !todoModel.didFetchLists {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .listRowSeparator(.hidden, edges: .bottom)
                        .padding()
                        .listRowSeparator(.hidden)
                } else if todoModel.lists.isEmpty && todoModel.didFetchLists {
                    ContentUnavailableView(
                        "No Todo's",
                        systemImage: "list.bullet",
                        description: Text("You are not currently taking care of any todo lists.")
                    )
                    .listRowSeparator(.hidden)
                } else {
                    TodoSearchResults()
                }
            }
        }
        .searchable(text: $todoModel.searchText)
        .listStyle(.plain)
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
    }
}
