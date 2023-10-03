//
//  ListsNavigationStack.swift
//  TakeCare
//
//  Created by Carson Gross on 10/2/23.
//

import SwiftUI

struct ListsNavigationStack: View {
    var body: some View {
        NavigationStack {
            Text("Lists")
                .navigationTitle("Lists")
        }
    }
}

#Preview {
    ListsNavigationStack()
}
