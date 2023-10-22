//
//  ListDetailHeader.swift
//  TakeCare
//
//  Created by Carson Gross on 10/21/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct ListDetailHeader: View {
    @Binding var list: TakeCareList
    
    var body: some View {
        let imageClipShape = RoundedRectangle(cornerRadius: 10, style: .continuous)
        WebImage(url: URL(string: list.photoURL ?? ""))
            .resizable()
            .placeholder {
                ZStack {
                    Image(systemName: "list.bullet")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                        .padding()
                }
            }
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 200, height: 200)
            .contentShape(imageClipShape)
            .clipShape(imageClipShape)
            .padding()
            .frame(maxWidth: .infinity)
        
        Text(list.description ?? "")
    }
}

#Preview {
    ListDetailHeader(list: .constant(PreviewData.previewTakeCareList))
}
