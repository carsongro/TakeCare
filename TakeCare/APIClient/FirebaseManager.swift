//
//  FirebaseManager.swift
//  TakeCare
//
//  Created by Carson Gross on 12/6/23.
//

import Foundation
import Firebase

final class FirebaseManager: Sendable {
    static let shared = FirebaseManager()
    
    private init() { }
    
    func getList(for id: String) async throws -> TakeCareList {
        try await Firestore.firestore().collection("lists").document(id).getDocument().data(as: TakeCareList.self)
    }
}

// MARK: AppIntents

extension FirebaseManager {
    func lists(for identifiers: [String]) async throws -> [TakeCareList] {
        try await Firestore.firestore().collection("lists").whereField(FieldPath.documentID(), in: identifiers).getDocuments().documents.compactMap { try $0.data(as: TakeCareList.self) }
    }
    
    func userTodoLists() async throws -> [TakeCareList] {
        guard let uid = Auth.auth().currentUser?.uid else { return [] }
        
        return try await Firestore.firestore().collection("lists").whereField("recipientID", isEqualTo: uid).getDocuments().documents.compactMap { try $0.data(as: TakeCareList.self) }
    }
    
    func userTodoWithNameMatching(matching string: String) async throws -> [TakeCareList] {
        guard let uid = Auth.auth().currentUser?.uid else { return [] }
        
        return try await Firestore.firestore().collection("lists")
            .whereField("recipientID", isEqualTo: uid)
            .whereField("name", arrayContains: string)
            .getDocuments()
            .documents
            .compactMap { try $0.data(as: TakeCareList.self) }
    }
}
