//
//  ListNavigationStack.swift
//  TakeCare
//
//  Created by Carson Gross on 10/2/23.
//

import SwiftUI

struct ListNavigationStack: View {
    @State private var searchText = ""
    @Environment(ListsModel.self) private var listsModel
    
    @State private var showingCreateListForm = false
    
    var body: some View {
        @Bindable var listsModel = listsModel
        NavigationStack {
            List {
                Section {
                    Button("New List...", systemImage: "plus") {
                        showingCreateListForm = true
                    }
                    .frame(height: 60)
                    .listRowSeparator(.hidden, edges: .top)
                    .listRowBackground(Color(.systemBackground))
                    
                    ForEach(listsModel.lists, id: \.self) { list in
                        NavigationLink {
                            ListView(list: list)
                        } label: {
                            ListRow(list: list)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Lists")
            .listStyle(.grouped)
            .searchable(text: $searchText) // TODO: Implement this
            .sheet(isPresented: $showingCreateListForm) {
                ListCreateListForm()
                    .environment(listsModel)
            }
        }
    }
}

#Preview {
    ListNavigationStack()
        .environment(ListsModel())
}