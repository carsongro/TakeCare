//
//  ListDetailHeader.swift
//  TakeCare
//
//  Created by Carson Gross on 10/21/23.
//

import SwiftUI
import Kingfisher

struct ListDetailHeader: View {
    @Environment(\.prefersTabNavigation) private var prefersTabNavigation
    @Binding var list: TakeCareList
    
    var width: CGFloat
    
    var proportionalWidth: CGFloat { width * (prefersTabNavigation ? 2/3 : 1/4) }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            let imageClipShape = RoundedRectangle(cornerRadius: 10, style: .continuous)
            KFImage(URL(string: list.photoURL ?? ""))
                .resizable()
                .placeholder {
                    Image(systemName: "list.bullet")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: proportionalWidth, height: proportionalWidth)
                        .padding()
                        .shadow(color: .black.opacity(0.3), radius: 6, y: 8)
                }
                .aspectRatio(contentMode: .fill)
                .frame(width: proportionalWidth, height: proportionalWidth)
                .contentShape(imageClipShape)
                .clipShape(imageClipShape)
                .frame(maxWidth: .infinity)
                .shadow(color: .black.opacity(0.3), radius: 6, y: 8)
            
            
            Text(list.isActive ? "Currently Active" : "Not Active")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
            
            Text(list.description ?? "")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ListDetailHeader(list: .constant(PreviewData.previewTakeCareList), width: 300)
}
