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
    
    var errorMessage = "" {
        didSet {
            AlertManager.shared.showAlert(title: errorMessage)
        }
    }
    
    init() {
        self.userSession = Auth.auth().currentUser
        
        Task {
            await fetchCurrentUser()
        }
    }
    
    func signIn(withEmail email: String, password: String) async {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            withAnimation {
                self.userSession = result.user
            }
            await fetchCurrentUser()
        } catch {
            errorMessage = "There was an error logging in."
        }
    }
    
    func createUser(withEmail email: String, password: String, name: String) async {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
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
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            
            await fetchCurrentUser()
        } catch {
            errorMessage = "There was an error creating a new account."
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            withAnimation {
                self.userSession = nil
                self.currentUser = nil
            }
        } catch {
            errorMessage = "Failed to sign out."
        }
    }
    
    @discardableResult
    func sendPasswordResetEmail(withEmail email: String) async -> Bool {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            return true
        } catch {
            errorMessage = "There was an error sending a password reset email."
            return false
        }
    }
    
    private func fetchCurrentUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
        withAnimation {
            self.currentUser = try? snapshot.data(as: User.self)
        }
    }
    
    func reAuthenticateUser(withEmail email: String, password: String) async {
        do {
            let authCredential = EmailAuthProvider.credential(withEmail: email, password: password)
            
            try await Auth.auth().currentUser?.reauthenticate(with: authCredential)
        } catch {
            errorMessage = "There was an error verifying your credentials."
        }
    }
    
    // MARK: Manage Users
    
    func deleteCurrentUser() async {
        do {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            try? await Firestore.firestore().collection("users").document(uid).delete()
            try await Auth.auth().currentUser?.delete()
            withAnimation {
                self.userSession = nil
                self.currentUser = nil
            }
        } catch {
            errorMessage = "There was an error deleting your account."
        }
    }
    
    func updateEmail(to email: String) async {
        do {
            try await Auth.auth().currentUser?.updateEmail(to: email)
        } catch {
            errorMessage = "There was an error updating your email."
        }
    }
    
    func updateName(to name: String) async {
        do {
            
        } catch {
            errorMessage = "There was an error updating your account name"
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
            errorMessage = "There was an error updating your profile image"
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
            
            try await Firestore.firestore().collection("images").document(uid).delete()
        } catch {
            errorMessage = "There was an error removing your profile image"
        }
    }
}
