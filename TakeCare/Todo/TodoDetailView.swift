//
//  TodoDetailView.swift
//  TakeCare
//
//  Created by Carson Gross on 10/14/23.
//

import SwiftUI

struct TodoDetailView: View {
    @Environment(TodoModel.self) private var todoModel
    
    @Binding var list: TakeCareList
    
    @State private var showingErrorAlert = false
    
    var body: some View {
        List {
            Section {
                ListDetailHeader(list: $list)
            }
            .listRowSeparator(.hidden)
            
            ForEach(TaskFilter.allCases, id: \.self) { filter in
                TodoTasksList(list: $list, taskFilter: filter) { task, isCompleted in
                    Task {
                        do {
                            try todoModel.updateListTask(list: list, task: task, isCompleted: isCompleted)
                            await todoModel.fetchLists(animated: true)
                        } catch {
                            showingErrorAlert = true
                        }
                    }
                }
            }
            
            Section {
                activeButton
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .navigationTitle(list.name)
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            todoModel.refresh()
        }
        .alert("There was an error modifying the task", isPresented: $showingErrorAlert) { }
    }
    
    @ViewBuilder
    var activeButton: some View {
        HStack {
            if list.isActive {
                Button("Make inactive") {
                    todoModel.updateListActive(isActive: false, list: list)
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button("Make active") {
                    todoModel.updateListActive(isActive: true, list: list)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .sensoryFeedback(.success, trigger: list.isActive)
        .frame(maxWidth: .infinity)
        .padding(.vertical)
    
    }
}

#Preview {
    NavigationStack {
        TodoDetailView(list: .constant(PreviewData.previewTakeCareList))
            .environment(TodoModel())
    }
}
