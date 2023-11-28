//
//  CameraView.swift
//  TakeCare
//
//  Created by Carson Gross on 11/27/23.
//

import SwiftUI

struct CameraView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    var finishedPicking: (Image) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, @unchecked Sendable {
        var parent: CameraView
        
        init(parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true)

            guard let image = info[.editedImage] as? UIImage else {
                print("No image found")
                return
            }

            parent.finishedPicking(Image(uiImage: image))
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
    
    @MainActor
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ imagePicker: UIImagePickerController, context: Context) {
        
    }
}

#Preview {
    CameraView() { _ in }
}
