//
//  Navigator.swift
//  TakeCare
//
//  Created by Carson Gross on 12/4/23.
//

import SwiftUI

@Observable
final class Navigator: @unchecked Sendable {
    public static let shared = Navigator()
    
    public var selection: AppScreen?
    
    public var todoPath = [TakeCareList]()
    
    private init() { }
    
    public func openAppScreen(_ appScreen: AppScreen) {
        todoPath.removeAll()
        selection = appScreen
    }
    
    public func openList(_ list: TakeCareToDoListEntity) {
        selection = .todo
        
        Task {
            do {
                let list = try await FirebaseManager.shared.getList(for: list.id)
                todoPath.append(list)
            } catch {
                
            }
        }
    }
}
