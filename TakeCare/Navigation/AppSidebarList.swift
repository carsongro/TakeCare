//
//  AppSidebarList.swift
//  TakeCare
//
//  Created by Carson Gross on 10/2/23.
//

import SwiftUI

struct AppSidebarList: View {
    @Environment(AuthModel.self) private var authModel
    @Environment(Navigator.self) private var navigator
    @State private var showingProfile = false

    var body: some View {
        @Bindable var navigator = navigator
        List(AppScreen.allCases, selection: $navigator.selection) { screen in
            NavigationLink(value: screen) {
                screen.label
            }
        }
        .navigationTitle("TakeCare")
        .toolbar {
            Button {
                showingProfile = true
            } label: {
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .fontWeight(.semibold)
            }
            .accessibilityLabel(Text("View Profile"))
        }
        .sheet(isPresented: $showingProfile) {
            ProfileNavigationStack()
                .environment(authModel)
        }
    }
}

#Preview {
    NavigationSplitView {
        AppSidebarList()
            .environment(Navigator.shared)
    } detail: {
        Text("Sidebar")
    }
}
