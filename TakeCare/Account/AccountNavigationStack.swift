//
//  AccountNavigationStack.swift
//  TakeCare
//
//  Created by Carson Gross on 10/2/23.
//

import SwiftUI

struct AccountNavigationStack: View {
    @Environment(TCAuthViewModel.self) private var viewModel
    
    var body: some View {
        NavigationStack {
            TCAccountView()
                .navigationTitle("Account")
                .environment(viewModel)
        }
    }
}

#Preview {
    AccountNavigationStack()
        .environment(TCAuthViewModel())
}
