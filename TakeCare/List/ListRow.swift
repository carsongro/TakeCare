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
                
                if let recipientName = list.recipient?.displayName {
                    Text(recipientName)
                        .lineLimit(1)
                        .accessibility(label: Text("Recipient: \(recipientName).",
                                                   comment: "Accessibility label containing the recipient"))
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer(minLength: 0)
                
        }
        .font(.subheadline)
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
    ListRow(list: PreviewData.previewTakeCareList)
}
