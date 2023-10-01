//
//  TCTabView.swift
//  TakeCare
//
//  Created by Carson Gross on 9/29/23.
//

import SwiftUI

struct TCTabView: View {
    
    var body: some View {
        TabView {
            TCProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}

#Preview {
    TCTabView()
        .environment(TCAuthViewModel())
}
