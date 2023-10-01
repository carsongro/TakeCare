//
//  User.swift
//  TakeCare
//
//  Created by Carson Gross on 9/29/23.
//

import Foundation

struct User: Codable, Identifiable {
    let id: String
    let displayName: String
    let email: String
    var photoURL: String?
}

extension User {
    static var previewUser = User(
        id: UUID().uuidString,
        displayName: "Carson Gross",
        email: "text@example.com",
        photoURL: ""
    )
}
