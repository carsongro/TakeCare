//
//  ListTaskDetailView.swift
//  TakeCare
//
//  Created by Carson Gross on 10/6/23.
//

import SwiftUI

struct ListTaskDetailView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var tasks: [ListTask]
    
    @Binding var selectedTask: ListTask?
    
    enum Mode {
        case edit
        case create
    }
    
    var mode: Mode
    
    enum Field {
        case title
        case notes
    }
    
    @FocusState private var focusedField: Field?
    
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
                        .focused($focusedField, equals: .title)
                        .submitLabel(.next)
                    TextField("Notes", text: $notes)
                        .focused($focusedField, equals: .notes)
                        .submitLabel(.return)
                }
                
                Section {
                    Toggle("Date", systemImage: "calendar", isOn: $showingDatePicker)
                    if showingDatePickerAnimated {
                        DatePicker(
                            "Start Date",
                            selection: $completionDate,
                            in: Date()...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.graphical)
                    }
                } footer: {
                    Text("Date is in the current timezone.")
                }
                .onChange(of: showingDatePicker) { _, _ in
                    withAnimation {
                        showingDatePickerAnimated = showingDatePicker
                    }
                }
                
                Section {
                    Picker("Repeat", systemImage: "repeat", selection: $taskRepeatInterval) {
                        ForEach(TaskRepeatInterval.allCases, id: \.self) { interval in
                            Text(interval.rawValue).tag(interval)
                        }
                    }
                } footer: {
                    Text("Recipients will not receive notifications for tasks that repeat daily but do not have a start date.")
                }
            }
            .onSubmit {
                switch focusedField {
                case .title:
                    focusedField = .notes
                default:
                    break
                }
            }
            .onAppear {
                if mode == .edit, let selectedTask = selectedTask {
                    title = selectedTask.title
                    notes = selectedTask.notes ?? ""
                    
                    if let completionDate = selectedTask.completionDate {
                        self.completionDate = completionDate
                        showingDatePicker = true
                        showingDatePickerAnimated = true
                        taskRepeatInterval = selectedTask.repeatInterval
                    }
                }
            }
            .navigationTitle(mode == .create ? "New Task" : "Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        switch mode {
                        case .edit:
                            if let id = selectedTask?.id,
                               let idx = tasks.firstIndex(where: { $0.id == id }) {
                                tasks[idx] = ListTask(
                                    id: UUID().uuidString,
                                    title: title,
                                    notes: notes.isEmpty ? nil : notes,
                                    completionDate: showingDatePicker ? completionDate : nil,
                                    repeatInterval: taskRepeatInterval,
                                    isCompleted: false,
                                    lastCompletionDate: selectedTask?.lastCompletionDate
                                )
                            }
                        case .create:
                            let newTask = ListTask(
                                id: UUID().uuidString,
                                title: title,
                                notes: notes.isEmpty ? nil : notes,
                                completionDate: showingDatePicker ? completionDate : nil,
                                repeatInterval: taskRepeatInterval,
                                isCompleted: false,
                                lastCompletionDate: nil
                            )
                            
                            guard !tasks.contains(newTask) else {
                                showingDuplicateTaskAlert = true
                                return
                            }
                            
                            tasks.append(newTask)
                            
                            let sortedTasks = tasks.sorted {
                                if let completionDate1 = $0.completionDate,
                                   let completionDate2 = $1.completionDate {
                                    return completionDate1 < completionDate2
                                } else {
                                    return $0.title < $1.title
                                }
                            }
                            
                            tasks = sortedTasks
                        }
                        
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                    .fontWeight(.semibold)
                }
            }
            .alert("You have already added this task to the list", isPresented: $showingDuplicateTaskAlert) { }
        }
    }
}

#Preview {
    ListTaskDetailView(
        tasks: .constant([]),
        selectedTask: .constant(PreviewData.previewListTask),
        mode: .edit
    )
}
