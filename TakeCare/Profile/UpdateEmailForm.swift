//
//  TCUpdateEmailView.swift
//  TakeCare
//
//  Created by Carson Gross on 9/29/23.
//

import SwiftUI
import FirebaseAuth

struct UpdateEmailForm: View {
    @Environment(AuthModel.self) private var authModel
    @Environment(\.dismiss) private var dismiss
    
    enum Field {
        case newEmail
        case confirmNewEmail
        case currentEmail
        case password
    }
    
    @FocusState private var focusedField: Field?
    
    @State private var newEmail = ""
    @State private var confirmNewEmail = ""
    @State private var currentEmail = ""
    @State private var password = ""
    
    @State private var showingErrorAlert = false
    @State private var presentingResetPasswordForm = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("You need to enter your credentials to make changes to your account.")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .listRowBackground(Color(uiColor: .systemGroupedBackground))
                }
                
                Section("New email") {
                    TextField("Enter your new email address", text: $newEmail)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .focused($focusedField, equals: .newEmail)
                        .submitLabel(.next)
                    
                    TextField("Confirm new email address", text: $confirmNewEmail)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .focused($focusedField, equals: .confirmNewEmail)
                        .submitLabel(.next)
                }
                
                Section("Current Email") {
                    TextField("Enter your current email address", text: $currentEmail)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .focused($focusedField, equals: .currentEmail)
                        .submitLabel(.next)
                }
                
                Section("Password") {
                    SecureField("Enter your password", text: $password)
                        .textContentType(.password)
                        .textInputAutocapitalization(.never)
                        .focused($focusedField, equals: .password)
                        .submitLabel(.return)
                }
                
                Section {
                    Button("Forgot password") {
                        presentingResetPasswordForm = true
                    }
                }
                
                Section {
                    Button("Submit") {
                        Task {
                            do {
                                try await authModel.reAuthenticateUser(
                                    withEmail: currentEmail,
                                    password: password
                                )
                                
                                try await authModel.updateEmail(to: newEmail)
                            } catch {
                                showingErrorAlert = true
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!textFieldsAreValid)
                    .listRowBackground(Color(uiColor: .systemGroupedBackground))
                    .frame(maxWidth: .infinity)
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Update Email Address")
            .navigationBarTitleDisplayMode(.inline)
            .onSubmit {
                switch focusedField {
                case .newEmail:
                    focusedField = .confirmNewEmail
                case .confirmNewEmail:
                    focusedField = .currentEmail
                case .currentEmail:
                    focusedField = .password
                default:
                    hideKeyboard()
                }
            }
            .alert("There was an error updating your email.", isPresented: $showingErrorAlert) {
                Button("OK") { }
            }
            .sheet(isPresented: $presentingResetPasswordForm) {
                PasswordResetForm()
            }
        }
    }
}

extension UpdateEmailForm: TextFieldProtocol {
    var textFieldsAreValid: Bool {
        !currentEmail.isEmpty
        && currentEmail.contains("@")
        && !password.isEmpty
        && password.count > 5
        && !newEmail.isEmpty
        && newEmail.contains("@")
        && newEmail == confirmNewEmail
    }
}


#Preview {
    NavigationStack {
        UpdateEmailForm()
            .environment(AuthModel())
    }
}
