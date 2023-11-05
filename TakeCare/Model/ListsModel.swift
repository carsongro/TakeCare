//
//  ListsModel.swift
//  TakeCare
//
//  Created by Carson Gross on 10/4/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

/// A model for lists
@Observable final class ListsModel: @unchecked Sendable {
    var lists = [TakeCareList]()
    var searchText = ""
    var didFetchLists = false

    init() {
        Task {
            await fetchLists()
        }
    }
    
    func fetchLists() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        do {
            let updatedLists = try await Firestore.firestore().collection("lists").whereField("ownerID", isEqualTo: uid).getDocuments().documents.compactMap { try $0.data(as: TakeCareList.self) }

            Task { @MainActor in
                withAnimation {
                    self.lists = updatedLists
                    didFetchLists = true
                }
            }
        } catch {
            print(error.localizedDescription)
            didFetchLists = true
        }
    }
    
    func createList(name: String, description: String?, recipient: User?, tasks: [ListTask], listImage: UIImage?) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let docRef = Firestore.firestore().collection("lists").document()
        
        var photoURL: String? = nil
        if let image = listImage {
            photoURL = try await LocalImageManager.uploadImage(name: docRef.documentID, image: image, path: .list_images)
        }
        
        let sortedTasks = tasks.sorted {
            if let completionDate1 = $0.completionDate,
               let completionDate2 = $1.completionDate {
                return completionDate1 < completionDate2
            } else {
                return $0.title < $1.title
            }
        }
        
        let list = TakeCareList(
            ownerID: uid,
            name: name,
            description: description,
            recipient: recipient,
            tasks: sortedTasks,
            photoURL: photoURL,
            isActive: false
        )
        
        try docRef.setData(from: list)
        
        if let recipient = recipient {
            try await sendListInvite(to: recipient)
        }
        
        await fetchLists()
    }
    
    func updateList(id: String, name: String, description: String?, recipient: User?, tasks: [ListTask], listImage: UIImage?, isActive: Bool, sendInvites: Bool, shouldUpdateImage: Bool = true) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let docRef = Firestore.firestore().collection("lists").document(id)
        
        var photoURL: String? = if let originalPhotoURL = lists.first(where: { $0.id == id })?.photoURL {
            originalPhotoURL
        } else {
            nil
        }
        
        if shouldUpdateImage, let image = listImage {
            photoURL = try await LocalImageManager.uploadImage(name: docRef.documentID, image: image, path: .list_images)
        }
        
        let list = TakeCareList(
            ownerID: uid,
            name: name,
            description: description,
            recipient: recipient,
            tasks: tasks,
            photoURL: photoURL,
            isActive: recipient == nil ? false : isActive
        )
        
        try docRef.setData(from: list)
        
        if let recipient = recipient,
           sendInvites {
            try await sendListInvite(to: recipient)
        }
        
        await fetchLists()
    }
    
    func deleteList(_ list: TakeCareList) async throws {
        guard let id = list.id else { return }
        
        if list.photoURL != nil {
            try await LocalImageManager.deleteImage(name: id, path: .list_images)
        }
        
        let docRef = Firestore.firestore().collection("lists").document(id)
        try await docRef.delete()
        
        await fetchLists()
    }
    
    func searchUser(email: String) async throws -> [User] {
        let users = try await Firestore.firestore().collection("users").whereField("email", isEqualTo: email.lowercased()).getDocuments().documents.compactMap { try $0.data(as: User.self) }
        return users
    }
    
    private func sendListInvite(to recipient: User) async throws {
        // TODO: Implement this
    }
}
