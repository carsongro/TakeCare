//
//  ListChooseListImageView.swift
//  TakeCare
//
//  Created by Carson Gross on 10/6/23.
//

import PhotosUI
import SwiftUI

struct ListChooseListImageView: View {
    
    @Binding var listImage: UIImage?
    
    @State private var listImageItem: PhotosPickerItem?
    @State private var showingPhotosPicker = false
    @State private var showingListImagePopover = false
    
    var body: some View {
        Button {
            showingListImagePopover = true
        } label: {
            let imageClipShape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            ZStack {
                if let listImage = listImage {
                    Image(uiImage: listImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 200)
                        .clipShape(imageClipShape)
                        .shadow(color: .black.opacity(0.3), radius: 6, y: 8)
                } else {
                    Rectangle()
                        .foregroundStyle(Color(.secondarySystemBackground))
                        .frame(width: 200, height: 200)
                        .clipShape(imageClipShape)
                        .shadow(color: .black.opacity(0.3), radius: 6, y: 8)
                    Image(systemName: "list.bullet")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .foregroundStyle(.secondary)
                }
                Circle()
                    .foregroundStyle(Color(.secondarySystemBackground))
                    .shadow(color: .black.opacity(0.6), radius: 5)
                    .frame(width: 70, height: 70)
                    .popover(isPresented: $showingListImagePopover) {
                        Button("Choose Photo", systemImage: "photo.on.rectangle") {
                            showingListImagePopover = false
                            showingPhotosPicker = true
                        }
                        .padding()
                        .presentationCompactAdaptation(.popover)
                    }
                Image(systemName: "camera.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 20, height: 20)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .accessibilityLabel("Change list image")
        .onChange(of: listImageItem) { _, _ in
            Task {
                if let data = try? await listImageItem?.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data) {
                        withAnimation {
                            listImage = uiImage
                        }
                        listImageItem = nil
                    }
                }
            }
        }
        .photosPicker(isPresented: $showingPhotosPicker, selection: $listImageItem)
    }
    
    var cornerRadius: Double {
        #if os(iOS)
        return 10
        #else
        return 4
        #endif
    }
}

#Preview {
    ListChooseListImageView(listImage: .constant(nil))
}
