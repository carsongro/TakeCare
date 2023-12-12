//
//  TodoLists.swift
//  TakeCare
//
//  Created by Carson Gross on 10/14/23.
//

import SwiftUI

struct TodoLists: View, @unchecked Sendable {
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
                        description: Text("Any lists shared with you will appear here")
                    )
                    .listRowSeparator(.hidden)
                } else {
                    TodoSearchResults()
                    paginationIndicator
                }
            }
        }
        .searchable(text: $todoModel.searchText)
        .listStyle(.plain)
        .refreshable {
            await todoModel.refreshTodoLists()
        }
    }
    
    @ViewBuilder
    var paginationIndicator: some View {
        LazyVStack {
            Color.clear
                .onAppear {
                    Task {
                        await todoModel.paginate()
                    }
                }
        }
        .listRowSeparator(.hidden, edges: .bottom)
    }
}

#Preview {
    NavigationStack {
        TodoLists()
            .environment(TodoModel())
            .navigationTitle("To Do")
    }
}
