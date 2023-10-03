//
//  AppTabView.swift
//  TakeCare
//
//  Created by Carson Gross on 9/29/23.
//

import SwiftUI

struct AppTabView: View {
    @Binding var selection: AppScreen?
    @Environment(TCAuthViewModel.self) private var viewModel
    
    var body: some View {
        TabView(selection: $selection) {
            ForEach(AppScreen.allCases) { screen in
                screen.destination
                    .tag(screen as AppScreen?)
                    .tabItem { screen.label }
            }
        }
        .environment(viewModel)
    }
}

#Preview {
    AppTabView(selection: .constant(.lists))
        .environment(TCAuthViewModel())
}
