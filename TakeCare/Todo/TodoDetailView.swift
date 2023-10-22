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
        }
        .listStyle(.inset)
        .navigationTitle(list.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        TodoDetailView(list: .constant(PreviewData.previewTakeCareList))
            .environment(TodoModel())
    }
}
