//
//  ListCreateListForm.swift
//  TakeCare
//
//  Created by Carson Gross on 10/4/23.
//

import PhotosUI
import SwiftUI

struct ListCreateListForm: View, @unchecked Sendable {
    @Environment(ListsModel.self) private var listsModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var description = ""
    @State private var recipient: User?
    @State private var tasks = [ListTask]()
    @State private var listImage: UIImage?
    
    @State private var showingErrorAlert = false
    
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
                    
                    ListAddRecipientButton(recipient: $recipient)
                    
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
            }
            .environment(\.editMode, .constant(.active))
            .scrollContentBackground(.hidden)
            .listStyle(.grouped)
            .navigationTitle("New List")
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
                            do {
                                try await listsModel.createList(
                                    name: name,
                                    description: description,
                                    recipient: recipient,
                                    tasks: tasks,
                                    listImage: listImage
                                )
                            } catch {
                                showingErrorAlert = true
                            }
                            dismiss()
                        }
                    }
                    .fontWeight(.semibold)
                    .disabled(name.isEmpty || tasks.isEmpty)
                }
            }
            .alert(
                "There was an error creating a new list",
                isPresented: $showingErrorAlert) {
                    Button("OK") {
                        
                    }
                }
        }
    }
    
    private func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
    
    private func moveTask(fromOffsets: IndexSet, toOffset: Int) {
        tasks.move(fromOffsets: fromOffsets, toOffset: toOffset)
    }
}

#Preview {
    ListCreateListForm()
        .environment(ListsModel())
}
