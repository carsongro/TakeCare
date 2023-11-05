//
//  ListProgressDetailView.swift
//  TakeCare
//
//  Created by Carson Gross on 10/21/23.
//

import SwiftUI

struct ListProgressDetailView: View {
    @Environment(ListsModel.self) private var listsModel
    @Environment(\.dismiss) private var dismiss
    
    @Binding var list: TakeCareList
    
    @State private var showingEditList = false
    @State private var showingErrorAlert = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        List {
            Section {
                ListDetailHeader(list: $list)
            }
            .listRowSeparator(.hidden)
            
            Section("Recipient") {
                if let recipient = list.recipient {
                    ListRecipientRow(user: recipient)
                }
            }
            .listRowSeparator(.hidden)
            
            ForEach(TaskFilter.allCases, id: \.self) { filter in
                TodoTasksList(list: $list, taskFilter: filter, interactionDisabled: true)
            }
            
            Section {
                Color.clear
            }
            .padding(.bottom)
            .listRowSeparator(.hidden)
        }
        .refreshable {
            await listsModel.fetchLists()
        }
        .listStyle(.plain)
        .navigationTitle(list.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Menu("Edit", systemImage: "ellipsis.circle") {
                Button("Edit", systemImage: "pencil") {
                    showingEditList = true
                }
                
                Divider()
                
                Button("Delete List", systemImage: "trash", role: .destructive) {
                    showingDeleteAlert = true
                }
            }
        }
        .sheet(isPresented: $showingEditList) {
            ListDetailView(mode: .edit, list: list)
                .environment(listsModel)
        }
        .alert(
            "Are you sure you want to delete this list?",
            isPresented: $showingDeleteAlert
        ) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    do {
                        dismiss()
                        try await listsModel.deleteList(list)
                    } catch {
                        showingErrorAlert = true
                    }
                }
            }
        }
        .alert(
            "There was an error deleting the list",
            isPresented: $showingErrorAlert
        ) { }
    }
}

#Preview {
    NavigationStack {
        ListProgressDetailView(list: .constant(PreviewData.previewTakeCareList))
            .environment(ListsModel())
    }
}