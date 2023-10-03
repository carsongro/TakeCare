//
//  TCAuthCheckView.swift
//  TakeCare
//
//  Created by Carson Gross on 9/29/23.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = TCAuthViewModel()
    @State private var selection: AppScreen? = .lists
    @Environment(\.prefersTabNavigation) private var prefersTabNavigation
    
    var body: some View {
        @Bindable var alertManager = AlertManager.shared
        
        Group {
            if viewModel.userSession == nil {
                TCLoginView()
                    .environment(viewModel)
                    .transition(.move(edge: .bottom))
            } else {
                if prefersTabNavigation {
                    AppTabView(selection: $selection)
                        .environment(viewModel)
                        .transition(.move(edge: .bottom))
                } else {
                    NavigationSplitView {
                        AppSidebarList(selection: $selection)
                    } detail: {
                        AppDetailColumn(screen: selection)
                    }
                    .environment(viewModel)
                }
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
    ContentView()
}
