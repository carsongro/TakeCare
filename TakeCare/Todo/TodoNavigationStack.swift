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
                    if let list = todoModel.lists.first(where: { $0.id == takeCareListID.id }) {
                        TodoDetailView(list: list)
                    }
                }
        }
    }
}

#Preview {
    TodoNavigationStack()
}
