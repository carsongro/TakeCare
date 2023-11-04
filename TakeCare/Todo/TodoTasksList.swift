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
    
    enum TaskFilter {
        case todayNotCompleted
        case other
        case completed
    }
    
    var taskFilter: TaskFilter
    
    var filteredTasks: [ListTask] {
        switch taskFilter {
        case .todayNotCompleted:
            return list.tasks.filter {
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
            return list.tasks.filter { !$0.isCompleted && $0.completionDate == nil }
        case .completed:
            return list.tasks.filter { $0.isCompleted }
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
                        todoModel.refresh(animated: true)
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
