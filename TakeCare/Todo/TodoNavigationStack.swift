//
//  TodoNavigationStack.swift
//  TakeCare
//
//  Created by Carson Gross on 10/2/23.
//

import SwiftUI

struct TodoNavigationStack: View {
    @State private var todoModel = TodoModel()
    
    var body: some View {
        NavigationStack {
            TodoLists()
                .environment(todoModel)
                .navigationTitle("Todo")
                .navigationDestination(for: TakeCareList.self) { takeCareListID in
                    if let index = todoModel.lists.firstIndex(where: { $0.id == takeCareListID.id }) {
                        TodoDetailView(list: $todoModel.lists[index])
                            .environment(todoModel)
                    }
                }
        }
    }
}

#Preview {
    TodoNavigationStack()
}
