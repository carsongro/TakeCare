//
//  ListTask.swift
//  TakeCare
//
//  Created by Carson Gross on 10/4/23.
//

import Firebase
import FirebaseFirestoreSwift
import Foundation

struct ListTask: Codable, Hashable, Equatable, Identifiable {
    let id: String
    let title: String
    let notes: String?
    let completionDate: Date?
    let repeatInterval: TaskRepeatInterval
    let isCompleted: Bool
    let lastCompletionDate: Date?
}

enum TaskRepeatInterval: String, CaseIterable, Codable {
    case never = "Never"
    case daily = "Daily"
}
