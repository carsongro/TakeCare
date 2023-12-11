//
//  TodoNavigationStack.swift
//  TakeCare
//
//  Created by Carson Gross on 10/2/23.
//

import SwiftUI

struct TodoNavigationStack: View {
    @Environment(TodoModel.self) private var todoModel
    
    var body: some View {
        @Bindable var navigator = Navigator.shared
        @Bindable var todoModel = todoModel
        
        NavigationStack(path: $navigator.todoPath) {
            TodoLists()
                .environment(todoModel)
                .navigationTitle("To Do")
                .navigationDestination(for: TakeCareList.self) { takeCareList in
                    if let index = todoModel.lists.firstIndex(where: { $0.id == takeCareList.id }) {
                        TodoDetailView(list: $todoModel.lists[index])
                            .environment(todoModel)
                    }
                }
        }
    }
}

#Preview {
    TodoNavigationStack()
        .environment(TodoModel())
}
