//
//  TCauthModel.swift
//  TakeCare
//
//  Created by Carson Gross on 9/29/23.
//

import SwiftUI
@preconcurrency import Firebase
import FirebaseFirestoreSwift
import UserNotifications

protocol TextFieldProtocol {
    var textFieldsAreValid: Bool { get }
}

@Observable
/// A authModel representing providing everything to manage users account, profile, and authentication
final class AuthModel: @unchecked Sendable {
    static let shared = AuthModel()
    
    private(set) var userSession: FirebaseAuth.User?
    private(set) var currentUser: User? {
        didSet {
            TakeCareShortcuts.updateAppShortcutParameters()
        }
    }
    
    var isSignedIn: Bool {
        userSession != nil
    }
    
    init() {
        self.userSession = Auth.auth().currentUser
        
        Task {
            await fetchCurrentUser()
        }
    }
    
    // MARK: Authentication
    
    func signIn(withEmail email: String, password: String) async throws {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        withAnimation {
            self.userSession = result.user
        }
        await fetchCurrentUser()
        NotificationCenter.default.post(name: Notification.Name("UserSignedIn"), object: nil)
    }
    
    func createUser(withEmail email: String, password: String, name: String) async throws {
        let result = try await Auth.auth().createUser(
            withEmail: email,
            password: password
        )
        
        Task { @MainActor in
            withAnimation {
                self.userSession = result.user
            }
        }
        
        let user = User(
            id: result.user.uid,
            displayName: name,
            email: email,
            photoURL: nil
        )
        
        try Firestore.firestore().collection("users").document(user.id).setData(from: user)
        
        await fetchCurrentUser()
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        withAnimation {
            self.userSession = nil
            self.currentUser = nil
        }
    }
    
    func sendPasswordResetEmail(withEmail email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    private func fetchCurrentUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        do {
            let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
        
            try withAnimation {
                self.currentUser = try snapshot.data(as: User.self)
            }
        } catch {
            do {
                /// If the user is here, they have likely deleted an account they are logged into from another device
                try signOut()
            } catch {
                /// This should not be possible but if it is it may be dangerous
                /// for the app to operate in this state so we force crash
                fatalError()
            }
        }
    }
    
    func reAuthenticateUser(withEmail email: String, password: String) async throws {
        let authCredential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        try await Auth.auth().currentUser?.reauthenticate(with: authCredential)
    }
    
    // MARK: Manage Users
    
    func deleteCurrentUser() async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        if currentUser?.photoURL != nil {
            try await removeProfileImage()
        }
        
        // Delete their lists
        let listsids = try await Firestore.firestore().collection("lists").whereField("ownerID", isEqualTo: uid).getDocuments().documents.compactMap { try $0.data(as: TakeCareList.self).id }
        
        for id in listsids {
            let docRef = Firestore.firestore().collection("lists").document(id)
            try await docRef.delete()
        }
        
        try? await Firestore.firestore().collection("users").document(uid).delete()
        try await Auth.auth().currentUser?.delete()
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        withAnimation {
            self.userSession = nil
            self.currentUser = nil
        }
    }
    
    func updateEmail(to email: String) async throws {
        try await Auth.auth().currentUser?.updateEmail(to: email)
    }
    
    func updateName(to name: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        try await Firestore.firestore().collection("users").document(uid).updateData(
            ["displayName": name]
        )
        
        await fetchCurrentUser()
    }
    
    func updateProfileImage(image: Image) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let photoURL = try await FirebaseImageManager.shared.uploadImage(
            name: uid,
            image: image,
            path: .profile_images
        )
        
        try await Firestore.firestore().collection("users").document(uid).updateData(
            ["photoURL": photoURL]
        )
        
        await fetchCurrentUser()
    }
    
    func removeProfileImage() async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        try await Firestore.firestore().collection("users").document(uid).updateData(
            ["photoURL": FieldValue.delete()]
        )
        
        try await FirebaseImageManager.shared.deleteImage(name: uid, path: .profile_images)
        
        await fetchCurrentUser()
        
    }
    
    func fetchUser(id: String) async -> User? {
        guard !id.isEmpty else { return nil }
        
        do {
            return try await Firestore.firestore().collection("users").document(id).getDocument().data(as: User.self)
        } catch {
            return nil
        }
    }
}
