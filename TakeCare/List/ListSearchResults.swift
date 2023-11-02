//
//  ListSearchResults.swift
//  TakeCare
//
//  Created by Carson Gross on 10/9/23.
//

import SwiftUI

struct ListSearchResults: View, @unchecked Sendable {
    @Environment(ListsModel.self) private var listsModel
    
    @State private var showingListDetail = false
    @State private var selectedList: TakeCareList?
    
    private var listedLists: [TakeCareList] {
        listsModel.lists
            .filter { $0.matches(listsModel.searchText) }
            .sorted(by: { $0.name.localizedCompare($1.name) == .orderedAscending })
    }
    
    var body: some View {
        ForEach(listedLists) { list in
            Button {
                selectedList = list
            } label: {
                ListRow(list: list)
            }
            .buttonStyle(.plain)
        }
        /// This needs to be here for the list to properly update after modifying individual lists:
        /// https://www.hackingwithswift.com/articles/210/how-to-fix-slow-list-updates-in-swiftui
        .id(UUID())
        .onChange(of: selectedList) { oldValue, newValue in
            if newValue != nil {
                showingListDetail = true
            }
        }
        .sheet(isPresented: $showingListDetail, onDismiss: {
            selectedList = nil
        }) {
            ListDetailView(mode: .edit, list: selectedList)
                .interactiveDismissDisabled()
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
