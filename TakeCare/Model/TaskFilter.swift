//
//  TaskFilter.swift
//  TakeCare
//
//  Created by Carson Gross on 11/4/23.
//

import Foundation

enum TaskFilter: String, CaseIterable {
    case todayNotCompleted = "Today"
    case other = "Other"
    case completed = "Completed"
}
