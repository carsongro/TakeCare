//
//  FirebaseImageManager.swift
//  TakeCare
//
//  Created by Carson Gross on 9/30/23.
//

import FirebaseStorage
import FirebaseFirestore
import SwiftUI

/// A shared singleton instance for managing images in firebase
final class FirebaseImageManager {
    public static let shared = FirebaseImageManager()
    
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
        
        let data = if let squareData = await image.uiImage()?.croppedToSquare()?.jpegData(compressionQuality: 0.7) {
            squareData
        } else if let defaultData = await image.data(compressionQuality: 0.7) {
            defaultData
        } else {
            throw ImageError.jpegConversionError
        }
        
        let storageRef = Storage.storage().reference()
        let path = "\(path)/\(name).jpg"
        let fileRef = storageRef.child(path)
        _ = try await fileRef.putDataAsync(data)
        
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
