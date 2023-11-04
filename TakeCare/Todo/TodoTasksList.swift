//
//  TodoTasksList.swift
//  TakeCare
//
//  Created by Carson Gross on 10/16/23.
//

import SwiftUI

struct TodoTasksList: View {
    @Environment(TodoModel.self) private var todoModel
    
    @Binding var list: TakeCareList
    
    @State private var showingErrorAlert = false
    
    var taskFilter: TaskFilter
    
    var filteredTasks: [ListTask] {
        var tasks = list.tasks
        
        switch taskFilter {
        case .todayNotCompleted:
            tasks = list.tasks.filter {
                if let completionDate = $0.completionDate,
                   ($0.repeatInterval == .daily ||
                    Calendar.current.isDateInToday(completionDate)) &&
                   !$0.isCompleted {
                    return true
                } else {
                    return false
                }
            }
        case .other:
            tasks = list.tasks.filter {
                if let completionDate = $0.completionDate {
                    return !$0.isCompleted && !Calendar.current.isDateInToday(completionDate) && $0.repeatInterval == .never
                } else {
                    return !$0.isCompleted
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
        ForEach(filteredTasks, id: \.self) { task in
            TodoTaskRow(
                task: task,
                isCompleted: task.isCompleted,
                interactionDisabled: !list.isActive
            ) { isCompleted in
                Task {
                    do {
                        try todoModel.updateListTask(list: list, task: task, isCompleted: isCompleted)
                        await todoModel.fetchLists(animated: true)
                    } catch {
                        showingErrorAlert = true
                    }
                }
            }
        }
        .alert("There was an error modifying the task", isPresented: $showingErrorAlert) { }
    }
}

#Preview {
    TodoTasksList(list: .constant(PreviewData.previewTakeCareList), taskFilter: .completed)
        .environment(TodoModel())
}
