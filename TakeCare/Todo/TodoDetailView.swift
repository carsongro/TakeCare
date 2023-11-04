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
    
    var body: some View {
        List {
            Section {
                ListDetailHeader(list: $list)
            }
            .listRowSeparator(.hidden)
            
            Section("Tasks") {
                TodoTasksList(list: $list)
                    .environment(todoModel)
            }
            
            Section {
                activeButton
                    .listRowSeparator(.hidden)
            } header: {
                Text("List Status")
            }
        }
        .listStyle(.inset)
        .navigationTitle(list.name)
        .navigationBarTitleDisplayMode(.inline)
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
