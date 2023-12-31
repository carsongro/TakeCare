//
//  TodoNavigationStack.swift
//  TakeCare
//
//  Created by Carson Gross on 10/2/23.
//

import SwiftUI
import IoImage

struct TodoNavigationStack: View {
    @Environment(TodoModel.self) private var todoModel
    @Environment(Navigator.self) private var navigator
    @Environment(\.prefersTabNavigation) private var prefersTabNavigation
    
    @State private var showingProfile = false
    
    var body: some View {
        @Bindable var navigator = navigator
        @Bindable var todoModel = todoModel
        
        NavigationStack(path: $navigator.todoPath) {
            TodoLists()
                .environment(todoModel)
                .navigationTitle("To Do")
                .navigationDestination(for: TakeCareList.self) { takeCareList in
                    if let index = todoModel.lists.firstIndex(where: { $0.id == takeCareList.id }) {
                        TodoDetailView(
                            list: todoModel.lists[index],
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
                            IoImageView(url: URL(string: AuthModel.shared.currentUser?.photoURL ?? ""))
                                .resizable()
                                .placeholder {
                                    Image(systemName: "person.crop.circle")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 35, height: 35)
                                        .fontWeight(.semibold)
                                }
                                .clipShape(Circle())
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 35, height: 35)
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
