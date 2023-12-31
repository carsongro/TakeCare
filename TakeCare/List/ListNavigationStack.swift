//
//  ListNavigationStack.swift
//  TakeCare
//
//  Created by Carson Gross on 10/2/23.
//

import SwiftUI
import IoImage

struct ListNavigationStack: View, @unchecked Sendable {
    @Environment(ListsModel.self) private var listsModel
    @Environment(Navigator.self) private var navigator
    @Environment(\.prefersTabNavigation) private var prefersTabNavigation
    
    @State private var showingProfile = false
    
    var body: some View {
        @Bindable var navigator = navigator
        @Bindable var listsModel = listsModel
        
        NavigationStack(path: $navigator.listsPath) {
            ListList()
                .environment(listsModel)
                .navigationTitle("Lists")
                .navigationDestination(for: TakeCareList.self) { list in
                    if let index = listsModel.lists.firstIndex(where: { $0.id == list.id }) {
                        ListProgressDetailView(list: listsModel.lists[index])
                            .environment(listsModel)
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
    ListNavigationStack()
        .environment(ListsModel())
}
