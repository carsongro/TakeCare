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
        
        Group {
            if authModel.isSignedIn {
                if prefersTabNavigation {
                    AppTabView(selection: $navigator.selection)
                        .environment(authModel)
                } else {
                    NavigationSplitView {
                        AppSidebarList(selection: $navigator.selection)
                    } detail: {
                        AppDetailColumn(screen: navigator.selection)
                    }
                    .environment(authModel)
                }
            }
        }
        .sheet(isPresented: .constant(!authModel.isSignedIn)) {
            AuthLoginView()
                .environment(authModel)
                .interactiveDismissDisabled()
        }
    }
}

#Preview {
    ContentView()
}
