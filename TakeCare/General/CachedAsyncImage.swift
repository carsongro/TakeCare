//
//  CachedAsyncImage.swift
//  TakeCare
//
//  Created by Carson Gross on 11/14/23.
//

import SwiftUI

struct CachedAsyncImage: View {
    
    @State private var image: Image?
    
    var url: URL?
    
    var placeholder: AnyView?
    var isResizable = false
    
    var body: some View {
        Group {
            if let image {
                if isResizable {
                    image
                        .resizable()
                } else {
                    image
                }
            } else {
                placeholder
            }
        }
        .onAppear {
            if let url {
                loadImage(url: url)
            }
        }
        .onChange(of: url) { oldValue, newValue in
            if let url {
                loadImage(url: url)
            } else {
                image = nil
            }
        }
    }
    
    @MainActor
    private func loadImage(url: URL) {
        Task {
            do {
                image = try await ImageManager.shared.Image(from: url)
            } catch {
                
            }
        }
    }
    
    func placeholder<T: View>(
        @ViewBuilder _ content: () -> T
    ) -> CachedAsyncImage where T : View {
        var imageView = self
        imageView.placeholder = AnyView(content())
        return imageView
    }
    
    func resizable() -> CachedAsyncImage {
        var imageView = self
        imageView.isResizable = true
        return imageView
    }
}

#Preview {
    CachedAsyncImage()
}
