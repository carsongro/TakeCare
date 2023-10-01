//
//  TCLoginView.swift
//  TakeCare
//
//  Created by Carson Gross on 9/29/23.
//

import SwiftUI

struct TCLoginView: View, @unchecked Sendable {
    @Environment(TCAuthManager.self) private var authManager
    
    @State var email = ""
    @State private var password = ""
    
    @State private var showingAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                TCInputView(
                    text: $email,
                    title: "Email address",
                    placeholder: "Please enter your email address",
                    textFieldType: .email
                )
                
//                TCInputView(
//                    text: $password,
//                    title: "Password",
//                    placeholder: "Please enter your password",
//                    textFieldType: .password
//                )
//                .onSubmit { login() }
                
                
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
            .alert("There was an error logging in", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            }
        }
    }
    
    private func login() {
        guard textFieldsAreValid else { return }
        
        Task {
            do {
                try await authManager.signIn(withEmail: email, password: password)
            } catch {
                print(error.localizedDescription)
                showingAlert = true
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
        .environment(TCAuthManager())
}
