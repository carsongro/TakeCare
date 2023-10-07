//
//  ListCreateTaskForm.swift
//  TakeCare
//
//  Created by Carson Gross on 10/6/23.
//

import SwiftUI

struct ListCreateTaskForm: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var tasks: [ListTask]
    
    @State private var showingDuplicateTaskAlert = false
    
    @State private var name = ""
    @State private var notes: String?
    @State private var completionDate: Date?
    
    var body: some View {
        NavigationStack {
            Form {
                
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        let newTask = ListTask(
                            name: name,
                            notes: notes,
                            completionDate: completionDate
                        )
                        
                        guard !tasks.contains(newTask) else {
                            showingDuplicateTaskAlert = true
                            return
                        }
                        
                        tasks.append(newTask)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                    .fontWeight(.semibold)
                }
            }
            .alert("You have already added this task to the list", isPresented: $showingDuplicateTaskAlert) {
                Button("OK") { }
            }
        }
    }
}

#Preview {
    ListCreateTaskForm(tasks: .constant([]))
}
