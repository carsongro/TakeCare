//
//  TCAuthCheckView.swift
//  TakeCare
//
//  Created by Carson Gross on 9/29/23.
//

import SwiftUI

struct ContentView: View {
    @State private var authModel = AuthModel.shared
    
    @Environment(\.prefersTabNavigation) private var prefersTabNavigation
    
    var body: some View {
        @Bindable var navigator = Navigator.shared
        
        if authModel.isSignedIn {
            if prefersTabNavigation {
                AppTabView(selection: $navigator.selection)
                    .environment(authModel)
                    .transition(.move(edge: .bottom))
            } else {
                NavigationSplitView {
                    AppSidebarList(selection: $navigator.selection)
                } detail: {
                    AppDetailColumn(screen: navigator.selection)
                }
                .transition(.move(edge: .bottom))
                .environment(authModel)
            }
        } else {
            AuthLoginView()
                .environment(authModel)
                .transition(.move(edge: .bottom))
        }
    }
}

#Preview {
    ContentView()
}
