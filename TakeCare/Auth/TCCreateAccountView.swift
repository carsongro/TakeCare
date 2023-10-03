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
    @State private var showingCreateAccountAlert = false
    
    var body: some View {
        Form {
            Section("Email") {
                TextField("Enter your email address", text: $email)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .focused($focusedField, equals: .email)
                    .submitLabel(.next)
            }
            
            Section("Name") {
                TextField("Enter your name", text: $name)
                    .textContentType(.name)
                    .focused($focusedField, equals: .name)
                    .submitLabel(.next)
            }
            
            Section("Password") {
                SecureField("Enter your password", text: $password)
                    .textContentType(.newPassword)
                    .textInputAutocapitalization(.never)
                    .focused($focusedField, equals: .password)
                    .submitLabel(.next)
                
                ZStack(alignment: .trailing) {
                    SecureField("Confirm your password", text: $confirmPassword)
                        .textContentType(.newPassword)
                        .textInputAutocapitalization(.never)
                        .focused($focusedField, equals: .confirmPassword)
                        .submitLabel(.return)
                    
                    passwordCheckView
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
        .formStyle(.grouped)
        .navigationTitle("Create Account")
        .navigationBarTitleDisplayMode(.inline)
        .onSubmit {
            switch focusedField {
            case .email:
                focusedField = .name
            case .name:
                focusedField = .password
            case .password:
                focusedField = .confirmPassword
            default:
                hideKeyboard()
            }
        }
        .alert("There was an error creating an account.", isPresented: $showingCreateAccountAlert) {
            Button("OK") { }
        }
    }
}

extension TCCreateAccountView {
    
    @ViewBuilder
    var passwordCheckView: some View {
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
    
    @MainActor
    private func createAccount() {
        guard textFieldsAreValid else { return }
        
        Task {
            do {
                try await viewModel.createUser(
                    withEmail: email,
                    password: password,
                    name: name
                )
                
                hideKeyboard()
            } catch {
                showingCreateAccountAlert = true
            }
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
