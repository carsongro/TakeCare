//
//  ListsModel.swift
//  TakeCare
//
//  Created by Carson Gross on 10/4/23.
//

import Foundation
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
            lists = try await Firestore.firestore().collection("lists").whereField("ownerID", isEqualTo: uid).getDocuments().documents.compactMap { try $0.data(as: TakeCareList.self) }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func createList(list: TakeCareList) async throws {
        let docRef = Firestore.firestore().collection("lists").document()
        
//        let id = docRef.documentID // Reference showing how to get id from document
        
        try docRef.setData(from: list)
        
        // TODO: If there is a recipient on the list, send them an invite
    }
    
    func addTask(_ task: ListTask) async throws {
        
    }
    
    func updateTask() async throws {
        
    }
    
    func removeTask(_ task: ListTask) async throws {
        
    }
    
    func updateListName(to name: String) async throws {
        
    }
    
    func updateListRecipient(to userID: String) async throws {
        
    }
    
    func deleteList(_ list: TakeCareList) async throws {
        guard let id = list.id else { return }
        
        let docRef = Firestore.firestore().collection("lists").document(id)
        try await docRef.delete()
    }
}
