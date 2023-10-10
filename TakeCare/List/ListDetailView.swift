//
//  ListDetailForm.swift
//  TakeCare
//
//  Created by Carson Gross on 10/4/23.
//

import PhotosUI
import SwiftUI
import Kingfisher

struct ListDetailView: View, @unchecked Sendable {
    @Environment(ListsModel.self) private var listsModel
    @Environment(\.dismiss) private var dismiss
    
    enum ListDetailMode {
        case create
        case edit
    }
    
    var mode: ListDetailMode
    var list: TakeCareList?

    @State private var name = ""
    @State private var description = ""
    @State private var recipient: User?
    @State private var tasks = [ListTask]()
    @State private var listImage: UIImage?
    
    @State private var showingErrorAlert = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ListChooseListImageView(listImage: $listImage)
                        .listRowSeparator(.hidden, edges: [.bottom, .top])
                    
                    TextField("List Name", text: $name)
                        .multilineTextAlignment(.center)
                        .fontWeight(.bold)
                        .padding(.bottom)
                    
                    TextField("Description", text: $description)
                        .padding(.bottom)
                    
                    ListUpdateRecipientButton(recipient: $recipient)
                    
                    if let recipient = recipient {
                        ListRecipientRow(user: recipient)
                    }
                    
                    ListAddTasksButton(tasks: $tasks)
                    
                    ForEach(tasks, id: \.self) { task in
                        ListTaskRow(task: task)
                    }
                    .onDelete(perform: deleteTask)
                    .onMove(perform: moveTask)
                }
                .listRowBackground(Color(.systemBackground))
                
                Section {
                    if mode == .edit {
                        Button("Delete list", role: .destructive) {
                            showingDeleteAlert = true
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity)
                    }
                }
                .listRowBackground(Color(.systemBackground))
                .listRowSeparator(.hidden)
            }
            .onAppear(perform: getList)
            .environment(\.editMode, .constant(.active))
            .scrollContentBackground(.hidden)
            .listStyle(.grouped)
            .navigationTitle(mode == .edit ? "Edit List" : "New List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        Task {
                            dismiss()
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
                                    guard let id = list?.id, let ownerID = list?.ownerID else { return }
                                    try await listsModel.updateList(
                                        id: id,
                                        name: name,
                                        description: description,
                                        recipient: recipient,
                                        tasks: tasks,
                                        listImage: listImage,
                                        isActive: list?.isActive ?? false,
                                        sendInvites: list?.recipient != recipient
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
                if ImageCache.default.isCached(forKey: url.absoluteString) {
                    ImageCache.default.retrieveImage(forKey: url.absoluteString) { result in
                        switch result {
                        case .success(let image):
                            guard let cgImage = image.image?.cgImage else { return }
                            listImage = UIImage(cgImage: cgImage)
                        case .failure:
                            KingfisherManager.shared.downloader.downloadImage(with: url) { result in
                                switch result {
                                case .success(let image):
                                    guard let cgImage = image.image.cgImage else { return }
                                    listImage = UIImage(cgImage: cgImage)
                                case .failure(let error):
                                    print(error.localizedDescription)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ListDetailView(mode: .edit)
        .environment(ListsModel())
}
