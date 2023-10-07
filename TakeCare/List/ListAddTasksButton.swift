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
        Button("Add Tasks", systemImage: "plus.circle.fill") {
            showingCreateTaskForm = true
        }
        .sheet(isPresented: $showingCreateTaskForm) {
            ListCreateTaskForm(tasks: $tasks)
        }
    }
}

#Preview {
    ListAddTasksButton(
        tasks: .constant([])
    )
}
