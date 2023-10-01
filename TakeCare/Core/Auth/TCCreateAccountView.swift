//
//  TCCreateAccountView.swift
//  TakeCare
//
//  Created by Carson Gross on 9/29/23.
//

import SwiftUI

struct TCCreateAccountView: View {
    @State private var email = ""
    @State private var name = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @Environment(TCAuthManager.self) private var authManager
    
    var body: some View {
        List {
            TCInputView(
                text: $email,
                title: "Email address",
                placeholder: "Please enter your email address",
                textFieldType: .email
            )
            
            TCInputView(
                text: $name,
                title: "Name",
                placeholder: "Please enter your name",
                textFieldType: .plain
            )
            
            TCInputView(
                text: $password,
                title: "Password",
                placeholder: "Please enter your password",
                textFieldType: .newPassword
            )
            
            ZStack(alignment: .trailing) {
                TCInputView(
                    text: $confirmPassword,
                    title: "Confirm password",
                    placeholder: "Please confirm your password",
                    textFieldType: .newPassword
                )
                
                if !password.isEmpty && !confirmPassword.isEmpty {
                    if password == confirmPassword {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.green)
                            .imageScale(.large)
                    } else {
                        Image(systemName: "xmark")
                            .foregroundStyle(.red)
                            .imageScale(.large)
                    }
                }
            }
            
            Section {
                Button("Create Account") {
                    Task {
                        try await authManager.createUser(
                            withEmail: email,
                            password: password,
                            name: name
                        )
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!textFieldsAreValid)
                .listRowBackground(Color(uiColor: .systemGroupedBackground))
                .frame(maxWidth: .infinity)
            }
        }
        .scrollDisabled(true)
        .navigationTitle("Create Account")
    }
}

// MARK: PasswordFieldProtocol

extension TCCreateAccountView: PasswordFieldProtocol {
    var textFieldsAreValid: Bool {
        !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
        && password == confirmPassword
        && !name.isEmpty
    }
}

#Preview {
    
    NavigationStack {
        TCCreateAccountView()
            .environment(TCAuthManager())
    }
}
