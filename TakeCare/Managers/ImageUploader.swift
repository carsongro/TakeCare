//
//  ImageUploader.swift
//  TakeCare
//
//  Created by Carson Gross on 9/30/23.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore
import UIKit

final class ImageUploader {
    
    @discardableResult
    static func uploadImage(
        uid: String = "",
        image: UIImage,
        path: String
    ) async throws -> String {
        guard let data = image.jpegData(compressionQuality: 0.7) else { throw ImageUploadError.jpegConversionError  }
        
        var name = NSUUID().uuidString
        
        if path == "profile_images" {
            name = uid
        }
        
        let storageRef = Storage.storage().reference()
        
        let path = "\(path)/\(name).jpg"
        
        let fileRef = storageRef.child(path)
        
        let _ = try await fileRef.putDataAsync(data)
        
        let db = Firestore.firestore()
        try await db.collection("images").document(name).setData(["url": path])
        
        let urlString = try await fileRef.downloadURL().absoluteString
        
        return urlString
    }
    
    private enum ImageUploadError: Error {
        case jpegConversionError
        case urlError
    }
}
