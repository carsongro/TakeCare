//
//  TodoSearchResults.swift
//  TakeCare
//
//  Created by Carson Gross on 10/14/23.
//

import SwiftUI

struct TodoSearchResults: View {
    @Environment(TodoModel.self) private var todoModel

    @State private var contextList: TakeCareList?
    @State private var showingRemoveConfirmation = false
    @State private var showingErrorAlert = false
    
    var listedLists: [TakeCareList] {
        todoModel.lists
            .filter { $0.matches(todoModel.searchText) }
            .sorted(by: { $0.name.localizedCompare($1.name) == .orderedAscending })
    }
    
    var body: some View {
        ForEach(listedLists, id: \.self) { list in
            NavigationLink(value: list) {
                ListRow(list: list)
                    .contextMenu {
                        Button(
                            "Delete from To Do",
                            systemImage: "trash",
                            role: .destructive
                        ) {
                            contextList = list
                        }
                    }
                    .confirmationDialog(
                        "Are you sure you want to delete this list from your To Do?",
                        isPresented: $showingRemoveConfirmation,
                        titleVisibility: .visible,
                        presenting: contextList
                    ) { list in
                        Button("Cancel", role: .cancel) {
                            contextList = nil
                        }
                        Button("Delete List", role: .destructive) {
                            Task {
                                do {
                                    try await todoModel.removeTodoList(list: list)
                                    contextList = nil
                                } catch {
                                    showingErrorAlert = true
                                    contextList = nil
                                }
                            }
                        }
                    }
            }
        }
        .onChange(of: contextList, { oldValue, newValue in
            if newValue != nil {
                showingRemoveConfirmation = true
            }
        })
        .alert("An error occured", isPresented: $showingErrorAlert) { }
        
        if listedLists.isEmpty && !todoModel.searchText.isEmpty {
            ContentUnavailableView("No lists found", systemImage: "magnifyingglass")
                .listRowSeparator(.hidden)
                .listRowBackground(Color(.systemBackground))
        }
    }
}

#Preview {
    NavigationStack {
        TodoSearchResults()
            .environment(TodoModel())
            .navigationTitle("To Do")
    }
}
