//
//  LocalImageManager.swift
//  TakeCare
//
//  Created by Carson Gross on 9/30/23.
//

@preconcurrency import Foundation
@preconcurrency import FirebaseStorage
import FirebaseFirestore
import SwiftUI

/// An global actor for managing images
@globalActor
actor ImageManager {
    public static let shared = ImageManager()
    
    private init() { }
    
    enum ImagePath {
        case profile_images
        case list_images
    }
    
    private enum ImageError: Error {
        case jpegConversionError
        case urlError
        case dataError
    }
    
    // MARK: Firebase
    
    @discardableResult
    func uploadImage(
        name: String,
        image: Image,
        path: ImagePath
    ) async throws -> String {
        
        guard let data = await image.data(compressionQuality: 0.7) else { throw ImageError.jpegConversionError }
        
        let storageRef = Storage.storage().reference()
        let path = "\(path)/\(name).jpg"
        let fileRef = storageRef.child(path)
        let _ = try await fileRef.putDataAsync(data)
        
        let urlString = try await fileRef.downloadURL().absoluteString
        
        return urlString
    }
    
    func deleteImage(
        name: String,
        path: ImagePath
    ) async throws {
        let storageRef = Storage.storage().reference()
        let fileRef = storageRef.child("\(path)/\(name).jpg")
        
        try await fileRef.delete()
    }
}
