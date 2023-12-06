//
//  ProfileNavigationStack.swift
//  TakeCare
//
//  Created by Carson Gross on 10/2/23.
//

import SwiftUI
import PhotosUI
import IoImage

struct ProfileNavigationStack: View {
    @Environment(AuthModel.self) private var authModel
    
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
    @State private var showingCamera = false
    
    var body: some View {
        NavigationStack {
            if let user = authModel.currentUser {
                List {
                    Section {
                        Button {
                            showingProfileImageConfirmation = true
                        } label: {
                            ZStack {
                                IoImageView(url: URL(string: authModel.currentUser?.photoURL ?? ""))
                                    .resizable()
                                    .placeholder {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .accountImage()
                                            .foregroundStyle(Color.secondary)
                                    }
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
                            Button("Take Photo") {
                                showingCamera = true
                            }
                            
                            Button("Choose Photo") {
                                showingPhotosPicker = true
                            }
                            
                            if authModel.currentUser?.photoURL != nil {
                                Button("Remove profile image") {
                                    showingRemoveImageConfirmation = true
                                }
                            }
                        }
                    }
                    .listRowBackground(Color(.systemGroupedBackground))
                    
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
                .photosPicker(isPresented: $showingPhotosPicker, selection: $profileImageItem)
                .onChange(of: profileImageItem) { _, _ in
                    Task {
                        if let data = try? await profileImageItem?.loadTransferable(type: Data.self) {
                            if let image = Image(data: data) {
                                defer {
                                    withAnimation {
                                        isUploadingImage = false
                                    }
                                }
                                do {
                                    withAnimation {
                                        isUploadingImage = true
                                    }
                                    try await authModel.updateProfileImage(image: image)
                                    profileImageItem = nil
                                } catch {
                                    errorAlertText = "There was an error updating your profile image"
                                }
                            }
                        }
                    }
                }
                .fullScreenCover(isPresented: $showingCamera) {
                    CameraView() { image in
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
                                try await authModel.updateProfileImage(image: image)
                            } catch {
                                errorAlertText = "There was an error updating your profile image"
                            }
                        }
                    }
                    .ignoresSafeArea()
                }
                .sheet(isPresented: $presentingDeleteAccountSheet) {
                    DeleteAccountForm()
                }
                .alert(errorAlertText, isPresented: $showingErrorAlert) { }
                .alert("Are you sure you want to sign out?", isPresented: $showingSignOutConfirmation) {
                    Button("Cancel", role: .cancel) { }
                    Button("Sign Out") {
                        do {
                            try authModel.signOut()
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
                                try await authModel.removeProfileImage()
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
            .aspectRatio(contentMode: .fill)
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
    return ProfileNavigationStack()
        .environment(AuthModel())
}
