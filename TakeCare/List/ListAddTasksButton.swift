//
//  ListAddTasksButton.swift
//  TakeCare
//
//  Created by Carson Gross on 10/6/23.
//

import SwiftUI

struct ListAddTasksButton: View {
    @Binding var tasks: [ListTask]
    
    @State private var showingCreateTaskForm = false
    
    var body: some View {
        Button("Add Task", systemImage: "plus.circle.fill") {
            showingCreateTaskForm = true
        }
        .sheet(isPresented: $showingCreateTaskForm) {
            ListTaskDetailView(
                tasks: $tasks,
                selectedTask: .constant(nil),
                mode: .create
            )
        }
    }
}

#Preview {
    ListAddTasksButton(
        tasks: .constant([])
    )
}
