//
//  AuthPasswordResetForm.swift
//  TakeCare
//
//  Created by Carson Gross on 9/29/23.
//

import SwiftUI

struct PasswordResetForm: View, @unchecked Sendable {
    @Environment(AuthModel.self) private var authModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var showingSuccessAlert = false
    @State private var showingErrorAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("You will receive a link to reset your password in your email.")
                        .listRowBackground(Color(.systemGroupedBackground))
                }
                
                Section("Email") {
                    TextField("Enter your email address", text: $email)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
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
                    .listRowBackground(Color(.systemGroupedBackground))
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Password Reset")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Successfully sent password reset link.", isPresented: $showingSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            }
            .alert("There was an error sending the password reset link", isPresented: $showingErrorAlert) { }
        }
    }
    
    private func sendResetLink() {
        Task {
            do {
                try await authModel.sendPasswordResetEmail(withEmail: email)
                showingSuccessAlert = true
            } catch {
                showingErrorAlert = true
            }
        }
    }
}

// MARK: PasswordFieldProtocol

extension PasswordResetForm: TextFieldProtocol {
    var textFieldsAreValid: Bool {
        !email.isEmpty
        && email.contains("@")
    }
}

#Preview {
    NavigationStack {
        PasswordResetForm()
            .environment(AuthModel())
    }
}
