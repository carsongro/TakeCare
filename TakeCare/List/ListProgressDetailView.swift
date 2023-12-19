//
//  ListProgressDetailView.swift
//  TakeCare
//
//  Created by Carson Gross on 10/21/23.
//

import SwiftUI

struct ListProgressDetailView: View, @unchecked Sendable {
    @Environment(ListsModel.self) private var listsModel
    @Environment(\.dismiss) private var dismiss
    
    @Binding var list: TakeCareList
    @State private var recipient: User?
    @State private var listOwner: User?
    @State private var selectedUser: User?
    
    @State private var showingEditList = false
    @State private var showingErrorAlert = false
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        GeometryReader { proxy in
            Group {
                if finishedFetchingData {
                    List {
                        Section {
                            ListDetailHeader(
                                list: $list,
                                listOwner: listOwner,
                                width: proxy.size.width
                            )
                        }
                        .listRowSeparator(.hidden)
                        
                        Section("Recipient") {
                            Group {
                                if let recipient {
                                    Button {
                                        selectedUser = recipient
                                    } label: {
                                        ListRecipientRow(user: recipient)
                                    }
                                    .buttonStyle(.plain)
                                } else {
                                    if list.recipientID == nil {
                                        Button(
                                            "Add Recipient",
                                            systemImage: "plus"
                                        ) {
                                            showingEditList = true
                                        }
                                    }
                                }
                            }
                            .padding(.bottom)
                        }
                        .listRowSeparator(.hidden)
                        
                        Section {
                            ProgressView(
                                value: CGFloat(list.dailyTasksCompletedCount),
                                total: CGFloat(list.dailyTasksCount)
                            ) {
                                Text("Daily Tasks Progress")
                            } currentValueLabel: {
                                Text((list.dailyTasksCompletedCount == list.dailyTasksCount ? "All" : "\(list.dailyTasksCompletedCount) / \(list.dailyTasksCount)") + " daily tasks completed")
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
                } else {
                    // If this isn't head the task modifier never gets called
                    Color.clear
                }
            }
            .task(id: list) {
                Task {
                    if let recipientID = list.recipientID {
                        async let recipient = AuthModel.shared.fetchUser(id: recipientID)
                        async let listOwner = AuthModel.shared.fetchUser(id: list.ownerID)
                        let associatedUsers = (await listOwner, await recipient)
                        
                        withAnimation {
                            self.listOwner = associatedUsers.0
                            self.recipient = associatedUsers.1
                        }
                    } else {
                        withAnimation {
                            recipient = nil
                        }
                    }
                }
            }
            .refreshable {
                await listsModel.refreshLists(updateTasksCompletion: true)
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
            }
            .sheet(isPresented: $showingEditList) {
                ListOwnerDetailView(mode: .edit, list: list)
                    .environment(listsModel)
            }
            .sheet(item: $selectedUser) {
                selectedUser = nil
            } content: { selectedUser in
                ProfileView(user: selectedUser)
                    .presentationDetents([.medium, .large])
            }
            .alert(
                "There was an error deleting the list",
                isPresented: $showingErrorAlert
            ) { }
        }
    }
    
    private var finishedFetchingData: Bool {
        (listOwner != nil && (list.recipientID != nil && recipient != nil) || list.recipientID == nil)
    }
}

#Preview {
    NavigationStack {
        ListProgressDetailView(list: .constant(PreviewData.previewTakeCareList))
            .environment(ListsModel())
    }
}
