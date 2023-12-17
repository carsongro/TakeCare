//
//  TakeCareList.swift
//  TakeCare
//
//  Created by Carson Gross on 10/4/23.
//

import Firebase
@preconcurrency import FirebaseFirestoreSwift
import Foundation


struct TakeCareList: Codable, Hashable, Identifiable, Sendable, Equatable {
    @DocumentID var id: String?
    let ownerID: String
    let name: String
    let description: String?
    let recipientID: String?
    let tasks: [ListTask]
    let photoURL: String?
    let hasRecipientTaskNotifications: Bool
    
    static func == (lhs: TakeCareList, rhs: TakeCareList) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.description == rhs.description &&
        lhs.recipientID == rhs.recipientID &&
        lhs.tasks == rhs.tasks &&
        lhs.photoURL == rhs.photoURL &&
        lhs.hasRecipientTaskNotifications == rhs.hasRecipientTaskNotifications
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: Task Filtering

extension TakeCareList {
    
    var dailyTasksCompletedCount: Int {
        tasksToday.count - tasksTodayNotCompleted.count
    }
    
    var dailyTasksCount: Int {
        tasksToday.count
    }
    
    /// Tasks today that are either completed or not
    var tasksToday: [ListTask] {
        tasks.filter {
            if let completionDate = $0.completionDate,
               (($0.repeatInterval == .daily && completionDate <= Date.now) ||
                Calendar.current.isDateInToday(completionDate)) {
                return true
            } else if $0.completionDate == nil && $0.repeatInterval == .daily {
                return true
            } else {
                return false
            }
        }
    }
    
    var tasksTodayNotCompleted: [ListTask] {
        tasks.filter {
            if let completionDate = $0.completionDate,
               (($0.repeatInterval == .daily && completionDate <= Date.now) ||
                Calendar.current.isDateInToday(completionDate)) &&
                !$0.isCompleted {
                return true
            } else if $0.completionDate == nil && $0.repeatInterval == .daily && !$0.isCompleted {
                return true
            } else {
                return false
            }
        }
    }
    
    var otherTasks: [ListTask] {
        tasks.filter {
            if let completionDate = $0.completionDate {
                return !$0.isCompleted && ((!Calendar.current.isDateInToday(completionDate) && $0.repeatInterval == .never) || ($0.repeatInterval == .daily && completionDate > Date.now && !Calendar.current.isDateInToday(completionDate)))
            } else {
                return !$0.isCompleted && $0.repeatInterval != .daily
            }
        }
    }
    
    var completedTasks: [ListTask] {
        tasks.filter { $0.isCompleted }
    }
}

enum TaskFilter: String, CaseIterable {
    case todayNotCompleted = "Today"
    case other = "Other"
    case completed = "Completed"
}

// MARK: Search

extension TakeCareList {
    func matches(_ string: String) -> Bool {
        string.isEmpty ||
        name.localizedCaseInsensitiveContains(string)
    }
}
