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
    @State private var recipient: User?
    @State private var selectedUserID: String?
    @State private var showUserSheet = false
    
    @State private var showingEditList = false
    @State private var showingErrorAlert = false
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        GeometryReader { proxy in
            List {
                Section {
                    ListDetailHeader(list: $list, width: proxy.size.width)
                }
                .listRowSeparator(.hidden)
                
                Section("Recipient") {
                    if let recipient {
                        Button {
                            selectedUserID = recipient.id
                        } label: {
                            ListRecipientRow(user: recipient)
                        }
                        .buttonStyle(.plain)
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
            .task(id: list) {
                Task {
                    if let recipientID = list.recipientID {
                        let recipient = await AuthModel.shared.fetchUser(id: recipientID)
                        withAnimation {
                            self.recipient = recipient
                        }
                    } else {
                        recipient = nil
                    }
                }
            }
            .refreshable {
                await listsModel.fetchLists()
            }
            .listStyle(.plain)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Menu("Edit", systemImage: "ellipsis.circle") {
                    Button("Edit", systemImage: "pencil") {
                        showingEditList = true
                    }
                    
                    Divider()
                    
                    Button("Delete List", systemImage: "trash", role: .destructive) {
                        showingDeleteConfirmation = true
                    }
                }
                .accessibilityLabel(Text("More"))
            }
            .sheet(isPresented: $showingEditList) {
                ListOwnerDetailView(mode: .edit, list: list)
                    .environment(listsModel)
            }
            .onChange(of: selectedUserID, { oldValue, newValue in
                if newValue != nil {
                    showUserSheet = true
                }
            })
            .sheet(isPresented: $showUserSheet) {
                selectedUserID = nil
            } content: {
                if let selectedUserID {
                    UserProfileView(userID: selectedUserID)
                        .presentationDetents([.medium, .large])
                }
            }
            .confirmationDialog(
                "Are you sure you want to delete this list?",
                isPresented: $showingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Cancel", role: .cancel) { }
                Button("Delete List", role: .destructive) {
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
}

#Preview {
    NavigationStack {
        ListProgressDetailView(list: .constant(PreviewData.previewTakeCareList))
            .environment(ListsModel())
    }
}
