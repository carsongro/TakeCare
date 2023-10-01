//
//  TCAuthCheckView.swift
//  TakeCare
//
//  Created by Carson Gross on 9/29/23.
//

import SwiftUI

struct TCAuthCheckView: View {
    @State private var viewModel = TCAuthViewModel()
    
    var body: some View {
        @Bindable var alertManager = AlertManager.shared
        
        Group {
            if viewModel.userSession == nil {
                TCLoginView()
                    .environment(viewModel)
                    .transition(.move(edge: .bottom))
            } else {
                TCTabView()
                    .environment(viewModel)
                    .transition(.move(edge: .bottom))
            }
        }
        .alert(
            alertManager.title,
            isPresented: $alertManager.showingAlert
        ) {
            if let primaryButtonText = alertManager.primaryButtonText {
                Button(
                    primaryButtonText,
                    role: alertManager.primaryButtonRole
                ) {
                    alertManager.primaryButtonAction?()
                }
            }
            
            if let secondaryButtonText = alertManager.secondaryButtonText {
                Button(
                    secondaryButtonText,
                    role: alertManager.secondaryButtonRole
                ) {
                    alertManager.secondaryButtonAction?()
                }
            }
        }
    }
}

#Preview {
    TCAuthCheckView()
}
