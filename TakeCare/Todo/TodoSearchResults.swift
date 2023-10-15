//
//  TodoSearchResults.swift
//  TakeCare
//
//  Created by Carson Gross on 10/14/23.
//

import SwiftUI

struct TodoSearchResults: View {
    @Environment(TodoModel.self) private var todoModel
    
    var listedLists: [TakeCareList] {
        todoModel.lists
            .filter { $0.matches(todoModel.searchText) }
            .sorted(by: { $0.name.localizedCompare($1.name) == .orderedAscending })
    }
    
    var body: some View {
        @Bindable var todoModel = todoModel
        ForEach(listedLists) { list in
            NavigationLink {
                TodoDetailView(list: list)
            } label: {
                ListRow(list: list)
            }
        }
        .id(UUID())
        
        
        if listedLists.isEmpty && !todoModel.searchText.isEmpty {
            ContentUnavailableView("No lists found", systemImage: "magnifyingglass")
                .listRowSeparator(.hidden)
                .listRowBackground(Color(.systemBackground))
        }
    }
}

#Preview {
    TodoSearchResults()
        .environment(TodoModel())
}
