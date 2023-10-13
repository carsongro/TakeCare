//
//  ListTask.swift
//  TakeCare
//
//  Created by Carson Gross on 10/4/23.
//

import Firebase
import FirebaseFirestoreSwift
import Foundation

struct ListTask: Codable, Hashable, Equatable {
    let id: String
    let title: String
    let notes: String?
    let completionDate: Date?
    let repeatInterval: TaskRepeatInterval
}

enum TaskRepeatInterval: String, CaseIterable, Codable {
    case never = "Never"
    case daily = "Daily"
    case weekly = "Weekly"
    case everyOtherDay = "Every other day"
}
