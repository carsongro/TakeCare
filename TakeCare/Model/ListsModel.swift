//
//  ListsModel.swift
//  TakeCare
//
//  Created by Carson Gross on 10/4/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

@Observable final class ListsModel: @unchecked Sendable {
    var lists = [TakeCareList]()
    var currentList: TakeCareList?
    
    init() {
        Task {
            await fetchLists()
        }
    }
    
    func fetchLists() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            let lists = try await Firestore.firestore().collection("lists").whereField("ownerID", isEqualTo: uid).getDocuments().documents.compactMap { try $0.data(as: TakeCareList.self) }
            
            withAnimation {
                self.lists = lists
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func createList(name: String, description: String?, recipients: [User], tasks: [ListTask], listImage: UIImage?) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        var photoURL: String? = nil
        if let image = listImage {
            photoURL = try await ImageManager.uploadImage(image: image, path: .list_images)
        }
        
        let list = TakeCareList(
            ownerID: uid,
            name: name,
            description: description,
            recipients: recipients,
            tasks: tasks,
            photoURL: photoURL
        )
        
        let docRef = Firestore.firestore().collection("lists").document()
        try docRef.setData(from: list)
        
        for recipient in list.recipients {
            try await sendListInvite(to: recipient)
        }
        
        await fetchLists()
    }
    
    func updateList(to list: TakeCareList) async throws {
        // TODO: Implement this
    }
    
    func deleteList(_ list: TakeCareList) async throws {
        guard let id = list.id else { return }
        
        let docRef = Firestore.firestore().collection("lists").document(id)
        try await docRef.delete()
    }
    
    private func sendListInvite(to recipient: User) async throws {
        // TODO: Implement this
    }
}
