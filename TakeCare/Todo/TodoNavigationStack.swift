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
        NavigationStack {
            TodoLists()
                .environment(todoModel)
                .navigationTitle("Todo")
        }
    }
}

#Preview {
    TodoNavigationStack()
        .environment(TodoModel())
}
