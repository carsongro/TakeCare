//
//  AppScreen.swift
//  TakeCare
//
//  Created by Carson Gross on 10/2/23.
//

import SwiftUI

enum AppScreen: Codable, Hashable, Identifiable, CaseIterable {
    case lists
    case todo
    case account
    
    var id: AppScreen { self }
}

extension AppScreen {
    @ViewBuilder
    var label: some View {
        switch self {
        case .lists:
            Label("Lists", systemImage: "list.bullet")
        case .todo:
            Label("To-Do", systemImage: "text.badge.checkmark")
        case .account:
            Label("Account", systemImage: "person")
        }
    }
    
    @ViewBuilder
    var destination: some View {
        switch self {
        case .lists:
            ListsNavigationStack()
        case .todo:
            TodoNavigationStack()
        case .account:
            AccountNavigationStack()
        }
    }
}
