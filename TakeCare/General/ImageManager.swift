//
//  ImageManager.swift
//  TakeCare
//
//  Created by Carson Gross on 9/30/23.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore
import UIKit

/// An object for uploading images to firebase
final class ImageManager {
    
    enum ImagePath {
        case profile_images
    }
    
    private enum ImageUploadError: Error {
        case jpegConversionError
        case urlError
    }
    
    @discardableResult
    static func uploadImage(
        name: String = UUID().uuidString,
        image: UIImage,
        path: ImagePath
    ) async throws -> String {
        guard let data = image.jpegData(compressionQuality: 0.7) else { throw ImageUploadError.jpegConversionError }
        
        let storageRef = Storage.storage().reference()
        
        let path = "\(path)/\(name).jpg"
        
        let fileRef = storageRef.child(path)
        
        let _ = try await fileRef.putDataAsync(data)
        
        let db = Firestore.firestore()
        try await db.collection("images").document(name).setData(["url": path])
        
        let urlString = try await fileRef.downloadURL().absoluteString
        
        return urlString
    }
    
    static func deleteImage(
        name: String,
        path: ImagePath
    ) async throws {
        let storageRef = Storage.storage().reference()
        let fileRef = storageRef.child("\(path)/\(name).jpg")
        
        try await fileRef.delete()
    }
}
