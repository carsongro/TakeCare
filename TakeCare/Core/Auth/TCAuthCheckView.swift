//
//  TCAuthCheckView.swift
//  TakeCare
//
//  Created by Carson Gross on 9/29/23.
//

import SwiftUI

struct TCAuthCheckView: View {
    @State private var authManager = TCAuthManager()
    
    var body: some View {
        Group {
            if authManager.userSession == nil {
                TCLoginView()
                    .environment(authManager)
            } else {
                TCTabView()
                    .environment(authManager)
            }
        }
    }
}

#Preview {
    TCAuthCheckView()
}
