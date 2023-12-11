//
//  TodoModel.swift
//  TakeCare
//
//  Created by Carson Gross on 10/14/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift
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
    
    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userSignedIn),
            name: Notification.Name("UserSignedIn"),
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
            await fetchLists(animated: true, isInitialFetch: true)
        }
    }
    
    @objc private func userSignedIn() {
        Task {
            await fetchLists(animated: true, isInitialFetch: true)
            getNotificationPermissionIfNotDetermined()
        }
    }
    
    @objc
    private func willEnterForground() {
        Task {
            await fetchLists(isInitialFetch: true)
        }
    }
    
    func refresh() {
        Task {
            await fetchLists(isInitialFetch: true)
        }
    }
    
    func fetchLists(animated: Bool = true, isInitialFetch: Bool = false) async {
        defer { didFetchLists = true }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        do {
            let updatedLists = try await Firestore.firestore().collection("lists").whereField("recipientID", isEqualTo: uid).getDocuments().documents.compactMap { try $0.data(as: TakeCareList.self) }
            
            Task { @MainActor in
                withAnimation(animated ? .default : .none) {
                    self.lists = updatedLists
                }
                
                if isInitialFetch {
                    try await updateDailyTasksCompletion()
                }
                correctLocalNotificationsIfNeeded()
                
                if !lists.isEmpty {
                    // The user could get here if they delete the app without signing out then reinstalled it
                    getNotificationPermissionIfNotDetermined()
                }
                
                TakeCareShortcuts.updateAppShortcutParameters()
            }
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// A function that resets the completion status of tasks that repeat daily
    private func updateDailyTasksCompletion() async throws {
        var needsCommit = false
        
        let db = Firestore.firestore()
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
        
        guard needsCommit else { return }
        
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
    ) throws -> TakeCareList {
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
        
        let docRef = Firestore.firestore().collection("lists").document(listID)
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
        
        return updatedList
    }
    
    func updateListActive(hasRecipientTaskNotifications: Bool, list: TakeCareList) {
        Task {
            guard let id = list.id else { return }
            
            do {
                try await Firestore.firestore().collection("lists").document(id).updateData(["hasRecipientTaskNotifications" : hasRecipientTaskNotifications])
                
                if hasRecipientTaskNotifications {
                    await localNotificationHelper.handleListNotifications(list: list)
                } else {
                    await localNotificationHelper.removeNotifications(for: list)
                }
                
                await fetchLists(animated: false)
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
        
        try Firestore.firestore().collection("lists").document(id).setData(from: updatedList)
        
        await fetchLists()
        
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
