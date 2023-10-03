//
//  AccountNavigationStack.swift
//  TakeCare
//
//  Created by Carson Gross on 10/2/23.
//

import SwiftUI
import PhotosUI
import Kingfisher

struct AccountNavigationStack: View {
    @Environment(TCAuthViewModel.self) private var viewModel
    
    @State private var accountItem: PhotosPickerItem?
    @State private var showOptions = false
    @State private var presentingDeleteAccountSheet = false
    
    @State private var errorAlertText = "" {
        didSet {
            showingErrorAlert = true
        }
    }
    @State private var showingErrorAlert = false
    @State private var showingSignOutConfirmation = false
    @State private var showingRemoveImageConfirmation = false
    
    var body: some View {
        NavigationStack {
            if let user = viewModel.currentUser {
                List {
                    Section {
                        PhotosPicker(selection: $accountItem, matching: .not(.videos)) {
                            KFImage(URL(string:viewModel.currentUser?.photoURL ?? ""))
                                .placeholder { _ in
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .accountImage()
                                        .foregroundStyle(Color.secondary)
                                }
                                .resizable()
                                .accountImage()
                        }
                        
                        if viewModel.currentUser?.photoURL != nil {
                            Button("Remove") {
                                showingRemoveImageConfirmation = true
                            }
                            .frame(maxWidth: .infinity)
                            .listRowSeparator(.hidden)
                        }
                    }
                    .listRowBackground(Color(uiColor: .systemGroupedBackground))
                    
                    Section("Details") {
                        Text(user.displayName)
                        
                        Text(user.email)
                    }
                    
                    Section {
                        Button("Sign out") {
                            showingSignOutConfirmation = true
                        }
                    }
                    
                    Section {
                        Button("Delete Account") {
                            presentingDeleteAccountSheet = true
                        }
                        .foregroundStyle(.red)
                    }
                }
                .navigationTitle("Account")
                .onChange(of: accountItem) { _, _ in
                    Task {
                        if let data = try? await accountItem?.loadTransferable(type: Data.self) {
                            if let uiImage = UIImage(data: data) {
                                Task {
                                    do {
                                        try await viewModel.updateAccountImage(image: uiImage)
                                    } catch {
                                        errorAlertText = "There was an error updating your account image"
                                    }
                                }
                            }
                        }
                    }
                }
                .sheet(isPresented: $presentingDeleteAccountSheet) {
                    DeleteAccountForm()
                }
                .alert(errorAlertText, isPresented: $showingErrorAlert) {
                    Button("OK") { }
                }
                .alert("Are you sure you want to sign out?", isPresented: $showingSignOutConfirmation) {
                    Button("Cancel", role: .cancel) { }
                    Button("Sign Out") {
                        do {
                            try viewModel.signOut()
                        } catch {
                            errorAlertText = "There was an error signing out."
                        }
                    }
                }
                .alert("Are you sure you want to remove your account photo?", isPresented: $showingRemoveImageConfirmation) {
                    Button("Cancel", role: .cancel) { }
                    Button("Remove", role: .destructive) {
                        Task {
                            do {
                                try await viewModel.removeAccountImage()
                            } catch {
                                print(error.localizedDescription)
                                errorAlertText = "There was an error remove your account image."
                            }
                        }
                    }
                }
            } else {
                ProgressView()
            }
        }
    }
}

struct AccountImage: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: 130, height: 130)
            .frame(maxWidth: .infinity)
            .clipShape(Circle())
            .overlay {
                ContainerRelativeShape().strokeBorder(.tertiary)
            }
            .containerShape(.circle)
            .compositingGroup()
    }
}

extension View {
    func accountImage() -> some View {
        modifier(AccountImage())
    }
}

#Preview {
    let viewModel = TCAuthViewModel()
    viewModel.currentUser = User(
        id: "",
        displayName: "Carson Gross",
        email: "example@example.com",
        photoURL: nil // https://source.unsplash.com/random
    )
    
    return AccountNavigationStack()
        .environment(viewModel)
}
