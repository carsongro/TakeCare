//
//  TCDeleteAccountView.swift
//  TakeCare
//
//  Created by Carson Gross on 9/29/23.
//


import SwiftUI
import FirebaseAuth

struct TCDeleteAccountView: View {
    @Environment(TCAuthViewModel.self) private var viewModel
    
    enum Field {
        case email
        case password
    }
    
    @FocusState private var focusedField: Field?
    
    @State private var email = ""
    @State private var password = ""
    
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
                Button("Delete") {
                    Task {
                        await viewModel.reAuthenticateUser(
                            withEmail: email,
                            password: password
                        )
                        
                        AlertManager.shared.showAlert(
                            title: "Are you sure you want to delete your accout? This action is irreversible.",
                            primaryButtonText: "Delete",
                            primaryButtonAction: {
                                Task {
                                    await viewModel.deleteCurrentUser()
                                }
                            },
                            primaryButtonRole: .destructive,
                            secondaryButtonText: "Cancel",
                            secondaryButtonRole: .cancel
                        )
                    }
                }
                .disabled(!textFieldsAreValid)
                .buttonStyle(.bordered)
                .foregroundStyle(.red)
                .listRowBackground(Color(uiColor: .systemGroupedBackground))
                .frame(maxWidth: .infinity)
            }
        }
        .scrollDisabled(true)
        .navigationTitle("Delete Account")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension TCDeleteAccountView: PasswordFieldProtocol {
    var textFieldsAreValid: Bool {
        !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
    }
}


#Preview {
    NavigationStack {
        TCDeleteAccountView()
            .environment(TCAuthViewModel())
    }
}
