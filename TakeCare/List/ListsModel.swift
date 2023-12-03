//
//  ListsModel.swift
//  TakeCare
//
//  Created by Carson Gross on 10/4/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

/// A model for lists
@Observable final class ListsModel: @unchecked Sendable {
    var lists = [TakeCareList]()
    var searchText = ""
    var didFetchLists = false
    
    enum UserSearchError: Error {
        case sameEmail
    }

    init() {
        Task {
            await fetchLists(isInitialFetch: true)
        }
    }
    
    func fetchLists(isInitialFetch: Bool = false) async {
        defer { didFetchLists = true }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        do {
            let updatedLists = try await Firestore.firestore().collection("lists").whereField("ownerID", isEqualTo: uid).getDocuments().documents.compactMap { try $0.data(as: TakeCareList.self) }

            Task { @MainActor in
                withAnimation {
                    self.lists = updatedLists
                }
                
                if isInitialFetch {
                    try await updateTasksCompletion()
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func createList(name: String, description: String?, recipient: User?, tasks: [ListTask], listImage: Image?) async throws {
        guard let ownerID = Auth.auth().currentUser?.uid else { return }
        
        let docRef = Firestore.firestore().collection("lists").document()
        
        var photoURL: String? = nil
        if let image = listImage {
            photoURL = try await FirebaseImageManager.shared.uploadImage(name: docRef.documentID, image: image, path: .list_images)
        }
        
        let sortedTasks = tasks.sorted {
            if let completionDate1 = $0.completionDate,
               let completionDate2 = $1.completionDate {
                return completionDate1 < completionDate2
            } else {
                return $0.title < $1.title
            }
        }
        
        let list = TakeCareList(
            ownerID: ownerID,
            ownerName: AuthModel.shared.currentUser?.displayName ?? "",
            name: name,
            description: description,
            recipientID: recipient?.id,
            tasks: sortedTasks,
            photoURL: photoURL,
            isActive: false
        )
        
        try docRef.setData(from: list)
        
        if let recipient = recipient {
            try await sendListInvite(to: recipient)
        }
        
        await fetchLists()
    }
    
    func updateList(
        id: String,
        name: String,
        description: String?,
        recipient: User?,
        tasks: [ListTask],
        listImage: Image?,
        isActive: Bool,
        sendInvites: Bool,
        shouldUpdateImage: Bool = true
    ) async throws {
        guard let ownerID = Auth.auth().currentUser?.uid else { return }
        
        let docRef = Firestore.firestore().collection("lists").document(id)
        
        var photoURL: String? = if let originalPhotoURL = lists.first(where: { $0.id == id })?.photoURL {
            originalPhotoURL
        } else {
            nil
        }
        
        if shouldUpdateImage, let image = listImage {
            photoURL = try await FirebaseImageManager.shared.uploadImage(name: docRef.documentID, image: image, path: .list_images)
        }
        
        let list = TakeCareList(
            ownerID: ownerID,
            ownerName: AuthModel.shared.currentUser?.displayName ?? "",
            name: name,
            description: description,
            recipientID: recipient?.id,
            tasks: tasks,
            photoURL: photoURL,
            isActive: recipient == nil ? false : isActive
        )
        
        try docRef.setData(from: list)
        
        if let recipient = recipient,
           sendInvites {
            try await sendListInvite(to: recipient)
        }
        
        await fetchLists(isInitialFetch: true)
    }
    
    func deleteList(_ list: TakeCareList) async throws {
        guard let id = list.id else { return }
        
        if list.photoURL != nil {
            try await FirebaseImageManager.shared.deleteImage(name: id, path: .list_images)
        }
        
        let docRef = Firestore.firestore().collection("lists").document(id)
        try await docRef.delete()
        
        await fetchLists()
    }
    
    func searchUser(email: String) async throws -> [User] {
        guard email != Auth.auth().currentUser?.email else { throw UserSearchError.sameEmail }
        let users = try await Firestore.firestore().collection("users").whereField("email", isEqualTo: email.lowercased()).getDocuments().documents.compactMap { try $0.data(as: User.self) }
        return users
    }
    
    private func sendListInvite(to recipient: User) async throws {
        // TODO: Implement this
    }
    
    /// A function that resets the completion status of tasks that repeat daily
    private func updateTasksCompletion() async throws {
        var shouldRefresh = false
        var listsToUpdate = [TakeCareList: [ListTask]]()
        
        for list in lists {
            for task in list.tasks {
                // If the task was marked completed on any day but today, set it to not completed
                if let lastCompletionDate = task.lastCompletionDate,
                   !Calendar.current.isDateInToday(lastCompletionDate),
                   task.isCompleted {
                    shouldRefresh = true
                    
                    if !listsToUpdate.keys.contains(list) {
                        listsToUpdate[list] = [task]
                    } else {
                        listsToUpdate[list]?.append(task)
                    }
                }
            }
        }
        
        if shouldRefresh {
            let db = Firestore.firestore()
            let batch = db.batch()
            
            for (list, tasks) in listsToUpdate {
                var updatedTasks = tasks
                
                for task in tasks {
                    guard let index = updatedTasks.firstIndex(of: task) else { continue }
                    
                    let updatedTask = ListTask(
                        id: task.id,
                        title: task.title,
                        notes: task.notes,
                        completionDate: task.completionDate,
                        repeatInterval: task.repeatInterval,
                        isCompleted: false,
                        lastCompletionDate: task.lastCompletionDate
                    )
                    
                    updatedTasks[index] = updatedTask
                }
                
                let updatedList = TakeCareList(
                    id: list.id,
                    ownerID: list.ownerID,
                    ownerName: list.ownerName,
                    name: list.name,
                    description: list.description,
                    recipientID: list.recipientID,
                    tasks: updatedTasks,
                    photoURL: list.photoURL,
                    isActive: list.isActive
                )
                
                guard let id = updatedList.id else { continue }
                
                let listRef = db.collection("lists").document(id)
                
                try batch.setData(from: updatedList, forDocument: listRef)
            }
            
            let result = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Bool, Error>) in
                batch.commit { error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(with: .success(true))
                    }
                }
            }
            
            if result {
                await fetchLists()
            }
        }
    }
}
