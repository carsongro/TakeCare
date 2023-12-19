//
//  AppTabView.swift
//  TakeCare
//
//  Created by Carson Gross on 9/29/23.
//

import SwiftUI

struct AppTabView: View {
    @Environment(Navigator.self) private var navigator
    @Environment(AuthModel.self) private var authModel
    
    var body: some View {
        @Bindable var navigator = navigator
        
        TabView(selection: $navigator.selection) {
            ForEach(AppScreen.allCases) { screen in
                screen.destination
                    .tag(screen as AppScreen?)
                    .tabItem { screen.label }
            }
        }
        .environment(authModel)
    }
}

#Preview {
    AppTabView()
        .environment(AuthModel())
        .environment(Navigator.shared)
}
