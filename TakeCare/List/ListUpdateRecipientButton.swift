//
//  ListUpdateRecipientButton.swift
//  TakeCare
//
//  Created by Carson Gross on 10/6/23.
//

import SwiftUI

struct ListUpdateRecipientButton: View {
    @Binding var recipient: User?
    
    @State private var showingAddPeopleForm = false
    
    var body: some View {
        Button(recipient == nil ? "Add Recipient" : "Change Recipient", systemImage: "person") {
            showingAddPeopleForm = true
        }
        .sheet(isPresented: $showingAddPeopleForm) {
            ListUpdateRecipientForm(recipient: $recipient)
        }
    }
}

#Preview {
    ListUpdateRecipientButton(
        recipient: .constant(
            User(
                id: "",
                displayName: "",
                email: "",
                photoURL: nil
            )
        )
    )
}
