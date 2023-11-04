//
//  ListDetailForm.swift
//  TakeCare
//
//  Created by Carson Gross on 10/4/23.
//

import PhotosUI
import SwiftUI

struct ListDetailView: View, @unchecked Sendable {
    @Environment(ListsModel.self) private var listsModel
    @Environment(\.dismiss) private var dismiss
    
    enum ListDetailMode {
        case create
        case edit
    }
    
    enum Field {
        case name
        case description
    }
    
    @FocusState private var focusedField: Field?
    
    var mode: ListDetailMode
    var list: TakeCareList?
    
    @State private var name = ""
    @State private var description = ""
    @State private var recipient: User?
    @State private var tasks = [ListTask]()
    @State private var listImage: UIImage?
    @State private var selectedTask: ListTask?
    
    @State private var showingErrorAlert = false
    @State private var showingDeleteAlert = false
    @State private var showingModifyTaskForm = false
    @State private var didChangeImage = false
    @State private var showingDismissDialog = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ListChooseListImageView(listImage: $listImage) {
                        didChangeImage = true
                    }
                    .listRowSeparator(.hidden)
                    
                    TextField("List Name", text: $name)
                        .multilineTextAlignment(.center)
                        .fontWeight(.bold)
                        .padding(.bottom)
                        .focused($focusedField, equals: .name)
                        .submitLabel(.next)
                    
                    TextField("Description", text: $description)
                        .focused($focusedField, equals: .description)
                        .submitLabel(.return)
                        .padding(.bottom)
                }
                .listRowBackground(Color(.systemGroupedBackground))
                
                Section("Recipient") {
                    ListUpdateRecipientButton(recipient: $recipient)
                    
                    if let recipient = recipient {
                        ForEach([recipient]) { recipient in
                            ListRecipientRow(user: recipient)
                        }
                        .onDelete(perform: deleteRecipient)
                    }
                }
                
                Section {
                    ListAddTasksButton(tasks: $tasks)
                    
                    ForEach(tasks, id: \.self) { task in
                        if list?.isActive ?? false {
                            ListTaskRow(task: task)
                        } else {
                            Button {
                                selectedTask = task
                            } label: {
                                ListTaskRow(task: task)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .onDelete(perform: deleteTask)
//                    .onMove(perform: moveTask)
                } header: {
                    Text("Tasks")
                } footer: {
                    if mode == .edit && list?.isActive ?? true {
                        Text("Tasks cannot be modified while the list is active. If a new task is added, recipients will not be notified until they open the app after the new task is added")
                    }
                }
                
                Section {
                    if mode == .edit {
                        Button("Delete list", role: .destructive) {
                            showingDeleteAlert = true
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color(.systemGroupedBackground))
            }
            .onSubmit {
                switch focusedField {
                case .name:
                    focusedField = .description
                default:
                    break
                }
            }
            .onChange(of: $selectedTask.wrappedValue, { oldValue, newValue in
                if newValue != nil {
                    showingModifyTaskForm = true
                }
            })
            .sheet(isPresented: $showingModifyTaskForm, onDismiss: {
                selectedTask = nil
            }) {
                ListTaskDetailView(
                    tasks: $tasks,
                    selectedTask: $selectedTask,
                    mode: .edit
                )
            }
            .onAppear(perform: getList)
            .environment(\.editMode, .constant(.active))
            .navigationTitle(mode == .edit ? "Edit List" : "New List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if mode == .edit && listDidChange || listDidChange {
                            showingDismissDialog = true
                        } else {
                            dismiss()
                        }
                    }
                    .confirmationDialog("Are you sure you want to discard your changes?", isPresented: $showingDismissDialog) {
                        Button("Discard Changes", role: .destructive) {
                            dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        Task {
                            dismiss()
                            guard listDidChange else { return }
                            
                            do {
                                switch mode {
                                case .create:
                                    try await listsModel.createList(
                                        name: name,
                                        description: description,
                                        recipient: recipient,
                                        tasks: tasks,
                                        listImage: listImage
                                    )
                                case .edit:
                                    guard let id = list?.id else { return }
                                    try await listsModel.updateList(
                                        id: id,
                                        name: name,
                                        description: description,
                                        recipient: recipient,
                                        tasks: tasks,
                                        listImage: listImage,
                                        isActive: list?.isActive ?? false,
                                        sendInvites: list?.recipient != recipient,
                                        shouldUpdateImage: didChangeImage
                                    )
                                }
                            } catch {
                                showingErrorAlert = true
                            }
                        }
                    }
                    .fontWeight(.semibold)
                    .disabled(name.isEmpty || tasks.isEmpty)
                }
            }
            .alert(
                "Are you sure you want to delete this list",
                isPresented: $showingDeleteAlert
            ) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task {
                        do {
                            guard let list = list else { return }
                            
                            dismiss()
                            try await listsModel.deleteList(list)
                        } catch {
                            showingErrorAlert = true
                        }
                    }
                }
            }
            .alert(
                "An error occured",
                isPresented: $showingErrorAlert
            ) { }
        }
    }
    
    private func deleteRecipient(at offsets: IndexSet) {
        withAnimation {
            recipient = nil
        }
    }
    
    private func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
    
    private func moveTask(fromOffsets: IndexSet, toOffset: Int) {
        tasks.move(fromOffsets: fromOffsets, toOffset: toOffset)
    }
    
    private func getList() {
        if let list = list {
            name = list.name
            description = list.description ?? ""
            recipient = list.recipient ?? nil
            tasks = list.tasks
            if let url = URL(string: list.photoURL ?? "") {
                Task {
                    do {
                        listImage = try await LocalImageManager.fetchImage(url: url)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    private var listDidChange: Bool {
        name != list?.name ||
        description != list?.description ||
        recipient != list?.recipient || 
        tasks != list?.tasks ||
        didChangeImage
    }
}

#Preview {
    ListDetailView(mode: .edit, list: PreviewData.previewTakeCareList)
        .environment(ListsModel())
}
