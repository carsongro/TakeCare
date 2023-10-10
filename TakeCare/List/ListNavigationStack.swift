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
        NavigationStack {
            ListList()
                .environment(listsModel)
                .navigationTitle("Lists")
        }
    }
}

#Preview {
    ListNavigationStack()
        .environment(ListsModel())
}
