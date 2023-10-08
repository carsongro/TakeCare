//
//  ListAddRecipientButton.swift
//  TakeCare
//
//  Created by Carson Gross on 10/6/23.
//

import SwiftUI

struct ListAddRecipientButton: View {
    @Binding var recipient: User?
    
    @State private var showingAddPeopleForm = false
    
    var body: some View {
        Button(recipient == nil ? "Add Recipient" : "Change Recipient", systemImage: "person") {
            showingAddPeopleForm = true
        }
        .sheet(isPresented: $showingAddPeopleForm) {
            ListAddRecipientForm(recipient: $recipient)
        }
    }
}

#Preview {
    ListAddRecipientButton(
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
