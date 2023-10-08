//
//  ListAddRecipientForm.swift
//  TakeCare
//
//  Created by Carson Gross on 10/6/23.
//

import SwiftUI

struct ListAddRecipientForm: View, @unchecked Sendable {
    @Environment(ListsModel.self) private var listsModel
    @Environment(\.dismiss) private var dismiss

    @Binding var recipient: User?
    
    @State private var users = [User]()
    @State private var searchText = ""
    @State private var showingSearchAlert = false
    
    enum UserSearchError: Error {
        case noUsersFound
    }
    
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
            .alert(
                "No users found",
                isPresented: $showingSearchAlert) {
                    Button("OK") { }
                }
        }
    }
    
    private func runSearch() {
        Task {
            do {
                let users = try await listsModel.searchUser(email: searchText)
                Task { @MainActor in
                    self.users = users
                }
                
                if users.isEmpty {
                    throw UserSearchError.noUsersFound
                }
            } catch {
                showingSearchAlert = true
            }
        }
    }
}

#Preview {
    ListAddRecipientForm(
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
