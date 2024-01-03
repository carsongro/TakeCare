//
//  AppSidebarList.swift
//  TakeCare
//
//  Created by Carson Gross on 10/2/23.
//

import SwiftUI
import IoImage

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
                IoImageView(url: URL(string: AuthModel.shared.currentUser?.photoURL ?? ""))
                    .resizable()
                    .placeholder {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 35, height: 35)
                            .fontWeight(.semibold)
                    }
                    .clipShape(Circle())
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 35, height: 35)
            }
            .accessibilityLabel(Text("View Profile"))
        }
        .sheet(isPresented: $showingProfile) {
            AccountNavigationStack()
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
