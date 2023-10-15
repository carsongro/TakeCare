//
//  TodoLists.swift
//  TakeCare
//
//  Created by Carson Gross on 10/14/23.
//

import SwiftUI

struct TodoLists: View {
    @Environment(TodoModel.self) private var todoModel
    
    var body: some View {
        List {
            Section {
                if !todoModel.didFetchLists {
                    Section {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .listRowSeparator(.hidden, edges: .bottom)
                            .padding()
                    }
                } else {
                    TodoSearchResults()
                }
            }
            .listRowBackground(Color(.systemBackground))
        }
        .listStyle(.grouped)
        .refreshable {
            await todoModel.fetchLists()
        }
    }
}

#Preview {
    TodoLists()
}
