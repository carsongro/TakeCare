//
//  TCAuthCheckView.swift
//  TakeCare
//
//  Created by Carson Gross on 9/29/23.
//

import SwiftUI

struct ContentView: View {
    @State private var authModel = AuthModel.shared
    @State private var todoModel = TodoModel()
    @State private var listsModel = ListsModel()
    
    @State private var selection: AppScreen? = .lists
    
    @Environment(\.prefersTabNavigation) private var prefersTabNavigation
    
    var body: some View {
        Group {
            if authModel.isSignedIn {
                if prefersTabNavigation {
                    AppTabView(selection: $selection)
                        .transition(.move(edge: .bottom))
                } else {
                    NavigationSplitView {
                        AppSidebarList(selection: $selection)
                    } detail: {
                        AppDetailColumn(screen: selection)
                    }
                    .transition(.move(edge: .bottom))
                }
            } else {
                AuthLoginView()
                    .transition(.move(edge: .bottom))
            }
        }
        .environment(authModel)
        .environment(todoModel)
        .environment(listsModel)
        .onChange(of: Navigator.shared.selection) { oldValue, newValue in
            selection = newValue
        }
    }
}

#Preview {
    ContentView()
}
