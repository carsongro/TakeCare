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
