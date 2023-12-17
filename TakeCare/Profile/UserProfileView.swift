//
//  UserProfileView.swift
//  TakeCare
//
//  Created by Carson Gross on 12/3/23.
//

import SwiftUI
import IoImage

struct UserProfileView: View {
    var userID: String
    
    @State private var user: User?
    
    init(userID: String) {
        self.userID = userID
    }
    
    init(user: User) {
        _user = State(initialValue: user)
        userID = user.id
    }
    
    var body: some View {
        Group {
            if let user {
                List {
                    Section {
                        IoImageView(url: URL(string: user.photoURL ?? ""))
                            .resizable()
                            .placeholder {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .accountImage()
                                    .foregroundStyle(Color.secondary)
                            }
                            .accountImage()
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color(.systemGroupedBackground))
                    
                    Section {
                        Text(user.displayName)
                    }
                }
            } else {
                ProgressView()
            }
        }
        .onAppear {
            guard user == nil else { return }
            
            Task {
                let user = await AuthModel.shared.fetchUser(id: userID)
                withAnimation {
                    self.user = user
                }
            }
        }
    }
}

#Preview {
    UserProfileView(userID: "")
}
