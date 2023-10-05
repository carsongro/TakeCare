//
//  AppTabView.swift
//  TakeCare
//
//  Created by Carson Gross on 9/29/23.
//

import SwiftUI

struct AppTabView: View {
    @Binding var selection: AppScreen?
    @Environment(AuthModel.self) private var authModel
    @Environment(ListsModel.self) private var listsModel
    
    var body: some View {
        TabView(selection: $selection) {
            ForEach(AppScreen.allCases) { screen in
                screen.destination
                    .tag(screen as AppScreen?)
                    .tabItem { screen.label }
            }
        }
        .environment(authModel)
        .environment(listsModel)
    }
}

#Preview {
    AppTabView(selection: .constant(.lists))
        .environment(AuthModel())
}
