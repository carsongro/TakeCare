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
    
    @State private var email = ""
    @State private var password = ""
    
    @State private var showingErrorAlert = false
    @State private var showingDeleteAlert = false
    
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
                    textFieldType: .email
                )
                
                TCInputView(
                    text: $password,
                    title: "Password",
                    placeholder: "Please enter your password",
                    textFieldType: .password
                )
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
                        do {
                            try await viewModel.reAuthenticateUser(
                                withEmail: email,
                                password: password
                            )
                            showingDeleteAlert = true
                        } catch {
                            showingErrorAlert = true
                        }
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
        .alert("There was an error completing your request", isPresented: $showingErrorAlert) {
            Button("OK", role: .cancel) { }
        }
        .alert("Are you sure you want to delete your account?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel.deleteUser()
                }
            }
        }
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
