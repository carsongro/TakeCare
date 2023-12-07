//
//  TCAuthCheckView.swift
//  TakeCare
//
//  Created by Carson Gross on 9/29/23.
//

import SwiftUI

struct ContentView: View {
    @State private var authModel = AuthModel.shared
    @State private var selection: AppScreen? = .lists
    
    @Environment(\.prefersTabNavigation) private var prefersTabNavigation
    
    var body: some View {
        Group {
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
        .onChange(of: Navigator.shared.selection) { oldValue, newValue in
            selection = newValue
        }
    }
}

#Preview {
    ContentView()
}
