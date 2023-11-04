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
                    updateTasksCompletion()
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
    func updateListTask(list: TakeCareList, task: ListTask, isCompleted: Bool, scheduleNotification: Bool = true) throws -> TakeCareList {
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
    
    private func updateTasksCompletion() {
        var shouldRefresh = false
        
        for list in lists {
            for task in list.tasks {
                // If the task was marked completed on any day but today, set it to not completed
                if let lastCompletionDate = task.lastCompletionDate,
                   !Calendar.current.isDateInToday(lastCompletionDate),
                   task.isCompleted {
                    shouldRefresh = true
                    
                    do {
                        try updateListTask(
                            list: list,
                            task: task,
                            isCompleted: false,
                            scheduleNotification: false
                        )
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
        
        if shouldRefresh {
            Task {
                await fetchLists()
            }
        }
    }
    
    // MARK: Local Notifications
    
    /// When the user makes a list active, it schedules notifications
    private func handleListNotifications(list: TakeCareList) {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self?.getNotificationPermission(list: list)
            case .authorized:
                self?.scheduleNotifications(for: list)
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
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] success, error in
            if success {
                print("Success getting notification permission")
                self?.scheduleNotifications(for: list)
            } else if let error {
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
}
