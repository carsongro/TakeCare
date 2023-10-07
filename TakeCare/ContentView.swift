//
//  TCAuthCheckView.swift
//  TakeCare
//
//  Created by Carson Gross on 9/29/23.
//

import SwiftUI

struct ContentView: View {
    @State private var authModel = AuthModel()
    @State private var listsModel = ListsModel()
    @State private var selection: AppScreen? = .lists
    
    @Environment(\.prefersTabNavigation) private var prefersTabNavigation
    
    var body: some View {
        if authModel.userSession == nil {
            AuthLoginView()
                .environment(authModel)
                .environment(listsModel)
                .transition(.move(edge: .bottom))
        } else {
            if prefersTabNavigation {
                AppTabView(selection: $selection)
                    .environment(authModel)
                    .environment(listsModel)
                    .transition(.move(edge: .bottom))
            } else {
                NavigationSplitView {
                    AppSidebarList(selection: $selection)
                } detail: {
                    AppDetailColumn(screen: selection)
                }
                .transition(.move(edge: .bottom))
                .environment(authModel)
                .environment(listsModel)
            }
        }
    }
}

#Preview {
    ContentView()
}
