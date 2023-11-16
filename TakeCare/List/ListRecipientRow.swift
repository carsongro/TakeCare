//
//  ListRecipientRow.swift
//  TakeCare
//
//  Created by Carson Gross on 10/6/23.
//

import SwiftUI
import IoImage

struct ListRecipientRow: View {
    var user: User
    
    var body: some View {
        HStack(alignment: .center) {
            IoImageView(url: URL(string: user.photoURL ?? ""))
                .resizable()
                .placeholder {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .recipientRowImage()
                        .foregroundStyle(.secondary)
                }
                .recipientRowImage()
            
            VStack(alignment: .leading) {
                Text(user.displayName)
                    .font(.headline)
            }
            
            Spacer(minLength: 0)
        }
        .font(.subheadline)
        .accessibilityElement(children: .combine)
    }
    
    var cornerRadius: Double { 10 }
}

struct RecipientRowImage: ViewModifier {
    func body(content: Content) -> some View {
        content
            .contentShape(Circle())
            .clipShape(Circle())
            .aspectRatio(contentMode: .fill)
            .frame(width: 60, height: 60)
            .accessibilityHidden(true)
    }
}

extension View {
    func recipientRowImage() -> some View {
        modifier(RecipientRowImage())
    }
}

#Preview {
    ListRecipientRow(
        user: User(
            id: UUID().uuidString,
            displayName: "Carson Gross",
            email: "test@test.com",
            photoURL: nil
        )
    )
    .frame(width: 250, alignment: .leading)
    .padding(.horizontal)
    .previewLayout(.sizeThatFits)
}
