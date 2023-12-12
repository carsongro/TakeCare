//
//  ListSearchResults.swift
//  TakeCare
//
//  Created by Carson Gross on 10/9/23.
//

import SwiftUI

struct ListSearchResults: View, @unchecked Sendable {
    @Environment(ListsModel.self) private var listsModel
    
    @State private var contextList: TakeCareList?
    @State private var showingRemoveConfirmation = false
    @State private var showingErrorAlert = false
    
    private var listedLists: [TakeCareList] {
        listsModel.lists
            .filter { $0.matches(listsModel.searchText) }
            .sorted(by: { $0.name.localizedCompare($1.name) == .orderedAscending })
    }
    
    var body: some View {
        ForEach(listedLists, id: \.self) { list in
            NavigationLink(value: list) {
                ListRow(list: list)
                    .contextMenu {
                        Button(
                            "Delete List",
                            systemImage: "trash",
                            role: .destructive
                        ) {
                            withAnimation {
                                contextList = list
                            }
                        }
                    }
                    .confirmationDialog(
                        "Are you sure you want to delete this list?",
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
                                    try await listsModel.deleteList(list)
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
