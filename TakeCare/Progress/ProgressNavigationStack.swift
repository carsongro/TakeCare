//
//  ProgressNavigationStack.swift
//  TakeCare
//
//  Created by Carson Gross on 10/21/23.
//

import SwiftUI

struct ProgressNavigationStack: View {
    @State private var progressModel = ProgressModel()
    
    var body: some View {
        NavigationStack {
            ProgressLists()
                .environment(progressModel)
                .navigationTitle("In Progress")
                .navigationDestination(for: TakeCareList.self) { takeCareList in
                    if let index = progressModel.lists.firstIndex(where: { $0.id == takeCareList.id }) {
                        ProgressDetailView(list: $progressModel.lists[index])
                            .refreshable {
                                await progressModel.fetchLists()
                            }
                    } else {
                        // Generally only here if the user deleted the list
                        ContentUnavailableView(
                            "List not found",
                            systemImage: "list.bullet",
                            description: Text("This list can no longer be found.")
                        )
                    }
                }
        }
    }
}

#Preview {
    ProgressNavigationStack()
}
