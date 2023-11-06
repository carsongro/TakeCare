//
//  ComparableTime.swift
//  TakeCare
//
//  Created by Carson Gross on 11/5/23.
//

import Foundation

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
