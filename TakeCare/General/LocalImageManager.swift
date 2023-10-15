//
//  LocalImageManager.swift
//  TakeCare
//
//  Created by Carson Gross on 9/30/23.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore
import SDWebImageSwiftUI
import SwiftUI

/// An object for managing images from firebase
final class LocalImageManager {
    
    enum ImagePath {
        case profile_images
        case list_images
    }
    
    private enum ImageError: Error {
        case jpegConversionError
        case urlError
    }
    
    @discardableResult
    static func uploadImage(
        name: String,
        image: UIImage,
        path: ImagePath
    ) async throws -> String {
        guard let data = image.jpegData(compressionQuality: 0.7) else { throw ImageError.jpegConversionError }
        
        let storageRef = Storage.storage().reference()
        
        let path = "\(path)/\(name).jpg"
        
        let fileRef = storageRef.child(path)
        
        let _ = try await fileRef.putDataAsync(data)
        
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
    
    static func fetchImage(
        url: URL
    ) async throws -> UIImage {
        return try await withCheckedThrowingContinuation { continuation in
            SDWebImageManager.shared.loadImage(with: url, progress: nil) { uiImage, _, error, _, _, _ in
                if let uiImage = uiImage {
                    continuation.resume(with: .success(uiImage))
                } else {
                    continuation.resume(throwing: ImageError.urlError)
                }
            }
        }
    }
}
