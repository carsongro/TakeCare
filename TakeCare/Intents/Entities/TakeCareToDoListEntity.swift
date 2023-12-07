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
    var imageURL: String?
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(
        stringLiteral: "List"
    )
    
    var displayRepresentation: DisplayRepresentation {
        .init(stringLiteral: listName)
    }
    
    var subtitle: DisplayRepresentation {
        .init(stringLiteral: listDescription)
    }
    
    var image: DisplayRepresentation.Image {
        if let url = imageURL {
           return .init(url: image(url: url))
        } else {
            return .init(systemName: "list.bullet.circle.fill")
        }
    }
    
    static var defaultQuery = TakeCareTodoListQuery()
    
    private func hashedKey(forKey key: String) -> String {
        let inputData = Data(key.utf8)
        let hashed = SHA256.hash(data: inputData)
        let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()
        return hashString
    }
    
    private func image(url: String) -> URL {
        let hashedKey = hashedKey(forKey: url)
        
        let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("com.carsongro.Io.ImageCache", isDirectory: true)
        
        let filename = cachesDirectory.appendingPathComponent(hashedKey, isDirectory: false)
        
        return filename
    }
}
