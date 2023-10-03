//
//  TodoNavigationStack.swift
//  TakeCare
//
//  Created by Carson Gross on 10/2/23.
//

import SwiftUI

struct TodoNavigationStack: View {
    var body: some View {
        NavigationStack {
            Text("Todo")
                .navigationTitle("Todo")
        }
    }
}

#Preview {
    TodoNavigationStack()
}
