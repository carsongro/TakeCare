//
//  TodoModel.swift
//  TakeCare
//
//  Created by Carson Gross on 10/14/23.
//

import SwiftUI
@preconcurrency import Firebase
@preconcurrency import FirebaseFirestoreSwift
import UserNotifications

/// A model for todo lists
@Observable final class TodoModel: @unchecked Sendable {
    var lists = [TakeCareList]()
    var searchText = ""
    var didFetchLists = false
    
    private enum TodoError: Error {
        case listNotFound
        case taskNotFound
    }
    
    init() {
        Task {
            await fetchLists(animated: true, isInitialFetch: true)
        }
    }
    
    func refresh() {
        Task {
            await fetchLists()
        }
    }
    
    func fetchLists(animated: Bool = true, isInitialFetch: Bool = false) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        do {
            let listRef = FieldPath(["recipient", "id"])
            let updatedLists = try await Firestore.firestore().collection("lists").whereField(listRef, isEqualTo: uid).getDocuments().documents.compactMap { try $0.data(as: TakeCareList.self) }
            
            Task { @MainActor in
                if animated {
                    withAnimation {
                        self.lists = updatedLists
                        didFetchLists = true
                    }
                } else {
                    self.lists = updatedLists
                    didFetchLists = true
                }
                
                if isInitialFetch {
                    try await updateTasksCompletion()
                    correctLocalNotificationsIfNeeded()
                }
            }
        } catch {
            print(error.localizedDescription)
            didFetchLists = true
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
    func updateListTask(list: TakeCareList, task: ListTask, isCompleted: Bool, scheduleNotification: Bool = true, lastCompletionDate: Date = Date.now) throws -> TakeCareList {
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
        
        // If the task is completed and it doesn't repeat then we remove the notification
        // Otherwise if the task has a completion date then we schedule one
        if isCompleted && task.repeatInterval == .never {
            Task {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [updatedTask.id])
            }
        } else if updatedTask.completionDate != nil && !isCompleted && scheduleNotification {
            scheduleTaskNotifications(for: updatedTask)
        }
        
        return updatedList
    }
    
    func updateListActive(isActive: Bool, list: TakeCareList) {
        guard let id = list.id else { return }
        
        Firestore.firestore().collection("lists").document(id).updateData(["isActive" : isActive])
        
        if isActive {
            handleListNotifications(list: list)
        } else {
            removeNotifications(for: list)
        }
        
        Task {
            await fetchLists(animated: false)
        }
    }
    
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
    
    // MARK: Local Notifications
    
    /// When the user makes a list active, it schedules notifications
    private func handleListNotifications(list: TakeCareList) {
        Task {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            switch settings.authorizationStatus {
            case .notDetermined:
                getNotificationPermission(list: list)
            case .authorized:
                scheduleNotifications(for: list)
            default:
                break
            }
        }
    }
    
    /// When the user makes a list inactive, it removes notifications
    private func removeNotifications(for list: TakeCareList) {
        Task {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: list.tasks.compactMap { $0.id })
        }
    }
    
    private func getNotificationPermission(list: TakeCareList) {
        Task {
            do {
                try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
                scheduleNotifications(for: list)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func scheduleNotifications(for list: TakeCareList) {
        for task in list.tasks {
            scheduleTaskNotifications(for: task)
        }
    }
    
    private func scheduleTaskNotifications(for task: ListTask) {
        guard let completionDate = task.completionDate, !task.isCompleted else { return }
        
        let dateComponents = Calendar.current.dateComponents(
            Set(
                arrayLiteral: Calendar.Component.year,
                Calendar.Component.month,
                Calendar.Component.day,
                Calendar.Component.hour,
                Calendar.Component.minute
            ),
            from: completionDate
        )
        
        let content = UNMutableNotificationContent()
        content.title = task.title
        if let notes = task.notes {
            content.subtitle = notes
        }
        content.sound = UNNotificationSound.default
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: task.repeatInterval == .daily)
        
        let request = UNNotificationRequest(identifier: task.id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    
    private func correctLocalNotificationsIfNeeded() {
        Task {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            guard settings.authorizationStatus == .authorized else { return }
            
            removeLocalNotificationsForDeletedTasks()
            addLocalNotificationsForNewTasks()
        }
    }
    
    /// A method to remove local notifications if the logged in user has been removed from a list as a recipient
    /// Or a list task is deleted by the list owner while the list is active
    private func removeLocalNotificationsForDeletedTasks() {
        Task {
            let allTodoTasksIDs = Set(lists.compactMap { $0.tasks.compactMap { $0.id } }.joined())
            let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
            
            var idsToRemove = [String]()
            for id in requests.compactMap({ $0.identifier }) {
                if !allTodoTasksIDs.contains(id) {
                    idsToRemove.append(id)
                }
            }
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: idsToRemove)
        }
    }
    
    /// A method to add local notifications for tasks that have been added since accepting the list
    private func addLocalNotificationsForNewTasks() {
        Task {
            let allTodoTasks = lists.compactMap { $0.tasks.compactMap { $0 } }.joined()
            let requests = Set(await UNUserNotificationCenter.current().pendingNotificationRequests().compactMap { $0.identifier })
            
            for task in allTodoTasks {
                if !requests.contains(task.id) {
                    scheduleTaskNotifications(for: task)
                }
            }
        }
    }
}
