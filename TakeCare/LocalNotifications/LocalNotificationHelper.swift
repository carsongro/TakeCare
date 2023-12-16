//
//  LocalNotificationHelper.swift
//  TakeCare
//
//  Created by Carson Gross on 11/24/23.
//

import Foundation
@preconcurrency import UserNotifications

actor LocalNotificationHelper {
    
    /// A method to remove local notifications if the logged in user has been removed from a list as a recipient, a list task is deleted by the list owner while the user is receiving notifications
    /// or if they turned off notifications on another device
    /// - Parameter lists: The current todo lists
    func removeInvalidLocalNotifications(lists: [TakeCareList]) async {
        let allTodoTasksIDs = Set(lists.compactMap { $0.tasks.map(\.id) }.joined())
        let invalidTaskIDs = Set(lists.filter { !$0.hasRecipientTaskNotifications }.compactMap { $0.tasks.map(\.id) }.joined())

        let requests = await getExistingRequestsIDs()
        
        let idsToRemove = Array(requests.filter { !allTodoTasksIDs.contains($0) || invalidTaskIDs.contains($0) })
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: idsToRemove)
    }
    
    /// A method to add local notifications for tasks that have been added since accepting the list
    func addLocalNotificationsForNewTasks(lists: [TakeCareList]) async throws {
        let allTodoTasks = lists.filter(\.hasRecipientTaskNotifications).map(\.tasks).joined()
        let requests = await getExistingRequestsIDs()
        
        for task in allTodoTasks {
            if !requests.contains(task.id) {
                try await scheduleTaskNotifications(for: task)
            }
        }
    }
    
    func handleListNotifications(list: TakeCareList) async {
        Task {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            switch settings.authorizationStatus {
            case .notDetermined:
                do {
                    if try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {
                        try await scheduleNotifications(for: list)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            case .authorized:
                try await scheduleNotifications(for: list)
            default:
                break
            }
        }
    }
    
    func getNotificationAuthorization() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        switch settings.authorizationStatus {
        case .notDetermined:
            do {
                return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            } catch {
                return false
            }
        case .authorized:
            return true
        default:
            return false
        }
    }
    
    /// Schedules local notifications for a list
    /// - Parameter list: The list to schedule local notifications for
    func scheduleNotifications(for list: TakeCareList) async throws {
        for task in list.tasks {
            try await scheduleTaskNotifications(for: task)
        }
    }
    
    /// Removes local notifications for a list
    /// - Parameter list: The list to remove local notifications for
    func removeNotifications(for list: TakeCareList) async {
        guard await isAuthorized() else { return }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: list.tasks.map(\.id))
    }
    
    /// Schedules local notifications for a task
    /// - Parameter task: The task to schedule notifications for
    func scheduleTaskNotifications(for task: ListTask) async throws {
        guard let completionDate = task.completionDate else { return }
        
        let components = Set(
            arrayLiteral: Calendar.Component.year,
            Calendar.Component.month,
            Calendar.Component.day,
            Calendar.Component.hour,
            Calendar.Component.minute
        )
        
        var dateComponents = Calendar.current.dateComponents(components, from: completionDate)
        guard let hour = dateComponents.hour, let minute = dateComponents.minute else { return }
        
        switch task.repeatInterval {
        case .never: guard completionDate > Date.now else { return }
        case .daily:
            if completionDate.comparableTime < Date.now.comparableTime || task.isCompleted {
                guard let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()),
                      let newDate = Calendar.current.date(
                        bySettingHour: hour,
                        minute: minute,
                        second: 0,
                        of: tomorrow
                      ) else { return }
                
                dateComponents = Calendar.current.dateComponents(components, from: newDate)
            }
        }
        
        let content = UNMutableNotificationContent()
        content.title = task.title
        if let notes = task.notes {
            content.subtitle = notes
        }
        content.sound = UNNotificationSound.default
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: task.repeatInterval == .daily)
        
        let request = UNNotificationRequest(identifier: task.id, content: content, trigger: trigger)
        
        try await UNUserNotificationCenter.current().add(request)
    }
    
    func getExistingRequestsIDs() async -> Set<String> {
        Set(await UNUserNotificationCenter.current().pendingNotificationRequests().map(\.identifier))
    }
    
    func removePendingNotificationRequests(for task: ListTask) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.id])
    }
    
    /// Checks if local notifications are authorized
    /// - Returns: A Bool indicating if local notifications are authorized
    func isAuthorized() async -> Bool {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus == .authorized
    }
}
