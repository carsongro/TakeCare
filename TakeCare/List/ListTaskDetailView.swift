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
            .scrollContentBackground(.visible)
            .onChange(of: showingDatePicker) { oldValue, newValue in
                withAnimation {
                    showingDatePickerAnimated = showingDatePicker
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
                        if mode == .edit,
                           let id = selectedTask?.id,
                           let idx = tasks.firstIndex(where: { $0.id == id }) {
                            tasks[idx] = ListTask(
                                id: id,
                                title: title,
                                notes: notes.isEmpty ? nil : notes,
                                completionDate: showingDatePicker ? completionDate : nil,
                                repeatInterval: taskRepeatInterval
                            )
                        } else {
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