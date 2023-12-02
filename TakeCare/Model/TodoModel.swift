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
        NotificationCenter.default.addObserver(self, selector: #selector(userSignedIn), name: Notification.Name("UserSignedIn"), object: nil)
        Task {
            await fetchLists(animated: true, isInitialFetch: true)
        }
    }
    
    @objc private func userSignedIn() {
        Task {
            if await localNotificationHelper.getNotificationAuthorization() {
                correctLocalNotificationsIfNeeded()
            }
        }
    }
    
    func refresh() {
        Task {
            await fetchLists(isInitialFetch: true)
        }
    }
    
    func fetchLists(animated: Bool = true, isInitialFetch: Bool = false) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        do {
            let listRef = FieldPath(["recipient", "id"])
            let updatedLists = try await Firestore.firestore().collection("lists").whereField(listRef, isEqualTo: uid).getDocuments().documents.compactMap { try $0.data(as: TakeCareList.self) }
            
            Task { @MainActor in
                withAnimation(animated ? .default : .none) {
                    self.lists = updatedLists
                }
                
                if isInitialFetch {
                    try await updateDailyTasksCompletion()
                    didFetchLists = true
                    correctLocalNotificationsIfNeeded()
                }
            }
        } catch {
            print(error.localizedDescription)
            didFetchLists = true
        }
    }
    
    /// A function that resets the completion status of tasks that repeat daily
    private func updateDailyTasksCompletion() async throws {
        var shouldRefresh = false
        var listsToUpdate = [TakeCareList: [ListTask]]()
        
        for list in lists {
            for task in list.tasks {
                // If the task was marked completed on any day but today, set it to not completed
                if let lastCompletionDate = task.lastCompletionDate,
                   !Calendar.current.isDateInToday(lastCompletionDate),
                   task.isCompleted,
                   task.repeatInterval == .daily {
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
                var updatedList = list
                
                for task in tasks {
                    guard let index = updatedList.tasks.firstIndex(of: task) else { continue }
                    
                    let updatedTask = ListTask(
                        id: task.id,
                        title: task.title,
                        notes: task.notes,
                        completionDate: task.completionDate,
                        repeatInterval: task.repeatInterval,
                        isCompleted: false,
                        lastCompletionDate: task.lastCompletionDate
                    )
                    
                    updatedList.tasks[index] = updatedTask
                }
                
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
        isCompleted: Bool,
        lastCompletionDate: Date? = Date.now
    ) throws -> TakeCareList {
        guard let listID = list.id else { throw TodoError.listNotFound }
        
        let updatedTask = ListTask(
            id: task.id,
            title: task.title,
            notes: task.notes,
            completionDate: task.completionDate,
            repeatInterval: task.repeatInterval,
            isCompleted: isCompleted,
            lastCompletionDate: lastCompletionDate
        )
        
        var tasks = list.tasks
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { throw TodoError.taskNotFound }
        tasks[index] = updatedTask
        
        let updatedList = TakeCareList(
            ownerID: list.ownerID,
            name: list.name,
            description: list.description,
            recipient: list.recipient,
            tasks: tasks,
            photoURL: list.photoURL,
            isActive: list.isActive
        )
        
        let docRef = Firestore.firestore().collection("lists").document(listID)
        try docRef.setData(from: updatedList)
        
        Task {
            switch updatedTask.repeatInterval {
            case .never:
                if isCompleted {
                    await localNotificationHelper.removePendingNotificationRequests(for: updatedTask)
                } else if updatedTask.completionDate != nil && updatedList.isActive {
                    try await localNotificationHelper.scheduleTaskNotifications(for: updatedTask)
                }
            case .daily: break
            }
        }
        
        return updatedList
    }
    
    func updateListActive(isActive: Bool, list: TakeCareList) {
        Task {
            guard let id = list.id else { return }
            
            do {
                try await Firestore.firestore().collection("lists").document(id).updateData(["isActive" : isActive])
                
                if isActive {
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
            name: list.name,
            description: list.description,
            recipient: nil,
            tasks: list.tasks,
            photoURL: list.photoURL,
            isActive: false
        )
        
        try Firestore.firestore().collection("lists").document(id).setData(from: updatedList)
        
        await fetchLists()
        
        correctLocalNotificationsIfNeeded()
    }
    
    private func correctLocalNotificationsIfNeeded() {
        Task {
            guard await localNotificationHelper.isAuthorized() else { return }
            await localNotificationHelper.removeLocalNotificationsForDeletedTasks(lists: lists)
            
            do {
                try await localNotificationHelper.addLocalNotificationsForNewTasks(lists: lists)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
