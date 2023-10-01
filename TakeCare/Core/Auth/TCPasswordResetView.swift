//
//  TCPasswordResetView.swift
//  TakeCare
//
//  Created by Carson Gross on 9/29/23.
//

import SwiftUI

struct TCPasswordResetView: View, @unchecked Sendable {
    @Environment(TCAuthViewModel.self) private var viewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var email = ""
    
    var body: some View {
        List {
            Section {
                Text("You will receive a link to reset your password in your email.")
            }
            .listRowBackground(Color(uiColor: .systemGroupedBackground))

            
            Section {
                TCInputView(
                    text: $email,
                    title: "Email address",
                    placeholder: "Please enter your email",
                    textFieldType: .emailAddress
                )
                .submitLabel(.send)
            }
            .onSubmit {
                sendResetLink()
            }
            
            Section {
                Button(
                    "Send reset link",
                    action: sendResetLink
                )
                .buttonStyle(.borderedProminent)
                .disabled(!textFieldsAreValid)
                .frame(maxWidth: .infinity)
                .listRowBackground(Color(uiColor: .systemGroupedBackground))
            }
        }
        .scrollDisabled(true)
        .navigationTitle("Password Reset")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func sendResetLink() {
        Task {
            await viewModel.sendPasswordResetEmail(withEmail: email)
            
            AlertManager.shared.showAlert(
                title: "Successfully sent password reset link.",
                primaryButtonText: "OK",
                primaryButtonAction: {
                    dismiss()
                }
            )
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
