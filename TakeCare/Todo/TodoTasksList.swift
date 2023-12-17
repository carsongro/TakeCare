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
            tasks = list.tasksTodayNotCompleted
        case .other:
            tasks = list.otherTasks
        case .completed:
            tasks = list.completedTasks
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

#Preview {
    TodoTasksList(list: .constant(PreviewData.previewTakeCareList), taskFilter: .completed)
}
