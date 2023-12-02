//
//  TodoTasksList.swift
//  TakeCare
//
//  Created by Carson Gross on 10/16/23.
//

import SwiftUI

struct TodoTasksList: View {
    @Binding var list: TakeCareList
    
    var taskFilter: TaskFilter
    var interactionDisabled: Bool = false
    var tapHandler: ((ListTask, Bool) -> Void)? = nil
    
    private var filteredTasks: [ListTask] {
        var tasks = list.tasks
        
        switch taskFilter {
        case .todayNotCompleted:
            tasks = list.tasks.filter {
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
        case .other:
            tasks = list.tasks.filter {
                if let completionDate = $0.completionDate {
                    return !$0.isCompleted && ((!Calendar.current.isDateInToday(completionDate) && $0.repeatInterval == .never) || ($0.repeatInterval == .daily && completionDate > Date.now))
                } else {
                    return !$0.isCompleted && $0.repeatInterval != .daily
                }
            }
        case .completed:
            tasks = list.tasks.filter { $0.isCompleted }
        }
        
        return tasks.sorted {
            // Sort by the time of day so that daily notifications aren't always first
            // If only one has a completion date, show the one with a completion date
            // Otherwise sort by title
            if let completionDate1 = $0.completionDate,
               let completionDate2 = $1.completionDate {
                return completionDate1.comparableTime < completionDate2.comparableTime
            } else if $0.completionDate == nil {
                return $1.completionDate != nil
            } else if $1.completionDate == nil {
                return $0.completionDate != nil
            } else {
                return $0.title < $1.title
            }
        }
    }
    
    var body: some View {
        if !filteredTasks.isEmpty {
            Section {
                ForEach(filteredTasks, id: \.self) { task in
                    TodoTaskRow(
                        task: task,
                        isCompleted: task.isCompleted,
                        interactionDisabled: interactionDisabled
                    ) { isCompleted in
                        tapHandler?(task, isCompleted)
                    }
                }
            } header: {
                Text(taskFilter.rawValue)
                    .accessibilityLabel(sectionHeaderAccessibilityLabel(taskFilter))
            }
        }
    }
    
    private func sectionHeaderAccessibilityLabel(_ taskFilter: TaskFilter) -> Text {
        switch taskFilter {
        case .todayNotCompleted:
            return Text("Today's tasks not completed")
        case .other:
            return Text("Other tasks")
        case .completed:
            return Text("Completed tasks")
        }
    }
}

enum TaskFilter: String, CaseIterable {
    case todayNotCompleted = "Today"
    case other = "Other"
    case completed = "Completed"
}

#Preview {
    TodoTasksList(list: .constant(PreviewData.previewTakeCareList), taskFilter: .completed)
}
