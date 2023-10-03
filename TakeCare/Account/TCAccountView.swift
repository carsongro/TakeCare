//
//  TCAccountView.swift
//  TakeCare
//
//  Created by Carson Gross on 9/29/23.
//

import SwiftUI
import PhotosUI
import Kingfisher


struct TCAccountView: View {
    @Environment(TCAuthViewModel.self) private var viewModel
    
    @State private var accountItem: PhotosPickerItem?
    @State private var showOptions = false
    
    var body: some View {
        if let user = viewModel.currentUser {
            List {
                Section {
                    PhotosPicker(
                        selection: $accountItem,
                        matching: .not(.videos)
                    ) {
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
                        Button("Remove", action: showRemoveImageAlert)
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
                    Button("Sign out", action: showSignOutAlert)
                }
                
                Section {
                    NavigationLink {
                        TCDeleteAccountView()
                    } label: {
                        Text("Delete account")
                    }
                }
            }
            .onChange(of: accountItem) { _, _ in
                Task {
                    if let data = try? await accountItem?.loadTransferable(type: Data.self) {
                        if let uiImage = UIImage(data: data) {
                            Task {
                                await viewModel.updateAccountImage(image: uiImage)
                            }
                        }
                    }
                }
            }
        } else {
            ProgressView()
        }
    }
    
    private func showRemoveImageAlert() {
        AlertManager.shared.showAlert(
            title: "Are you sure you want to remove your account photo?",
            primaryButtonText: "Remove",
            primaryButtonAction: {
                Task {
                    await viewModel.removeAccountImage()
                }
            },
            primaryButtonRole: .destructive,
            secondaryButtonText: "Cancel",
            secondaryButtonRole: .cancel
        )
    }
    
    private func showSignOutAlert() {
        AlertManager.shared.showAlert(
            title: "Are you sure you want to sign out?",
            primaryButtonText: "Sign Out",
            primaryButtonAction: {
                viewModel.signOut()
            },
            secondaryButtonText: "Cancel",
            secondaryButtonRole: .cancel
        )
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
    
    return NavigationStack {
        TCAccountView()
            .environment(viewModel)
    }
}
