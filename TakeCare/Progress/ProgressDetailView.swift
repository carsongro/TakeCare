//
//  ProgressDetailView.swift
//  TakeCare
//
//  Created by Carson Gross on 10/21/23.
//

import SwiftUI

struct ProgressDetailView: View {
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
            
            ForEach(TaskFilter.allCases, id: \.self) { filter in
                Section(filter.rawValue) {
                    TodoTasksList(list: $list, taskFilter: filter, interactionDisabled: true)
                }
            }
        }
        .refreshable {
            await listsModel.fetchLists()
        }
        .listStyle(.inset)
        .navigationTitle(list.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Menu("Edit", systemImage: "ellipsis.circle") {
                Button("Edit", systemImage: "pencil") {
                    showingEditList = true
                }
                
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
            "Are you sure you want to delete this list",
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
        ProgressDetailView(list: .constant(PreviewData.previewTakeCareList))
    }
}
