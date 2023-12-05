//
//  TakeCareShortcuts.swift
//  TakeCare
//
//  Created by Carson Gross on 12/4/23.
//

import Foundation
import AppIntents

class TakeCareShortcuts: AppShortcutsProvider {
    static var shortcutTileColor = ShortcutTileColor.grape
    
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OpenToDo(),
            phrases: [
                "Open To Do in \(.applicationName)",
                "Open \(.applicationName) To Do",
            ],
            shortTitle: "Open To Do",
            systemImageName: "checklist"
        )
    }
}
