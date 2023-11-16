//
//  ListChooseListImageView.swift
//  TakeCare
//
//  Created by Carson Gross on 10/6/23.
//

import PhotosUI
import SwiftUI

struct ListChooseListImageView: View {
    @Environment(\.prefersTabNavigation) private var prefersTabNavigation
    
    @Binding var listImage: Image?
    var width: CGFloat
    
    @State private var listImageItem: PhotosPickerItem?
    @State private var showingPhotosPicker = false
    
    var didChangeImageHandler: (() -> Void)? = nil
    
    var proportionalWidth: CGFloat { width * (prefersTabNavigation ? 3/5 : 1/3) }
    
    var body: some View {
        let imageClipShape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        ZStack {
            if let listImage = listImage {
                listImage
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: proportionalWidth, height: proportionalWidth)
                    .clipShape(imageClipShape)
                    .contentShape(imageClipShape)
                    .shadow(color: .black.opacity(0.3), radius: 6, y: 8)
            } else {
                Rectangle()
                    .foregroundStyle(Color(.secondarySystemBackground))
                    .frame(width: proportionalWidth, height: proportionalWidth)
                    .clipShape(imageClipShape)
                    .shadow(color: .black.opacity(0.3), radius: 6, y: 8)
                Image(systemName: "list.bullet")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .foregroundStyle(.secondary)
            }
            Menu {
                Button("Choose Photo", systemImage: "photo.on.rectangle") {
                    showingPhotosPicker = true
                }
            } label: {
                ZStack {
                    Circle()
                        .foregroundStyle(Color(.secondarySystemBackground))
                        .shadow(color: .black.opacity(0.6), radius: 5)
                        .frame(width: 70, height: 70)
                    Image(systemName: "camera.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 20, height: 20)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .accessibilityLabel("Change list image")
        .onChange(of: listImageItem) { _, _ in
            Task {
                if let data = try? await listImageItem?.loadTransferable(type: Data.self) {
                    if let image = Image(data: data) {
                        listImage = image
                        didChangeImageHandler?()
                        listImageItem = nil
                    }
                }
            }
        }
        .photosPicker(isPresented: $showingPhotosPicker, selection: $listImageItem)
    }
    
    var cornerRadius: Double { 10 }
}

#Preview {
    ListChooseListImageView(listImage: .constant(nil), width: 300)
}
