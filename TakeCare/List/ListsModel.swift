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
    
    let db = Firestore.firestore()
    
    private var listsQuery: Query!
    private var loadedDocuments = [QueryDocumentSnapshot]()
    private let pageLimit = 25
    var isPaginating = false
    
    enum UserSearchError: Error {
        case sameEmail
    }
    
    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userSignedIn),
            name: Notification.Name("UserSignedIn"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userSignedOut),
            name: Notification.Name("UserSignedOut"),
            object: nil
        )
        Task { @MainActor in
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(willEnterForground),
                name: UIApplication.willEnterForegroundNotification,
                object: nil
            )
        }
        
        Task {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            listsQuery = db.collection("lists").whereField("ownerID", isEqualTo: uid).limit(to: pageLimit)
            await fetchLists()
        }
        
    }
    
    @objc
    private func userSignedIn() {
        Task {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            listsQuery = db.collection("lists").whereField("ownerID", isEqualTo: uid).limit(to: pageLimit)
            await fetchLists()
        }
    }
    
    @objc private func userSignedOut() {
        lists.removeAll()
        loadedDocuments.removeAll()
    }
    
    @objc
    private func willEnterForground() {
        Task {
            await refreshLists(updateTasksCompletion: true)
        }
    }
    
    func fetchLists() async {
        defer { didFetchLists = true }
        
        do {
            let queryDocuments = try await listsQuery.getDocuments().documents
            loadedDocuments.append(contentsOf: queryDocuments)
            
            let updatedLists = try queryDocuments.compactMap { try $0.data(as: TakeCareList.self) }
            
            Task { @MainActor in
                withAnimation {
                    self.lists.append(contentsOf: updatedLists)
                }
                
                try await updateTasksCompletion()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func paginate() async {
        guard let last = loadedDocuments.last,
              !isPaginating,
              lists.count >= pageLimit,
              !lists.isEmpty else {
            return
        }
        
        isPaginating = true
        defer { isPaginating = false }
        
        listsQuery = listsQuery.start(afterDocument: last)
        await fetchLists()
    }
    
    func refreshLists(updateTasksCompletion: Bool = true, didAddNewList: Bool = false) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        do {
            let refreshQuery = db.collection("lists")
                .whereField("ownerID", isEqualTo: uid)
                .limit(to: lists.count + (didAddNewList ? 1 : 0))
            
            let queryDocuments = try await refreshQuery.getDocuments().documents
            
            if didAddNewList {
                loadedDocuments = queryDocuments
            }
            
            let updatedLists = try await refreshQuery
                .getDocuments()
                .documents
                .compactMap { try $0.data(as: TakeCareList.self) }
            
            Task { @MainActor in
                withAnimation {
                    self.lists = updatedLists
                }
                
                if updateTasksCompletion {
                    try await self.updateTasksCompletion()
                }
            }
        } catch {
            
        }
    }
    
    func createList(name: String, description: String?, recipient: User?, tasks: [ListTask], listImage: Image?) async throws {
        guard let ownerID = Auth.auth().currentUser?.uid, tasks.count <= 50 else { return }
        
        let docRef = db.collection("lists").document()
        
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
            hasRecipientTaskNotifications: false
        )
        
        try docRef.setData(from: list)
        
        await refreshLists(didAddNewList: true)
    }
    
    func updateList(
        id: String,
        name: String,
        description: String?,
        recipient: User?,
        tasks: [ListTask],
        listImage: Image?,
        hasRecipientTaskNotifications: Bool,
        sendInvites: Bool,
        shouldUpdateImage: Bool = true
    ) async throws {
        guard let ownerID = Auth.auth().currentUser?.uid else { return }
        
        let docRef = db.collection("lists").document(id)
        
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
            hasRecipientTaskNotifications: recipient == nil ? false : hasRecipientTaskNotifications
        )
        
        try docRef.setData(from: list)
        
        await refreshLists()
    }
    
    func deleteList(_ list: TakeCareList) async throws {
        guard let id = list.id else { return }
        
        if list.photoURL != nil {
            try await FirebaseImageManager.shared.deleteImage(name: id, path: .list_images)
        }
        
        let docRef = db.collection("lists").document(id)
        try await docRef.delete()
        
        await refreshLists()
    }
    
    func searchUser(email: String) async throws -> [User] {
        guard email != Auth.auth().currentUser?.email else { throw UserSearchError.sameEmail }
        let users = try await db.collection("users").whereField("email", isEqualTo: email.lowercased()).getDocuments().documents.compactMap { try $0.data(as: User.self) }
        return users
    }
    
    /// A function that resets the completion status of tasks that repeat daily
    private func updateTasksCompletion() async throws {
        if try await FirebaseManager.shared.updateDailyTasksCompletion(lists: lists) {
            await refreshLists(updateTasksCompletion: false)
        }
    }
}
