//
//  TCDeleteAccountView.swift
//  TakeCare
//
//  Created by Carson Gross on 9/29/23.
//


import SwiftUI
import FirebaseAuth

struct DeleteAccountForm: View {
    @Environment(AuthModel.self) private var authModel
    @Environment(\.dismiss) private var dismiss
    
    enum Field {
        case email
        case password
    }
    
    @FocusState private var focusedField: Field?
    
    @State private var email = ""
    @State private var password = ""
    @State private var showingDeleteAlert = false
    @State private var showingErrorAlert = false
    
    @State private var presentingResetPasswordForm = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("You need to enter your credentials to delete your account.")
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color(.systemGroupedBackground))
                }
                
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
                        .submitLabel(.return)
                }
                .onSubmit {
                    switch focusedField {
                    case .email:
                        focusedField = .password
                    default:
                        hideKeyboard()
                    }
                }
                
                Section {
                    Button("Forgot password") {
                        presentingResetPasswordForm = true
                    }
                }
                
                Section {
                    Button("Delete", role: .destructive) {
                        showingDeleteAlert = true
                    }
                    .disabled(!textFieldsAreValid)
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .listRowBackground(Color(.systemGroupedBackground))
                    .frame(maxWidth: .infinity)
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Delete Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $presentingResetPasswordForm) {
                PasswordResetForm()
            }
            .alert("There was an error deleting your account", isPresented: $showingErrorAlert) { }
            .alert("Are you sure you want to delete your accout? This action is irreversible.", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task {
                        do {
                            try await authModel.reAuthenticateUser(
                                withEmail: email,
                                password: password
                            )
                            
                            try await authModel.deleteCurrentUser()
                            
                        } catch {
                            showingErrorAlert = true
                        }
                    }
                }
            }
        }
    }
}

extension DeleteAccountForm: TextFieldProtocol {
    var textFieldsAreValid: Bool {
        !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
    }
}


#Preview {
    NavigationStack {
        DeleteAccountForm()
            .environment(AuthModel())
    }
}
