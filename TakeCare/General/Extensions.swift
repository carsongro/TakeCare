//
//  Extensions.swift
//  TakeCare
//
//  Created by Carson Gross on 10/1/23.
//

import SwiftUI

#if canImport(UIKit)
extension View {
    @MainActor 
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

struct PrefersTabNavigationEnvironmentKey: EnvironmentKey {
    static var defaultValue: Bool = false
}

extension EnvironmentValues {
    var prefersTabNavigation: Bool {
        get { self[PrefersTabNavigationEnvironmentKey.self] }
        set { self[PrefersTabNavigationEnvironmentKey.self] = newValue }
    }
}

#if os(iOS)
extension PrefersTabNavigationEnvironmentKey: UITraitBridgedEnvironmentKey {
    static func read(from traitCollection: UITraitCollection) -> Bool {
        return traitCollection.userInterfaceIdiom == .phone || traitCollection.userInterfaceIdiom == .tv
    }
    
    static func write(to mutableTraits: inout UIMutableTraits, value: Bool) {
        // Do not write.
    }
}
#endif

final class ComparableTime: Comparable, Equatable {
    private let time: Date
    
    init(_ date: Date) {
        let calendar = Calendar.current
        
        let components = calendar.dateComponents([.hour, .minute], from: date)
        
        if let time = calendar.date(byAdding: components, to: Date(timeIntervalSinceReferenceDate: 0)) {
            self.time = time
        } else {
            time = Date(timeIntervalSinceReferenceDate: 0)
        }
    }
    
    static func == (lhs: ComparableTime, rhs: ComparableTime) -> Bool {
        lhs.time == rhs.time
    }
    
    static func < (lhs: ComparableTime, rhs: ComparableTime) -> Bool {
        lhs.time < rhs.time
    }
    
    static func > (lhs: ComparableTime, rhs: ComparableTime) -> Bool {
        lhs.time > rhs.time
    }
    
    static func <= (lhs: ComparableTime, rhs: ComparableTime) -> Bool {
        lhs.time <= rhs.time
    }
    
    static func >= (lhs: ComparableTime, rhs: ComparableTime) -> Bool {
        lhs.time >= rhs.time
    }
}

extension Date {
    var comparableTime: ComparableTime {
        ComparableTime(self)
    }
}
