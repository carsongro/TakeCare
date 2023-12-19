//
//  Navigator.swift
//  TakeCare
//
//  Created by Carson Gross on 12/4/23.
//

import SwiftUI

@MainActor
@Observable
final class Navigator: @unchecked Sendable {
    public static let shared = Navigator()
    
    public var selection: AppScreen? = .lists
    
    public var todoPath = [TakeCareList]()
    public var listsPath = [TakeCareList]()
    
    private init() { }
    
    public func openAppScreen(_ appScreen: AppScreen) {
        switch appScreen {
        case .lists:
            listsPath.removeLast(listsPath.count - 1)
        case .todo:
            todoPath.removeLast(listsPath.count - 1)
        }
        selection = appScreen
    }
    
    public func openToDoList(_ list: TakeCareToDoListEntity) {
        selection = .todo
        
        Task {
            do {
                let list = try await FirebaseManager.shared.getList(for: list.id)
                todoPath.append(list)
            } catch {
                
            }
        }
    }
    
    public func openList(_ list: TakeCareListEntity) {
        selection = .lists
        
        Task {
            do {
                let list = try await FirebaseManager.shared.getList(for: list.id)
                listsPath.append(list)
            } catch {
                
            }
        }
    }
}
