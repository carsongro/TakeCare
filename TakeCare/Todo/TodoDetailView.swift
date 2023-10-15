//
//  TodoDetailView.swift
//  TakeCare
//
//  Created by Carson Gross on 10/14/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct TodoDetailView: View {
    var list: TakeCareList
    
    var body: some View {
        ScrollView {
            VStack {
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
                
                Text(list.description ?? "")
            }
            .frame(maxWidth: .infinity)
        }
        .navigationTitle(list.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        TodoDetailView(list: PreviewData.previewTakeCareList)
    }
}
