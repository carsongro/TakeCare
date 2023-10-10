//
//  AppDetailColumn.swift
//  TakeCare
//
//  Created by Carson Gross on 10/2/23.
//

import SwiftUI

struct AppDetailColumn: View {
    var screen: AppScreen?
    
    var body: some View {
        Group {
            if let screen {
                screen.destination
            } else {
                ContentUnavailableView("Select an list", systemImage: "list.bullet", description: Text("Pick something from the list"))
            }
        }
    }
}

#Preview {
    AppDetailColumn()
}
