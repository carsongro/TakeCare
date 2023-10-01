//
//  TCLoginView.swift
//  TakeCare
//
//  Created by Carson Gross on 9/29/23.
//

import SwiftUI

struct TCLoginView: View, @unchecked Sendable {
    @Environment(TCAuthViewModel.self) private var viewModel
    
    enum Field {
        case email
        case password
    }
    
    @FocusState private var focusedField: Field?
    
    @State var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationStack {
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
                        text: $password,
                        title: "Password",
                        placeholder: "Please enter your password",
                        textFieldType: .password
                    )
                    .focused($focusedField, equals: .password)
                    .submitLabel(.go)
                }
                .onSubmit {
                    switch focusedField {
                    case .email:
                        focusedField = .password
                    default:
                        login()
                    }
                }
                
                Section {
                    NavigationLink {
                        TCPasswordResetView()
                    } label: {
                        Text("Forgot password")
                            .foregroundStyle(.blue)
                    }
                    
                    NavigationLink {
                        TCCreateAccountView()
                    } label: {
                        Text("Sign up")
                            .fontWeight(.semibold)
                            .foregroundStyle(.blue)
                    }
                }
                
                Section {
                    Button(
                        "Login",
                        action: login
                    )
                    .buttonStyle(.borderedProminent)
                    .disabled(!textFieldsAreValid)
                    .frame(maxWidth: .infinity)
                }
                .listRowBackground(Color(uiColor: .systemGroupedBackground))
            }
            .navigationTitle("Login")
        }
    }
    
    private func login() {
        guard textFieldsAreValid else { return }
        
        Task {
            await viewModel.signIn(withEmail: email, password: password)
        }
    }
}

// MARK: PasswordFieldProtocol

extension TCLoginView: PasswordFieldProtocol {
    var textFieldsAreValid: Bool {
        !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
    }
}

#Preview {
    TCLoginView()
        .environment(TCAuthViewModel())
}
