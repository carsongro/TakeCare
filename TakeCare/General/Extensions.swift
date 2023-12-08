//
//  Extensions.swift
//  TakeCare
//
//  Created by Carson Gross on 10/1/23.
//

import SwiftUI

#if canImport(UIKit)
extension View {
    @MainActor 
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

struct PrefersTabNavigationEnvironmentKey: EnvironmentKey {
    static var defaultValue: Bool = false
}

extension EnvironmentValues {
    var prefersTabNavigation: Bool {
        get { self[PrefersTabNavigationEnvironmentKey.self] }
        set { self[PrefersTabNavigationEnvironmentKey.self] = newValue }
    }
}

#if os(iOS)
extension PrefersTabNavigationEnvironmentKey: UITraitBridgedEnvironmentKey {
    static func read(from traitCollection: UITraitCollection) -> Bool {
        return traitCollection.userInterfaceIdiom == .phone || traitCollection.userInterfaceIdiom == .tv
    }
    
    static func write(to mutableTraits: inout UIMutableTraits, value: Bool) {
        // Do not write.
    }
}
#endif

extension Date {
    var comparableTime: ComparableTime {
        ComparableTime(self)
    }
}

extension Image {
    init?(data: Data) {
        guard let uiImage = UIImage(data: data) else { return nil }
        self.init(uiImage: uiImage)
    }
    
    @MainActor
    func uiImage() async -> UIImage? {
        ImageRenderer(content: self).uiImage
    }
    
    @MainActor
    func data(compressionQuality: Double = 0.7) async -> Data? {
        ImageRenderer(content: self).uiImage?.jpegData(compressionQuality: compressionQuality)
    }
}

extension UIImage {
    func croppedToSquare() -> UIImage? {
        let isPortrait = self.size.height > self.size.width
        let offsetCenterX = isPortrait ? 0 : self.size.width / 2 - self.size.height / 2
        let offsetCenterY = isPortrait ? self.size.height / 2 - self.size.width / 2 : 0
        let sideLength = isPortrait ? self.size.width : self.size.height

        if let croppedCGImage = self.cgImage?.cropping(
            to: CGRect(
                x: offsetCenterX,
                y: offsetCenterY,
                width: sideLength,
                height: sideLength
            )
        ) {
            return UIImage(cgImage: croppedCGImage)
        } else {
            return nil
        }
    }
}
