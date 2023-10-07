//
//  ListTask.swift
//  TakeCare
//
//  Created by Carson Gross on 10/4/23.
//

import Firebase
import FirebaseFirestoreSwift
import Foundation

struct ListTask: Codable, Hashable {
    let name: String
    let notes: String?
    let completionDate: Date?
}
