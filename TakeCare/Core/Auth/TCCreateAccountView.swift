//
//  TCCreateAccountView.swift
//  TakeCare
//
//  Created by Carson Gross on 9/29/23.
//

import SwiftUI

struct TCCreateAccountView: View {
    @Environment(TCAuthViewModel.self) private var viewModel

    enum Field {
        case email
        case name
        case password
        case confirmPassword
    }
    
    @FocusState private var focusedField: Field?
    
    @State private var email = ""
    @State private var name = ""
    @State private var password = ""
    @State private var confirmPassword = ""
        
    var body: some View {
        List {
            Section {
                TCInputView(
                    text: $email,
                    title: "Email address",
                    placeholder: "Please enter your email address",
                    textFieldType: .emailAddress
                )
                .focused($focusedField, equals: .email)
                .submitLabel(.next)
                
                TCInputView(
                    text: $name,
                    title: "Name",
                    placeholder: "Please enter your name",
                    textFieldType: .name
                )
                .focused($focusedField, equals: .name)
                .submitLabel(.next)
                
                TCInputView(
                    text: $password,
                    title: "Password",
                    placeholder: "Please enter your password",
                    textFieldType: .newPassword
                )
                .focused($focusedField, equals: .password)
                .submitLabel(.next)
                
                ZStack(alignment: .trailing) {
                    TCInputView(
                        text: $confirmPassword,
                        title: "Confirm password",
                        placeholder: "Please confirm your password",
                        textFieldType: .newPassword
                    )
                    .focused($focusedField, equals: .confirmPassword)
                    .submitLabel(.join)
                    
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
            }
            .onSubmit {
                switch focusedField {
                case .email:
                    focusedField = .name
                case .name:
                    focusedField = .password
                case .password:
                    focusedField = .confirmPassword
                default:
                    createAccount()
                }
            }
            
            Section {
                Button("Create Account") {
                    createAccount()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!textFieldsAreValid)
                .listRowBackground(Color(uiColor: .systemGroupedBackground))
                .frame(maxWidth: .infinity)
            }
        }
        .scrollDisabled(true)
        .navigationTitle("Create Account")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @MainActor
    private func createAccount() {
        Task {
            await viewModel.createUser(
                withEmail: email,
                password: password,
                name: name
            )
            
            hideKeyboard()
        }
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
            .environment(TCAuthViewModel())
    }
}
