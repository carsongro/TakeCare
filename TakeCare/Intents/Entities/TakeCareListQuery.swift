//
//  TakeCareListQuery.swift
//  TakeCare
//
//  Created by Carson Gross on 12/18/23.
//

import Foundation
import Firebase
import AppIntents

struct TakeCareListQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [TakeCareListEntity] {
        let lists = try await FirebaseManager.shared.lists(for: identifiers)
        let imageDataMap = await FirebaseManager.shared.imagesMap(from: lists)
        
        
        return lists.compactMap {
            guard let id = $0.id else { return nil }
            
            return TakeCareListEntity(
                id: id,
                listName: $0.name,
                listDescription: $0.description ?? "",
                imageData: imageDataMap[id, default: nil]
            )
        }
    }
    
    func suggestedEntities() async throws -> [TakeCareListEntity] {
        let lists = try await FirebaseManager.shared.userLists(isRecipient: false)
        let imageDataMap = await FirebaseManager.shared.imagesMap(from: lists)
        
        
        return lists.compactMap {
            guard let id = $0.id else { return nil }
            
            return TakeCareListEntity(
                id: id,
                listName: $0.name,
                listDescription: $0.description ?? "",
                imageData: imageDataMap[id, default: nil]
            )
        }
    }
    
    func entities(matching string: String) async throws -> [TakeCareListEntity] {
        let lists = try await FirebaseManager.shared.userListsWithNameMatching(matching: string, isRecipient: false)
        let imageDataMap = await FirebaseManager.shared.imagesMap(from: lists)
        
        
        return lists.compactMap {
            guard let id = $0.id else { return nil }
            
            return TakeCareListEntity(
                id: id,
                listName: $0.name,
                listDescription: $0.description ?? "",
                imageData: imageDataMap[id, default: nil]
            )
        }
    }
}
