//
//  TCProfileView.swift
//  TakeCare
//
//  Created by Carson Gross on 9/29/23.
//

import SwiftUI
import PhotosUI
import Kingfisher


struct TCProfileView: View {
    @Environment(TCAuthViewModel.self) private var viewModel
    
    @State private var profileItem: PhotosPickerItem?
    @State private var showOptions = false
    @State private var showRemoveAlert = false
    
    var body: some View {
        if let user = viewModel.currentUser {
            NavigationStack {
                List {
                    Section {
                        PhotosPicker(
                            selection: $profileItem,
                            matching: .not(.videos)
                        ) {
                            KFImage(URL(string:viewModel.currentUser?.photoURL ?? ""))
                                .placeholder { _ in
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .profileImage()
                                        .foregroundStyle(Color.secondary)
                                }
                                .resizable()
                                .profileImage()
                        }
                    }
                    .listRowBackground(Color(uiColor: .systemGroupedBackground))
                    
                    Section {
                        if viewModel.currentUser?.photoURL != nil {
                            Section {
                                Button("Remove profile photo") {
                                    showRemoveAlert = true
                                }
                            }
                        }
                    }
                    
                    Section("Details") {
                        Text(user.displayName)
                            .fontWeight(.semibold)
                        
    //                    NavigationLink {
    //                        TCUpdateEmailView()
    //                    } label: {
    //                        Text(user.email)
    //                    }
                        Text(user.email)
                    }
                    
                    Section("Actions") {
                        Button("Sign out") {
                            viewModel.signOut()
                        }
                    }
                    
                    Section {
                        NavigationLink {
                            TCDeleteAccountView()
                        } label: {
                            Text("Delete account")
                                .foregroundStyle(.red)
                        }
                    }
                }
                .alert(
                    "Are you sure you want to remove your profile photo?",
                    isPresented: $showRemoveAlert
                ) {
                    Button("Cancel", role: .cancel) { }
                    Button("Remove", role: .destructive) {
                        Task {
                            await viewModel.removeProfileImage()
                        }
                    }
                }
                .onChange(of: profileItem) { _, _ in
                    Task {
                        if let data = try? await profileItem?.loadTransferable(type: Data.self) {
                            if let uiImage = UIImage(data: data) {
                                Task {
                                    await viewModel.updateProfileImage(image: uiImage)
                                }
                            }
                        }
                        
                        print("Failed")
                    }
                }
                .navigationTitle("Profile")
            }
        }
    }
}

struct ProfileImage: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: 130, height: 130)
            .frame(maxWidth: .infinity)
            .clipShape(Circle())
    }
}

extension View {
    func profileImage() -> some View {
        modifier(ProfileImage())
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
        TCProfileView()
            .environment(viewModel)
    }
}
