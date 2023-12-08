//
//  TakeCareToDoListEntity.swift
//  TakeCare
//
//  Created by Carson Gross on 12/6/23.
//

import AppIntents
import CryptoKit
import SwiftUI

struct TakeCareToDoListEntity: AppEntity {
    var id: String
    var listName: String
    var listDescription: String
    var imageData: Data?
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(
        stringLiteral: "List"
    )
    
    var displayRepresentation: DisplayRepresentation {
        .init(
            title: "\(listName)",
            subtitle: "\(listDescription)",
            image: image
        )
    }
    
    var subtitle: DisplayRepresentation {
        .init(stringLiteral: listDescription)
    }
    
    var image: DisplayRepresentation.Image {
        if let imageData {
            return .init(data: imageData)
        } else {
            return .init(systemName: "list.bullet.circle.fill")
        }
    }
    
    static var defaultQuery = TakeCareTodoListQuery()
}
