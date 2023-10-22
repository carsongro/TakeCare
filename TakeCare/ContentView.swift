//
//  TCAuthCheckView.swift
//  TakeCare
//
//  Created by Carson Gross on 9/29/23.
//

import SwiftUI

struct ContentView: View {
    @State private var authModel = AuthModel()
    @State private var selection: AppScreen? = .progress
    
    @Environment(\.prefersTabNavigation) private var prefersTabNavigation
    
    var body: some View {
        if authModel.isSignedIn {
            if prefersTabNavigation {
                AppTabView(selection: $selection)
                    .environment(authModel)
                    .transition(.move(edge: .bottom))
            } else {
                NavigationSplitView {
                    AppSidebarList(selection: $selection)
                } detail: {
                    AppDetailColumn(screen: selection)
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
