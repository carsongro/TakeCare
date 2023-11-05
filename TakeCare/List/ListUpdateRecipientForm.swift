//
//  ListUpdateRecipientForm.swift
//  TakeCare
//
//  Created by Carson Gross on 10/6/23.
//

import SwiftUI

struct ListUpdateRecipientForm: View, @unchecked Sendable {
    @Environment(ListsModel.self) private var listsModel
    @Environment(\.dismiss) private var dismiss

    @Binding var recipient: User?
    
    @State private var users = [User]()
    @State private var searchText = ""
    @State private var showingSearchAlert = false
    @State private var didSearch = false
    @State private var isSearching = false
    
    var body: some View {
        NavigationStack {
            Form {
                ForEach(users) { user in
                    HStack {
                        ListRecipientRow(user: user)
                        
                        Button("Add", systemImage: "plus.circle.fill") {
                            recipient = user
                            dismiss()
                        }
                    }
                }
                
                if !searchText.isEmpty && users.isEmpty && didSearch {
                    ContentUnavailableView("No users found", systemImage: "person.2")
                        .listRowBackground(Color(.systemGroupedBackground))
                } else if !searchText.isEmpty && isSearching && users.isEmpty {
                    ProgressView()
                        .listRowBackground(Color(.systemGroupedBackground))
                        .frame(maxWidth: .infinity)
                }
            }
            .searchable(text: $searchText, prompt: "Recipient's email address")
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .onSubmit(of: .search, runSearch)
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onChange(of: searchText, { oldValue, newValue in
                if newValue.isEmpty {
                    didSearch = false
                    users.removeAll()
                }
            })
            .alert(
                "There was an error while searching.",
                isPresented: $showingSearchAlert) { }
        }
    }
    
    private func runSearch() {
        Task {
            do {
                isSearching = true
                let users = try await listsModel.searchUser(email: searchText)
                Task { @MainActor in
                    self.users = users
                    didSearch = true
                    isSearching = false
                }
            } catch {
                showingSearchAlert = true
                didSearch = false
                isSearching = false
            }
        }
    }
}

#Preview {
    ListUpdateRecipientForm(
        recipient: .constant(
            User(
                id: "",
                displayName: "",
                email: "",
                photoURL: nil
            )
        )
    )
    .environment(ListsModel())
}
