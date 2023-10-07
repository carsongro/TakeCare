//
//  ListRow.swift
//  TakeCare
//
//  Created by Carson Gross on 10/4/23.
//

import SwiftUI
import Kingfisher

struct ListRow: View {
    var list: TakeCareList
    
    var body: some View {
        HStack(alignment: .top) {
            KFImage(URL(string: list.photoURL ?? ""))
                .placeholder {
                    Image(systemName: "photo.fill")
                        .resizable()
                        .listRowImage()
                }
                .resizable()
                .listRowImage()
            
            VStack(alignment: .leading) {
                Text(list.name)
                    .font(.headline)
                
                if let description = list.description {
                    Text(description)
                        .lineLimit(1)
                }
                
                Text(listedRecipients)
                    .lineLimit(1)
                    .accessibility(label: Text("Recipients: \(listedRecipients).",
                                               comment: "Accessibility label containing the full list of list recipients"))
                    .foregroundStyle(.secondary)
            }
            
            Spacer(minLength: 0)
                
        }
        .font(.subheadline)
    }
    
    var listedRecipients: String {
        guard !list.recipients.isEmpty else { return "" }
        var recipientsList = [String]()
        recipientsList.append(contentsOf: list.recipients.compactMap { $0.displayName.localizedCapitalized })
        return ListFormatter.localizedString(byJoining: recipientsList)
    }
}

struct ListRowImage: ViewModifier {
    func body(content: Content) -> some View {
        let imageClipShape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        content
            .aspectRatio(contentMode: .fill)
            .frame(width: 60, height: 60)
            .clipShape(imageClipShape)
            .accessibilityHidden(true)
    }
    
    private var cornerRadius: Double {
        #if os(iOS)
        return 10
        #else
        return 4
        #endif
    }
}

extension View {
    func listRowImage() -> some View {
        modifier(ListRowImage())
    }
}

#Preview {
    ListRow(
        list: TakeCareList(
            id: nil,
            ownerID: "",
            name: "Carson's list",
            description: "Description for this list.",
            recipients: [
                User(
                    id: UUID().uuidString,
                    displayName: "Carson Gross",
                    email: "test@test.com",
                    photoURL: nil
                ),
                User(
                    id: UUID().uuidString,
                    displayName: "Test Testing",
                    email: "test@test.com",
                    photoURL: nil
                )
            ],
            tasks: [
                ListTask(
                    name: "Go for walk",
                    notes: "Walk around outside?",
                    completionDate: nil
                )
            ],
            photoURL: nil
        )
    )
}
