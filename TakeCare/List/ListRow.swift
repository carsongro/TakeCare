//
//  ListRow.swift
//  TakeCare
//
//  Created by Carson Gross on 10/4/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct ListRow: View {
    var list: TakeCareList
    var showingInfoIndicator = true
    
    @ObservedObject var imageManager = ImageManager()
    
    var body: some View {
        HStack {
            if let image = imageManager.image {
                Image(uiImage: image)
                    .resizable()
                    .listRowImage()
            } else {
                ZStack {
                    Rectangle()
                        .listRowImage()
                        .foregroundStyle(Color(.secondarySystemBackground))
                    
                    Image(systemName: "list.bullet")
                        .resizable()
                        .padding()
                        .fontWeight(.light)
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.secondary)
                }
                .listRowImage()
            }
            
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
            
            if showingInfoIndicator {
                Spacer(minLength: 0)
                
                Image(systemName: "info.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 22, height: 22)
                    .foregroundStyle(.accent)
                    .padding(.leading, 8)
            }
                
        }
        .onAppear {
            imageManager.load(url: URL(string: list.photoURL ?? ""))
        }
        .font(.subheadline)
        .contentShape(Rectangle())
    }
}

struct ListRowImage: ViewModifier {
    func body(content: Content) -> some View {
        let imageClipShape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        content
            .aspectRatio(contentMode: .fill)
            .frame(width: 60, height: 60)
            .clipShape(imageClipShape)
            .contentShape(imageClipShape)
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
