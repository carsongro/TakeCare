//
//  Navigator.swift
//  TakeCare
//
//  Created by Carson Gross on 12/4/23.
//

import Foundation

@Observable
final class Navigator {
    public static let shared = Navigator()
    
    public var selection: AppScreen?
    
    private init() { }
    
    public func openAppScreen(_ appScreen: AppScreen) {
        selection = appScreen
    }
}
