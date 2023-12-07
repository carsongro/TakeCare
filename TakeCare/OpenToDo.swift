//
//  OpenToDo.swift
//  TakeCare
//
//  Created by Carson Gross on 12/4/23.
//

import Foundation
import AppIntents

struct OpenToDo: AppIntent {
    static var title: LocalizedStringResource = "Open To Do"
    
    @MainActor
    func perform() async throws -> some IntentResult {
        Navigator.shared.openAppScreen(.todo)
        return .result()
    }
    
    static var openAppWhenRun: Bool = true
}
