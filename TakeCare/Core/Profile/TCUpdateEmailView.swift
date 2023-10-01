//
//  TCUpdateEmailView.swift
//  TakeCare
//
//  Created by Carson Gross on 9/29/23.
//

import SwiftUI
import FirebaseAuth

struct TCUpdateEmailView: View {
    @Environment(TCAuthViewModel.self) private var viewModel
    @Environment(\.dismiss) var dismiss
    
    
    @State private var newEmail = ""
    @State private var confirmNewEmail = ""
    @State private var email = ""
    @State private var password = ""
    
    @State private var showingErrorAlert = false
    
    var body: some View {
        List {
            Section {
                Text("You need to enter your credentials to make changes to your account.")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .listRowBackground(Color(uiColor: .systemGroupedBackground))
            }
            
            Section {
                TCInputView(
                    text: $newEmail,
                    title: "New email address",
                    placeholder: "Please enter your new email address",
                    textFieldType: .email
                )
                
                TCInputView(
                    text: $confirmNewEmail,
                    title: "Confirm new email address",
                    placeholder: "Please confirm your new email address",
                    textFieldType: .email
                )
                
                TCInputView(
                    text: $email,
                    title: "Current email address",
                    placeholder: "Please enter your current email address",
                    textFieldType: .email
                )
                
                TCInputView(
                    text: $password,
                    title: "Password",
                    placeholder: "Please enter your password",
                    textFieldType: .password
                )
            }
            
            Section {
                HStack {
                    Spacer()
                    
                    NavigationLink {
                        TCPasswordResetView()
                    } label: {
                        Text("Forgot password")
                            .foregroundStyle(.blue)
                    }
                }
            }
            
            Section {
                Button("Submit") {
                    Task {
                        do {
                            try await viewModel.reAuthenticateUser(
                                withEmail: email,
                                password: password
                            )
                            
                            try await viewModel.updateEmail(to: newEmail)
                        } catch {
                            showingErrorAlert = true
                            print("ERROR: \(error.localizedDescription)")
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!textFieldsAreValid)
                .listRowBackground(Color(uiColor: .systemGroupedBackground))
                .frame(maxWidth: .infinity)
            }
        }
        .scrollDisabled(true)
        .alert("There was an error completing your request", isPresented: $showingErrorAlert) {
            Button("OK", role: .cancel) { }
        }
        .navigationTitle("Update Email Address")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension TCUpdateEmailView: PasswordFieldProtocol {
    var textFieldsAreValid: Bool {
        !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
        && !newEmail.isEmpty
        && newEmail.contains("@")
        && newEmail == confirmNewEmail
    }
}


#Preview {
    NavigationStack {
        TCUpdateEmailView()
            .environment(TCAuthViewModel())
    }
}
