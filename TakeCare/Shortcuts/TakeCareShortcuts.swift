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
        
        AppShortcut(
            intent: OpenToDoList(),
            phrases: [
                "Open \(\.$list) to do list with \(.applicationName)",
                "Open a \(.applicationName) to do list"
            ],
            shortTitle: "Open To Do List",
            systemImageName: "list.bullet"
        )
        
        AppShortcut(
            intent: OpenList(),
            phrases: [
                "Open \(\.$list) list with \(.applicationName)",
                "Open a \(.applicationName) list",
                "Check progress for a \(.applicationName) list",
                "Check progress for \(\.$list) list with \(.applicationName)"
            ],
            shortTitle: "Check List Progress",
            systemImageName: "checklist.checked"
        )
    }
}
