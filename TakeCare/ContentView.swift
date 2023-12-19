//
//  TCAuthCheckView.swift
//  TakeCare
//
//  Created by Carson Gross on 9/29/23.
//

import SwiftUI

struct ContentView: View {
    @State private var todoModel = TodoModel()
    @State private var listsModel = ListsModel()
    
    @State private var selection: AppScreen? = .lists
    
    @Environment(\.prefersTabNavigation) private var prefersTabNavigation
    
    var body: some View {
        Group {
            if AuthModel.shared.isSignedIn {
                if prefersTabNavigation {
                    AppTabView()
                        .transition(.move(edge: .bottom))
                } else {
                    NavigationSplitView {
                        AppSidebarList()
                    } detail: {
                        AppDetailColumn(screen: Navigator.shared.selection)
                    }
                    .transition(.move(edge: .bottom))
                }
            } else {
                AuthLoginView()
                    .transition(.move(edge: .bottom))
            }
        }
        .environment(Navigator.shared)
        .environment(AuthModel.shared)
        .environment(todoModel)
        .environment(listsModel)
    }
}

#Preview {
    ContentView()
}
