//
//  ListAddRecipientButton.swift
//  TakeCare
//
//  Created by Carson Gross on 10/6/23.
//

import SwiftUI

struct ListAddRecipientButton: View {
    @Binding var recipients: [User]
    
    @State private var showingAddPeopleForm = false
    
    var body: some View {
        Button("Add People", systemImage: "person.2") {
            showingAddPeopleForm = true
        }
        .sheet(isPresented: $showingAddPeopleForm) {
            ListAddRecipientForm(recipients: $recipients)
        }
    }
}

#Preview {
    ListAddRecipientButton(recipients: .constant([]))
}
