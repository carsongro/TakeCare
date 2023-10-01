//
//  TCPasswordResetView.swift
//  TakeCare
//
//  Created by Carson Gross on 9/29/23.
//

import SwiftUI

struct TCPasswordResetView: View {
    @Environment(TCAuthManager.self) private var authManager
    @Environment(\.dismiss) var dismiss
    
    @State private var showingAlert = false
    @State private var alertText = ""
    @State private var canDismiss = false
    
    @State private var email = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("You will receive a link to reset your password.")
            
            TCInputView(
                text: $email,
                title: "Email address",
                placeholder: "Please enter your email",
                textFieldType: .email
            )
            
            Button("Send email") {
                Task {
                    do {
                        try await authManager.sendPasswordResetEmail(withEmail: email)
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
            
            Spacer()
        }
        .padding()
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
            .environment(TCAuthManager())
    }
}
