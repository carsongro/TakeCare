//
//  TakeCareList.swift
//  TakeCare
//
//  Created by Carson Gross on 10/4/23.
//

import Firebase
import FirebaseFirestoreSwift
import Foundation


struct TakeCareList: Codable, Hashable, Equatable, Identifiable, @unchecked Sendable {
    @DocumentID var id: String?
    let ownerID: String
    let name: String
    let description: String?
    let recipient: User?
    let tasks: [ListTask]
    let photoURL: String?
    let isActive: Bool
    
    static func == (lhs: TakeCareList, rhs: TakeCareList) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
