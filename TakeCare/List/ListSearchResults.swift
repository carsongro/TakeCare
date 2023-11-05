//
//  ListSearchResults.swift
//  TakeCare
//
//  Created by Carson Gross on 10/9/23.
//

import SwiftUI

struct ListSearchResults: View, @unchecked Sendable {
    @Environment(ListsModel.self) private var listsModel
    
    private var listedLists: [TakeCareList] {
        listsModel.lists
            .filter { $0.matches(listsModel.searchText) }
            .sorted(by: { $0.name.localizedCompare($1.name) == .orderedAscending })
    }
    
    var body: some View {
        ForEach(listedLists, id: \.self) { list in
            NavigationLink(value: list) {
                ListRow(list: list)
            }
        }
        
        if listedLists.isEmpty && !listsModel.searchText.isEmpty {
            ContentUnavailableView("No lists found", systemImage: "magnifyingglass")
                .listRowSeparator(.hidden)
                .listRowBackground(Color(.systemBackground))
        }
    }
}

#Preview {
    ListSearchResults()
        .environment(ListsModel())
}
