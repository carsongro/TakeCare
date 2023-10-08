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
    @State private var showingDatePicker = false
    @State private var showingDatePickerAnimated = false
    
    @State private var title = ""
    @State private var notes = ""
    @State private var completionDate = Date()
    @State private var taskRepeatInterval: TaskRepeatInterval = .never
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $title)
                    TextField("Notes", text: $notes)
                }
                
                Section {
                    Toggle("Date", systemImage: "calendar", isOn: $showingDatePicker)
                    if showingDatePickerAnimated {
                        DatePicker(
                            "Start Date",
                            selection: $completionDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.graphical)
                    }
                }
                
                if showingDatePickerAnimated {
                    Section {
                        Picker("Repeat", systemImage: "repeat", selection: $taskRepeatInterval) {
                            ForEach(TaskRepeatInterval.allCases, id: \.self) { interval in
                                Text(interval.rawValue).tag(interval)
                            }
                        }
                    }
                    .listRowBackground(Color(.systemGroupedBackground))
                }
            }
            .scrollContentBackground(.visible)
            .onChange(of: showingDatePicker) { oldValue, newValue in
                withAnimation {
                    showingDatePickerAnimated = showingDatePicker
                }
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
                            id: UUID().uuidString,
                            title: title,
                            notes: notes.isEmpty ? nil : notes,
                            completionDate: showingDatePicker ? completionDate : nil,
                            repeatInterval: taskRepeatInterval
                        )
                        
                        guard !tasks.contains(newTask) else {
                            showingDuplicateTaskAlert = true
                            return
                        }
                        
                        tasks.append(newTask)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
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
