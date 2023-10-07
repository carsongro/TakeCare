//
//  ListAddRecipientForm.swift
//  TakeCare
//
//  Created by Carson Gross on 10/6/23.
//

import SwiftUI

struct ListAddRecipientForm: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var recipients: [User]
    
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            Form {
                
            }
            .searchable(text: $searchText, prompt: "Enter the recipients email address")
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ListAddRecipientForm(recipients: .constant([]))
}
