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
        ForEach(listedLists) { list in
            NavigationLink(value: list) {
                HStack {
                    ListRow(list: list, showingInfoIndicator: false)
                    
                    Spacer(minLength: 0)
                    
                    if !list.isActive {
                        Text("Not Active")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding()
                    }
                }
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
    NavigationStack {
        TodoSearchResults()
            .environment(TodoModel())
            .navigationTitle("Todo")
    }
}
