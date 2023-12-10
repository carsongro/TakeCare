//
//  TakeCareApp.swift
//  TakeCare
//
//  Created by Carson Gross on 9/27/23.
//

import AppIntents
import SwiftUI
import Firebase
import IoImage

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        return true
    }
}

@main
struct TakeCareApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        AppDependencyManager.shared.add(dependency: FirebaseManager.shared)
        AppDependencyManager.shared.add(dependency: Navigator.shared)
        AppDependencyManager.shared.add(dependency: IoImageLoader.shared)
                                            
        TakeCareShortcuts.updateAppShortcutParameters()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .dynamicTypeSize(...DynamicTypeSize.accessibility3)
        }
    }
}
