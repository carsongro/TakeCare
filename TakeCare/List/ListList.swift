//
//  ListList.swift
//  TakeCare
//
//  Created by Carson Gross on 10/9/23.
//

import SwiftUI

struct ListList: View {
    @Environment(ListsModel.self) private var listsModel
    @State private var showingCreateListForm = false
    
    var body: some View {
        @Bindable var listsModel = listsModel
        List {
            Section {
                newListButton
                
                if !listsModel.didFetchLists {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .listRowSeparator(.hidden, edges: .bottom)
                        .padding()
                } else {
                    ListSearchResults()
                }
            }
        }
        .refreshable {
            await listsModel.fetchLists(isInitialFetch: true)
        }
        .searchable(text: $listsModel.searchText)
        .listStyle(.plain)
        .sheet(isPresented: $showingCreateListForm) {
            ListOwnerDetailView(mode: .create)
                .environment(listsModel)
        }
    }
    
    var newListButton: some View {
        Button {
            showingCreateListForm = true
        } label: {
            HStack {
                ZStack {
                    Rectangle()
                        .listRowImage()
                        .foregroundStyle(Color(.secondarySystemBackground))
                    
                    Image(systemName: "plus")
                        .resizable()
                        .padding()
                        .frame(width: 60, height: 60)
                        .fontWeight(.light)
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.accent)
                }
                
                Text("New List...")
            }
        }
        .listRowSeparator(.hidden, edges: .top)
        .accessibilityLabel(Text("New List"))
    }
}

#Preview {
    ListList()
        .environment(ListsModel())
}
