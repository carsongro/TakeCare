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
    
    var body: some View {
        ForEach(list.tasks) { task in
            TodoTaskRow(task: task, isCompleted: task.isCompleted) { isCompleted in
                Task {
                    try todoModel.updateListTask(list: list, task: task, isCompleted: isCompleted)
                    await todoModel.fetchLists()
                }
            }
        }
        .id(UUID())
        .alert("There was an error modifying the task", isPresented: $showingErrorAlert) { }
    }
}

#Preview {
    TodoTasksList(list: .constant(PreviewData.previewTakeCareList))
        .environment(TodoModel())
}
