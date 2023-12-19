//
//  TodoNavigationStack.swift
//  TakeCare
//
//  Created by Carson Gross on 10/2/23.
//

import SwiftUI

struct TodoNavigationStack: View {
    @Environment(TodoModel.self) private var todoModel
    @Environment(\.prefersTabNavigation) private var prefersTabNavigation
    
    @State private var showingProfile = false
    
    var body: some View {
        @Bindable var navigator = Navigator.shared
        @Bindable var todoModel = todoModel
        
        NavigationStack(path: $navigator.todoPath) {
            TodoLists()
                .environment(todoModel)
                .navigationTitle("To Do")
                .navigationDestination(for: TakeCareList.self) { takeCareList in
                    if let index = todoModel.lists.firstIndex(where: { $0.id == takeCareList.id }) {
                        TodoDetailView(
                            list: $todoModel.lists[index],
                            hasRecipientTaskNotifications: todoModel.lists[index].hasRecipientTaskNotifications
                        )
                        .environment(todoModel)
                    }
                }
                .toolbar {
                    if prefersTabNavigation {
                        Button {
                            showingProfile = true
                        } label: {
                            Image(systemName: "person.crop.circle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                                .fontWeight(.semibold)
                        }
                        .accessibilityLabel(Text("View Profile"))
                    }
                }
                .sheet(isPresented: $showingProfile) {
                    AccountNavigationStack()
                        .environment(AuthModel.shared)
                }
        }
    }
}

#Preview {
    TodoNavigationStack()
        .environment(TodoModel())
}
