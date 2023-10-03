//
//  AppSidebarList.swift
//  TakeCare
//
//  Created by Carson Gross on 10/2/23.
//

import SwiftUI

struct AppSidebarList: View {
    @Binding var selection: AppScreen?

    var body: some View {
        List(AppScreen.allCases, selection: $selection) { screen in
            NavigationLink(value: screen) {
                screen.label
            }
        }
        .navigationTitle("TakeCare")
    }
}

#Preview {
    NavigationSplitView {
        AppSidebarList(selection: .constant(.lists))
    } detail: {
        Text("Sidebar")
    }
}
