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
        let lists = try await FirebaseManager.shared.lists(for: identifiers)
        let imageDataMap = await FirebaseManager.shared.imagesMap(from: lists)
        
        
        return lists.compactMap {
            guard let id = $0.id else { return nil }
            
            return TakeCareToDoListEntity(
                id: id,
                listName: $0.name,
                listDescription: $0.description ?? "",
                imageData: imageDataMap[id, default: nil]
            )
        }
    }
    
    func suggestedEntities() async throws -> [TakeCareToDoListEntity] {
        let lists = try await FirebaseManager.shared.userTodoLists()
        let imageDataMap = await FirebaseManager.shared.imagesMap(from: lists)
        
        
        return lists.compactMap {
            guard let id = $0.id else { return nil }
            
            return TakeCareToDoListEntity(
                id: id,
                listName: $0.name,
                listDescription: $0.description ?? "",
                imageData: imageDataMap[id, default: nil]
            )
        }
    }
    
    func entities(matching string: String) async throws -> [TakeCareToDoListEntity] {
        let lists = try await FirebaseManager.shared.userTodoWithNameMatching(matching: string)
        let imageDataMap = await FirebaseManager.shared.imagesMap(from: lists)
        
        
        return lists.compactMap {
            guard let id = $0.id else { return nil }
            
            return TakeCareToDoListEntity(
                id: id,
                listName: $0.name,
                listDescription: $0.description ?? "",
                imageData: imageDataMap[id, default: nil]
            )
        }
    }
}
