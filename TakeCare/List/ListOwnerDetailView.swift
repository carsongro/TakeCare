//
//  ListDetailForm.swift
//  TakeCare
//
//  Created by Carson Gross on 10/4/23.
//

import PhotosUI
import SwiftUI
import Kingfisher

struct ListOwnerDetailView: View, @unchecked Sendable {
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
    @State private var listImage: Image?
    @State private var selectedTask: ListTask?
    
    @State private var showingErrorAlert = false
    @State private var showingModifyTaskForm = false
    @State private var didChangeImage = false
    @State private var showingDismissDialog = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                List {
                    Section {
                        ListChooseListImageView(listImage: $listImage, width: proxy.size.width) {
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
                    
                    Section {
                        ListUpdateRecipientButton(recipient: $recipient)
                        
                        if let recipient = recipient {
                            ForEach([recipient]) { recipient in
                                ListRecipientRow(user: recipient)
                            }
                            .onDelete(perform: deleteRecipient)
                        }
                    } header: {
                        Text("Recipient")
                    } footer: {
                        if mode == .edit && list?.isActive ?? true {
                            Text("If a recipient is removed or changed while the list is active, the recipient will continue to receive notifications for the tasks until the next time they open the app.")
                        }
                    }
                    
                    Section {
                        ListAddTasksButton(tasks: $tasks)
                        
                        ForEach(tasks, id: \.self) { task in
                            Button {
                                selectedTask = task
                            } label: {
                                ListTaskRow(task: task)
                            }
                            .buttonStyle(.plain)
                        }
                        .onDelete(perform: deleteTask)
                    } header: {
                        Text("Tasks")
                    } footer: {
                        if mode == .edit && list?.isActive ?? true {
                            Text("If a task is added, deleted, or modified, the recipient will not receive updated notifications until the next time they open the app.")
                        }
                    }
                }
                .interactiveDismissDisabled()
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
                            if didChangeList {
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
                                guard didChangeList else { return }
                                
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
                                            sendInvites: list?.recipientID != recipient?.id,
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
                    "An error occured",
                    isPresented: $showingErrorAlert
                ) { }
            }
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
    
    private func getList() {
        if let list = list {
            name = list.name
            description = list.description ?? ""
            Task {
                do {
                    if let url = URL(string: list.photoURL ?? "") {
                        listImage = try await KingfisherManager.shared.retrieveImage(with: url)
                    }
                } catch {
                    
                }
                
                if let recipientID = list.recipientID {
                    recipient = await AuthModel.shared.fetchUser(id: recipientID)
                }
            }
            tasks = list.tasks
        }
    }
    
    private var didChangeList: Bool {
        name != list?.name ?? "" ||
        description != list?.description ?? "" ||
        recipient?.id != list?.recipientID ||
        tasks != list?.tasks ?? [] ||
        didChangeImage
    }
}

#Preview {
    ListOwnerDetailView(mode: .edit, list: PreviewData.previewTakeCareList)
        .environment(ListsModel())
}
