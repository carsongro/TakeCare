//
//  FirebaseManager.swift
//  TakeCare
//
//  Created by Carson Gross on 12/6/23.
//

import Foundation
@preconcurrency import Firebase
import IoImage

final class FirebaseManager: Sendable {
    static let shared = FirebaseManager()
    
    private init() { }
    
    private let db = Firestore.firestore()
    
    func getList(for id: String) async throws -> TakeCareList {
        try await db.collection("lists").document(id).getDocument().data(as: TakeCareList.self)
    }
    
    @discardableResult
    func updateDailyTasksCompletion(lists: [TakeCareList]) async throws -> Bool {
        var needsCommit = false
        
        let db = db
        let batch = db.batch()
        
        for list in lists {
            var updatedTasks = [ListTask]()
            
            for task in list.tasks {
                var isCompleted = task.isCompleted
                
                if let lastCompletionDateCalendar = task.lastCompletionDate,
                   !Calendar.current.isDateInToday(lastCompletionDateCalendar),
                   task.repeatInterval == .daily {
                    needsCommit = true
                    isCompleted = false
                }
                
                let updatedTask = ListTask(
                    id: task.id,
                    title: task.title,
                    notes: task.notes,
                    completionDate: task.completionDate,
                    repeatInterval: task.repeatInterval,
                    isCompleted: isCompleted,
                    lastCompletionDate: task.lastCompletionDate
                )
                
                updatedTasks.append(updatedTask)
            }
            
            let updatedList = TakeCareList(
                ownerID: list.ownerID,
                ownerName: list.ownerName,
                name: list.name,
                description: list.description,
                recipientID: list.recipientID,
                tasks: updatedTasks,
                photoURL: list.photoURL,
                hasRecipientTaskNotifications: list.hasRecipientTaskNotifications
            )
            
            guard let id = list.id else { continue }
            
            let listRef = db.collection("lists").document(id)
            
            try batch.setData(from: updatedList, forDocument: listRef)
        }
        
        guard needsCommit else { return needsCommit }
        
        let _ = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Bool, Error>) in
            batch.commit { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(with: .success(true))
                }
            }
        }
        
        return needsCommit
    }
}

// MARK: AppIntents

extension FirebaseManager {
    func lists(for identifiers: [String]) async throws -> [TakeCareList] {
        try await db.collection("lists")
            .whereField(FieldPath.documentID(), in: identifiers)
            .limit(to: 20)
            .getDocuments()
            .documents
            .compactMap { try $0.data(as: TakeCareList.self) }
    }
    
    func userTodoLists() async throws -> [TakeCareList] {
        guard let uid = Auth.auth().currentUser?.uid else { return [] }
        
        return try await db.collection("lists")
            .whereField("recipientID", isEqualTo: uid)
            .limit(to: 20)
            .getDocuments()
            .documents
            .compactMap { try $0.data(as: TakeCareList.self) }
    }
    
    func userTodoWithNameMatching(matching string: String) async throws -> [TakeCareList] {
        guard let uid = Auth.auth().currentUser?.uid else { return [] }
        
        return try await db.collection("lists")
            .whereField("recipientID", isEqualTo: uid)
            .whereField("name", arrayContains: string)
            .limit(to: 20)
            .getDocuments()
            .documents
            .compactMap { try $0.data(as: TakeCareList.self) }
    }
    
    func imagesMap(from lists: [TakeCareList]) async -> [String: Data?] {
        let imagesMap = lists.reduce(into: [String: String?]()) { imagesMap, list in
            imagesMap[list.id] = list.photoURL
        }
        
        var imageDataMap = [String: Data?]()
        for (id, url) in imagesMap {
            guard let id else { continue }
            
            if let url = URL(string: url ?? "") {
                let uiImage = try? await IoImageLoader.shared.loadImage(from: url)
                imageDataMap[id] = uiImage?.jpegData(compressionQuality: 1)
            } else {
                imageDataMap[id] = nil
            }
        }
        
        return imageDataMap
    }
}
