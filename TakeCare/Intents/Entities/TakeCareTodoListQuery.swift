//
//  TakeCareTodoListQuery.swift
//  TakeCare
//
//  Created by Carson Gross on 12/6/23.
//

import Foundation
import Firebase
import AppIntents

struct TakeCareTodoListQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [TakeCareToDoListEntity] {
        try await FirebaseManager.shared.lists(for: identifiers).compactMap {
            guard let id = $0.id else { return nil }
            
            return TakeCareToDoListEntity(
                id: id,
                listName: $0.name,
                listDescription: $0.description ?? "",
                imageURL: $0.photoURL
            )
        }
    }
    
    func suggestedEntities() async throws -> [TakeCareToDoListEntity] {
        try await FirebaseManager.shared.userTodoLists().compactMap {
            guard let id = $0.id else { return nil }
            
            return TakeCareToDoListEntity(
                id: id,
                listName: $0.name,
                listDescription: $0.description ?? "",
                imageURL: $0.photoURL
            )
        }
    }
    
    func entities(matching string: String) async throws -> [TakeCareToDoListEntity] {
        try await FirebaseManager.shared.userTodoWithNameMatching(matching: string).compactMap {
            guard let id = $0.id else { return nil }
            
            return TakeCareToDoListEntity(
                id: id,
                listName: $0.name,
                listDescription: $0.description ?? "",
                imageURL: $0.photoURL
            )
        }
    }
}
