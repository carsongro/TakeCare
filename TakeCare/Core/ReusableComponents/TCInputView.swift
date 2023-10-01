//
//  TCInputView.swift
//  TakeCare
//
//  Created by Carson Gross on 9/29/23.
//

import SwiftUI

enum TextFieldType {
    case email
    case password
    case newPassword
    case plain
}

struct TCInputView: View {
    @Binding var text: String
    let title: String
    let placeholder: String
    let textFieldType: TextFieldType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .fontWeight(.semibold)
            
            switch textFieldType {
            case .email:
                TextField(placeholder, text: $text)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
            case .password:
                SecureField(placeholder, text: $text)
                    .textContentType(.password)
                    .textInputAutocapitalization(.never)
            case .newPassword:
                SecureField(placeholder, text: $text)
                    .textContentType(.newPassword)
                    .textInputAutocapitalization(.never)
            case .plain:
                TextField(placeholder, text: $text)
            }
        }
    }
}

#Preview {
    TCInputView(
        text: .constant(
            ""
        ),
        title: "Email address",
        placeholder: "test@example.com",
        textFieldType: .email
    )
}
