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
                    textFieldType: .emailAddress
                )
                .focused($focusedField, equals: .newEmail)
                .submitLabel(.next)
                
                TCInputView(
                    text: $confirmNewEmail,
                    title: "Confirm new email address",
                    placeholder: "Please confirm your new email address",
                    textFieldType: .emailAddress
                )
                .focused($focusedField, equals: .confirmNewEmail)
                .submitLabel(.next)
                
                TCInputView(
                    text: $currentEmail,
                    title: "Current email address",
                    placeholder: "Please enter your current email address",
                    textFieldType: .emailAddress
                )
                .focused($focusedField, equals: .currentEmail)
                .submitLabel(.next)
                
                TCInputView(
                    text: $password,
                    title: "Password",
                    placeholder: "Please enter your password",
                    textFieldType: .password
                )
                .focused($focusedField, equals: .password)
                .submitLabel(.return)
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
        .scrollDisabled(true)
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
