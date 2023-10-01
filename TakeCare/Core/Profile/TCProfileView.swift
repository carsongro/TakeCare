//
//  TCProfileView.swift
//  TakeCare
//
//  Created by Carson Gross on 9/29/23.
//

import SwiftUI
import Kingfisher


struct TCProfileView: View {
    @Environment(TCAuthManager.self) private var authManager
    
    var body: some View {
        if let user = authManager.currentUser {
            List {
                KFImage(URL(string:authManager.currentUser?.photoURL ?? ""))
                    .placeholder { _ in
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .profileImage()
                    }
                    .resizable()
                    .profileImage()
                
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
                        authManager.signOut()
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
            .navigationTitle("Profile")
        }
    }
}

struct ProfileImage: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: 100, height: 100)
            .clipShape(Circle())
            .frame(maxWidth: .infinity)
            .listRowBackground(Color.clear)
    }
}

extension View {
    func profileImage() -> some View {
        modifier(ProfileImage())
    }
}

#Preview {
    NavigationStack {
        TCProfileView()
            .environment(TCAuthManager())
    }
}
