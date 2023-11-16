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
    
    final class CacheEntry {
        enum CacheEntryType {
            case ready(Image)
            case inProgress(Task<Image, Error>)
        }
        
        var cacheEntryType: CacheEntryType?
    }
    
    private let cache = NSCache<NSString, CacheEntry>()
    
    enum ImagePath {
        case profile_images
        case list_images
    }
    
    private enum ImageError: Error {
        case jpegConversionError
        case urlError
        case dataError
    }
    
    func Image(from url: URL) async throws -> Image {
        let key = url.absoluteString as NSString
        
        if let entry = cache.object(forKey: key),
           let status = entry.cacheEntryType {
            switch status {
            case .ready(let image):
                return image
            case .inProgress(let task):
                return try await task.value
            }
        }
        
        let task = Task {
            try await downloadImage(url: url)
        }
        
        let cacheEntry = CacheEntry()
        cacheEntry.cacheEntryType = .inProgress(task)
        
        cache.setObject(cacheEntry, forKey: key)
        
        do {
            let image = try await task.value
            cacheEntry.cacheEntryType = .ready(image)
            cache.setObject(cacheEntry, forKey: key)
            return image
        } catch {
            cache.removeObject(forKey: key)
            throw error
        }
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
    
    private func downloadImage(url: URL) async throws -> Image {
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let uiImage = UIImage(data: data) else { throw ImageError.dataError }
        return SwiftUI.Image(uiImage: uiImage)
    }
}
