//
//  TodoDetailView.swift
//  TakeCare
//
//  Created by Carson Gross on 10/14/23.
//

import SwiftUI

struct TodoDetailView: View {
    @Environment(TodoModel.self) private var todoModel
    @Environment(\.dismiss) private var dismiss
    
    @Binding var list: TakeCareList
    
    @State private var showingErrorAlert = false
    @State private var showingRemoveAlert = false
    @State private var selectedUserId: String? = nil
    @State private var showUsersheet = false
    @State private var hasRecipientTaskNotifications: Bool
    
    init(list: Binding<TakeCareList>, hasRecipientTaskNotifications: Bool) {
        _list = list
        _hasRecipientTaskNotifications = State(initialValue: hasRecipientTaskNotifications)
    }
    
    var body: some View {
        GeometryReader { proxy in
            List {
                Section {
                    ListDetailHeader(list: $list, width: proxy.size.width)
                }
                .listRowSeparator(.hidden)
                
                ForEach(TaskFilter.allCases, id: \.self) { filter in
                    TodoTasksList(list: $list, taskFilter: filter) { task, isCompleted in
                        Task {
                            do {
                                try todoModel.updateListTask(
                                    list: list,
                                    task: task,
                                    isCompleted: isCompleted
                                )
                                await todoModel.fetchLists(animated: true)
                            } catch {
                                showingErrorAlert = true
                            }
                        }
                    }
                }
            }
            .sensoryFeedback(.impact, trigger: hasRecipientTaskNotifications)
            .listStyle(.plain)
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                todoModel.refresh()
            }
            .toolbar {
                Button {
                    hasRecipientTaskNotifications.toggle()
                    todoModel.updateListActive(hasRecipientTaskNotifications: hasRecipientTaskNotifications, list: list)
                } label: {
                    Label("Notifcations", systemImage: hasRecipientTaskNotifications ? "bell.fill" : "bell.slash.fill")
                }
                
                Menu("Options", systemImage: "ellipsis.circle") {
                    
                    
                    Divider()
                    
                    Button("Remove List", systemImage: "minus.circle", role: .destructive) {
                        showingRemoveAlert = true
                    }
                }
                .accessibilityLabel(Text("More"))
            }
            .alert("Are you sure you want to remove this list from your to do?", isPresented: $showingRemoveAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Remove", role: .destructive) {
                    Task {
                        do {
                            try await todoModel.removeTodoList(list: list)
                            dismiss()
                        } catch {
                            showingErrorAlert = true
                        }
                    }
                }
            }
            .alert("An error occured", isPresented: $showingErrorAlert) { }
        }
    }
}

#Preview {
    NavigationStack {
        TodoDetailView(
            list: .constant(PreviewData.previewTakeCareList),
            hasRecipientTaskNotifications: PreviewData.previewTakeCareList.hasRecipientTaskNotifications
        )
        .environment(TodoModel())
    }
}
