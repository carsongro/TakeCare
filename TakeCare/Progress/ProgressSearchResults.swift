//
//  ProgressSearchResults.swift
//  TakeCare
//
//  Created by Carson Gross on 10/21/23.
//

import SwiftUI

struct ProgressSearchResults: View {
    @Environment(ProgressModel.self) private var progressModel
    
    var listedLists: [TakeCareList] {
        progressModel.lists
            .filter { $0.matches(progressModel.searchText) }
            .sorted(by: { $0.name.localizedCompare($1.name) == .orderedAscending })
    }
    
    var body: some View {
        ForEach(listedLists, id: \.self) { list in
            NavigationLink(value: list) {
                HStack {
                    ListRow(list: list, showingInfoIndicator: false)
                    
                    Spacer(minLength: 0)
                    
                    ListIndicator(isCompleted: list.tasks.allSatisfy({ $0.isCompleted }))
                }
            }
        }
        
        if listedLists.isEmpty && !progressModel.searchText.isEmpty {
            ContentUnavailableView("No lists in progress found", systemImage: "magnifyingglass")
                .listRowSeparator(.hidden)
                .listRowBackground(Color(.systemBackground))
        }
    }
    
    struct ListIndicator: View {
        let isCompleted: Bool
        
        var body: some View {
            Image(systemName: isCompleted ? "checkmark.circle" : "checklist")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 22, height: 22)
                .padding(.leading, 8)
                .foregroundStyle(isCompleted ? .green : .accentColor)
        }
    }
}

#Preview {
    ProgressSearchResults()
        .environment(ProgressModel())
}
