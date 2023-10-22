//
//  ProgressDetailView.swift
//  TakeCare
//
//  Created by Carson Gross on 10/21/23.
//

import SwiftUI

struct ProgressDetailView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var list: TakeCareList
    
    var body: some View {
        List {
            Section {
                ListDetailHeader(list: $list)
            }
            .listRowSeparator(.hidden)
            
            Section("List Progress") {
                ProgressTasksList(list: $list)
            }
        }
        .listStyle(.inset)
        .navigationTitle(list.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ProgressDetailView(list: .constant(PreviewData.previewTakeCareList))
    }
}
