//
//  ProgressSearchResults.swift
//  TakeCare
//
//  Created by Carson Gross on 10/21/23.
//

import SwiftUI

struct ProgressSearchResults: View {
    @Environment(ProgressModel.self) private var progressModel
    
    var listedLists: [TakeCareList] {
        progressModel.lists
            .filter { $0.matches(progressModel.searchText) }
            .sorted(by: { $0.name.localizedCompare($1.name) == .orderedAscending })
    }
    
    var body: some View {
        ForEach(listedLists) { list in
            NavigationLink(value: list) {
                ListRow(list: list, showingInfoIndicator: false)
            }
        }
        .id(UUID())
        
        if listedLists.isEmpty && !progressModel.searchText.isEmpty {
            ContentUnavailableView("No lists in progress found", systemImage: "magnifyingglass")
                .listRowSeparator(.hidden)
                .listRowBackground(Color(.systemBackground))
        }
    }
}

#Preview {
    ProgressSearchResults()
}
