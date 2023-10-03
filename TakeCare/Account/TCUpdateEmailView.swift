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
    
    var body: some View {
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
                        await viewModel.reAuthenticateUser(
                            withEmail: currentEmail,
                            password: password
                        )
                        
                        await viewModel.updateEmail(to: newEmail)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!textFieldsAreValid)
                .listRowBackground(Color(uiColor: .systemGroupedBackground))
                .frame(maxWidth: .infinity)
            }
        }
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
        .navigationTitle("Update Email Address")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension TCUpdateEmailView: PasswordFieldProtocol {
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
        TCUpdateEmailView()
            .environment(TCAuthViewModel())
    }
}
