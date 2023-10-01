//
//  TCPasswordResetView.swift
//  TakeCare
//
//  Created by Carson Gross on 9/29/23.
//

import SwiftUI

struct TCPasswordResetView: View {
    @Environment(TCAuthViewModel.self) private var viewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var showingAlert = false
    @State private var alertText = ""
    @State private var canDismiss = false
    
    @State private var email = ""
    
    var body: some View {
        List {
            Section {
                Text("You will receive a link to reset your password.")
            }
            .listRowBackground(Color(uiColor: .systemGroupedBackground))

            
            Section {
                TCInputView(
                    text: $email,
                    title: "Email address",
                    placeholder: "Please enter your email",
                    textFieldType: .email
                )
            }
            
            Section {
                Button("Send email") {
                    Task {
                        do {
                            try await viewModel.sendPasswordResetEmail(withEmail: email)
                            canDismiss = true
                            alertText = "Successfully sent password reset email"
                            showingAlert = true
                        } catch {
                            canDismiss = false
                            alertText = "There was an error sending a password reset email"
                            showingAlert = true
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!textFieldsAreValid)
                .frame(maxWidth: .infinity)
                .listRowBackground(Color(uiColor: .systemGroupedBackground))
            }
        }
        .navigationTitle("Password Reset")
        .alert(alertText, isPresented: $showingAlert) {
            Button("OK", role: .cancel) { 
                if canDismiss {
                    dismiss()
                }
            }
        }
    }
}

// MARK: PasswordFieldProtocol

extension TCPasswordResetView: PasswordFieldProtocol {
    var textFieldsAreValid: Bool {
        !email.isEmpty
        && email.contains("@")
    }
}

#Preview {
    NavigationStack {
        TCPasswordResetView()
            .environment(TCAuthViewModel())
    }
}
