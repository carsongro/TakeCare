//
//  ProfileNavigationStack.swift
//  TakeCare
//
//  Created by Carson Gross on 10/2/23.
//

import SwiftUI
import PhotosUI
import Kingfisher

struct ProfileNavigationStack: View {
    @Environment(TCAuthViewModel.self) private var viewModel
    
    @State private var profileImageItem: PhotosPickerItem?
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
    @State private var showingProfileImageConfirmation = false
    @State private var showingPhotosPicker = false
    @State private var isUploadingImage = false
    
    var body: some View {
        NavigationStack {
            if let user = viewModel.currentUser {
                List {
                    Section {
                        Button {
                            showingProfileImageConfirmation = true
                        } label: {
                            ZStack {
                                KFImage(URL(string:viewModel.currentUser?.photoURL ?? ""))
                                    .placeholder { _ in
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .accountImage()
                                            .foregroundStyle(Color.secondary)
                                    }
                                    .resizable()
                                    .accountImage()
                                    .blur(radius: isUploadingImage ? 4 : 0)
                                    .opacity(isUploadingImage ? 0.6 : 1)
                                
                                if isUploadingImage {
                                    ProgressView()
                                }
                            }
                            
                        }
                        .accessibilityLabel("Change profile image")
                        .confirmationDialog("Profile Image", isPresented: $showingProfileImageConfirmation) {
                            Button("Select profile image") {
                                showingPhotosPicker = true
                            }
                            
                            if viewModel.currentUser?.photoURL != nil {
                                Button("Remove profile image") {
                                    showingRemoveImageConfirmation = true
                                }
                            }
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
                .navigationTitle("Profile")
                .onChange(of: profileImageItem) { _, _ in
                    Task {
                        if let data = try? await profileImageItem?.loadTransferable(type: Data.self) {
                            if let uiImage = UIImage(data: data) {
                                defer {
                                    withAnimation {
                                        isUploadingImage = false
                                    }
                                }
                                do {
                                    withAnimation {
                                        isUploadingImage = true
                                    }
                                    try await viewModel.updateProfileImage(image: uiImage)
                                    profileImageItem = nil
                                } catch {
                                    errorAlertText = "There was an error updating your profile image"
                                }
                            }
                        }
                    }
                }
                .photosPicker(isPresented: $showingPhotosPicker, selection: $profileImageItem)
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
                .alert("Are you sure you want to remove your profile photo?", isPresented: $showingRemoveImageConfirmation) {
                    Button("Cancel", role: .cancel) { }
                    Button("Remove", role: .destructive) {
                        Task {
                            defer {
                                withAnimation {
                                    isUploadingImage = false
                                }
                            }
                            do {
                                withAnimation {
                                    isUploadingImage = true
                                }
                                try await viewModel.removeProfileImage()
                                profileImageItem = nil
                            } catch {
                                print(error.localizedDescription)
                                errorAlertText = "There was an error remove your profile image."
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
        photoURL: nil
    )
    
    return ProfileNavigationStack()
        .environment(viewModel)
}
