//
//  TCviewModel.swift
//  TakeCare
//
//  Created by Carson Gross on 9/29/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

protocol PasswordFieldProtocol {
    var textFieldsAreValid: Bool { get }
}

@Observable
final class TCAuthViewModel: @unchecked Sendable {
    var userSession: FirebaseAuth.User?
    var currentUser: User?
    
    init() {
        self.userSession = Auth.auth().currentUser
        
        Task {
            await fetchCurrentUser()
        }
    }
    
    func signIn(withEmail email: String, password: String) async {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchCurrentUser()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func createUser(withEmail email: String, password: String, name: String) async {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            Task { @MainActor in
                self.userSession = result.user
            }
            let user = User(
                id: result.user.uid,
                displayName: name,
                email: email,
                photoURL: nil
            )
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            await fetchCurrentUser()
        } catch {
            print("\n\nInTCAuthviewModel createUser: \(error)")
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        } catch {
            print("Failed to sign out: \(error)")
        }
    }
    
    func sendPasswordResetEmail(withEmail email: String) async throws  {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func fetchCurrentUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
        self.currentUser = try? snapshot.data(as: User.self)
    }
    
    func reAuthenticateUser(withEmail email: String, password: String) async throws {
        let authCredential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        try await Auth.auth().currentUser?.reauthenticate(with: authCredential)
    }
    
    // MARK: Manage Users
    
    func deleteUser() async {
        do {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            try? await Firestore.firestore().collection("users").document(uid).delete()
            try await Auth.auth().currentUser?.delete()
            self.userSession = nil
            self.currentUser = nil
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateEmail(to email: String) async {
        do {
            try await Auth.auth().currentUser?.updateEmail(to: email)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateName(to name: String) async {
        do {
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = name
            try await changeRequest?.commitChanges()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateProfileImage(image: UIImage) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        do {
            let photoURL = try await ImageUploader.uploadImage(uid: uid, image: image, path: "profile_images")
            
            try await Firestore.firestore().collection("users").document(uid).updateData(
                ["photoURL": photoURL]
            )
            
            withAnimation {
                currentUser?.photoURL = photoURL
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func removeProfileImage() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        do {
            try await Firestore.firestore().collection("users").document(uid).updateData(
                ["photoURL": FieldValue.delete()]
            )
            
            withAnimation {
                currentUser?.photoURL = nil
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
