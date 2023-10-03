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
    @State private var showingSignInAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Email") {
                    TextField("Enter your email address", text: $email)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .focused($focusedField, equals: .email)
                        .submitLabel(.next)
                }
                
                Section("Password") {
                    SecureField("Enter your password", text: $password)
                        .textContentType(.password)
                        .textInputAutocapitalization(.never)
                        .focused($focusedField, equals: .password)
                        .submitLabel(.go)
                }
                
                Section {
                    NavigationLink {
                        TCPasswordResetView()
                    } label: {
                        Text("Forgot password")
                    }
                    
                    NavigationLink {
                        TCCreateAccountView()
                    } label: {
                        Text("Sign up")
                            .fontWeight(.semibold)
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
                    .listRowBackground(Color(uiColor: .systemGroupedBackground))
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Login")
            .onSubmit {
                switch focusedField {
                case .email:
                    focusedField = .password
                default:
                    login()
                }
            }
            .alert("There was an error signing in.", isPresented: $showingSignInAlert) {
                Button("OK") { }
            }
        }
    }
    
    private func login() {
        guard textFieldsAreValid else { return }
        
        Task {
            do {
                try await viewModel.signIn(withEmail: email, password: password)
            } catch {
                showingSignInAlert = true
            }
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
