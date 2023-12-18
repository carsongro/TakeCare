//
//  ListNavigationStack.swift
//  TakeCare
//
//  Created by Carson Gross on 10/2/23.
//

import SwiftUI

struct ListNavigationStack: View, @unchecked Sendable {
    @Environment(ListsModel.self) private var listsModel

    var body: some View {
        @Bindable var navigator = Navigator.shared
        @Bindable var listsModel = listsModel
        
        NavigationStack(path: $navigator.listsPath) {
            ListList()
                .environment(listsModel)
                .navigationTitle("Lists")
                .navigationDestination(for: TakeCareList.self) { list in
                    if let index = listsModel.lists.firstIndex(where: { $0.id == list.id }) {
                        ListProgressDetailView(list: $listsModel.lists[index])
                            .environment(listsModel)
                    }
                }
        }
    }
}

#Preview {
    ListNavigationStack()
        .environment(ListsModel())
}
