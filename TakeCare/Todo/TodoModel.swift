//
//  TodoModel.swift
//  TakeCare
//
//  Created by Carson Gross on 10/14/23.
//

import SwiftUI
@preconcurrency import Firebase
import UserNotifications

/// A model for todo lists
@Observable final class TodoModel: @unchecked Sendable {
    var lists = [TakeCareList]()
    var searchText = ""
    var didFetchLists = false
    
    private var localNotificationHelper = LocalNotificationHelper()
    
    private enum TodoError: Error {
        case listNotFound
        case taskNotFound
    }
    
    let db = Firestore.firestore()
    
    private var listsQuery: Query!
    private var loadedDocuments = [QueryDocumentSnapshot]()
    private let pageLimit = 25
    var isPaginating = false
    
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
            
            listsQuery = db.collection("lists").whereField("recipientID", isEqualTo: uid).limit(to: pageLimit)
            await fetchLists(animated: true)
        }
    }
    
    @objc private func userSignedIn() {
        Task {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            listsQuery = db.collection("lists").whereField("recipientID", isEqualTo: uid).limit(to: pageLimit)
            await fetchLists(animated: true)
            
            getNotificationPermissionIfNotDetermined()
        }
    }
    
    @objc private func userSignedOut() {
        lists.removeAll()
        loadedDocuments.removeAll()
    }
    
    @objc
    private func willEnterForground() {
        Task {
            await refreshTodoLists(updatedDailyTasksCompletion: true)
        }
    }
    
    @MainActor
    func fetchLists(animated: Bool = true) async {
        defer {
            didFetchLists = true
        }
        
        do {
            let queryDocuments = try await listsQuery.getDocuments().documents
            loadedDocuments.append(contentsOf: queryDocuments)
            
            let updatedLists = try queryDocuments.compactMap { try $0.data(as: TakeCareList.self) }
            
            withAnimation(animated ? .default : .none) {
                self.lists.append(contentsOf: updatedLists)
            }
            
            try await updateDailyTasksCompletion()
            correctLocalNotificationsIfNeeded()
            
            if !lists.isEmpty {
                // The user could get here if they delete the app without signing out then reinstalled it
                getNotificationPermissionIfNotDetermined()
            }
            
            TakeCareShortcuts.updateAppShortcutParameters()
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @MainActor
    func paginate() async {
        guard let last = loadedDocuments.last, !isPaginating, lists.count >= pageLimit, !lists.isEmpty else { return }
        
        isPaginating = true
        defer { isPaginating = false }
        
        listsQuery = listsQuery.start(afterDocument: last)
        await fetchLists(animated: true)
    }
    
    @MainActor
    func refreshTodoLists(animated: Bool = true, updatedDailyTasksCompletion: Bool = true) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        do {
            let updatedLists = try await db.collection("lists")
                .whereField("recipientID", isEqualTo: uid)
                .limit(to: lists.isEmpty ? pageLimit : lists.count)
                .getDocuments()
                .documents
                .compactMap { try $0.data(as: TakeCareList.self) }
            
            withAnimation(animated ? .default : .none) {
                self.lists = updatedLists
            }
            
            if updatedDailyTasksCompletion {
                try await updateDailyTasksCompletion()
                correctLocalNotificationsIfNeeded()
            }
        } catch {
            
        }
    }
    
    /// A function that resets the completion status of tasks that repeat daily
    private func updateDailyTasksCompletion() async throws {
        try await FirebaseManager.shared.updateDailyTasksCompletion(lists: lists)
        await refreshTodoLists(updatedDailyTasksCompletion: false)
    }
    
    /// A function for updating the completion status of a task
    /// - Parameters:
    ///   - list: The list the task belongs to
    ///   - task: The task to change the completion status for
    ///   - isCompleted: Whether the task should be marked as complete or not
    ///   - scheduleNotification: Defaults to `true`. True means notification will be scheduled when `isCompleted` is `false`.
    /// - Returns: The updated task
    @discardableResult
    func updateListTask(
        list: TakeCareList,
        task: ListTask,
        isCompleted: Bool
    ) async throws -> TakeCareList {
        guard let listID = list.id else { throw TodoError.listNotFound }
        
        let updatedTask = ListTask(
            id: task.id,
            title: task.title,
            notes: task.notes,
            completionDate: task.completionDate,
            repeatInterval: task.repeatInterval,
            isCompleted: isCompleted,
            lastCompletionDate: Date.now
        )
        
        var tasks = list.tasks
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { throw TodoError.taskNotFound }
        tasks[index] = updatedTask
        
        let updatedList = TakeCareList(
            ownerID: list.ownerID,
            ownerName: list.ownerName,
            name: list.name,
            description: list.description,
            recipientID: list.recipientID,
            tasks: tasks,
            photoURL: list.photoURL,
            hasRecipientTaskNotifications: list.hasRecipientTaskNotifications
        )
        
        let docRef = db.collection("lists").document(listID)
        try docRef.setData(from: updatedList)
        
        Task {
            switch updatedTask.repeatInterval {
            case .never:
                if isCompleted {
                    await localNotificationHelper.removePendingNotificationRequests(for: updatedTask)
                } else if updatedTask.completionDate != nil && updatedList.hasRecipientTaskNotifications {
                    try await localNotificationHelper.scheduleTaskNotifications(for: updatedTask)
                }
            case .daily: break
            }
        }
        
        if let newList = try await Firestore.firestore().collection("lists")
            .whereField(FieldPath.documentID(), in: [listID])
            .getDocuments()
            .documents
            .compactMap({ try $0.data(as: TakeCareList.self) }).first,
           let idx = lists.firstIndex(where: { $0.id == listID }) {
            withAnimation {
                lists[idx] = newList
            }
        } else {
            await refreshTodoLists(animated: true)
        }
        
        return updatedList
    }
    
    func updateListRecipientNotifications(hasRecipientTaskNotifications: Bool, list: TakeCareList) {
        Task {
            guard let id = list.id else { return }
            
            do {
                try await db.collection("lists").document(id).updateData(["hasRecipientTaskNotifications" : hasRecipientTaskNotifications])
                
                if hasRecipientTaskNotifications {
                    await localNotificationHelper.handleListNotifications(list: list)
                } else {
                    await localNotificationHelper.removeNotifications(for: list)
                }
                
                await refreshTodoLists(animated: false)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func removeTodoList(list: TakeCareList) async throws {
        guard let id = list.id else { return }
        
        let updatedList = TakeCareList(
            ownerID: list.ownerID,
            ownerName: list.ownerName,
            name: list.name,
            description: list.description,
            recipientID: nil,
            tasks: list.tasks,
            photoURL: list.photoURL,
            hasRecipientTaskNotifications: false
        )
        
        try db.collection("lists").document(id).setData(from: updatedList)
        
        if let idx = lists.firstIndex(where: { $0.id == id }) {
            withAnimation {
                lists.remove(at: idx)
            }
        } else {
            await refreshTodoLists()
        }
        correctLocalNotificationsIfNeeded()
        
        TakeCareShortcuts.updateAppShortcutParameters()
    }
    
    private func correctLocalNotificationsIfNeeded() {
        Task {
            guard await localNotificationHelper.isAuthorized() else { return }
            await localNotificationHelper.removeInvalidLocalNotifications(lists: lists)
            
            do {
                try await localNotificationHelper.addLocalNotificationsForNewTasks(lists: lists)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func getNotificationPermissionIfNotDetermined() {
        Task {
            if await localNotificationHelper.getNotificationAuthorization() {
                correctLocalNotificationsIfNeeded()
            }
        }
    }
}
