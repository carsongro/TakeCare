//
//  TakeCareList.swift
//  TakeCare
//
//  Created by Carson Gross on 10/4/23.
//

import Firebase
import FirebaseFirestoreSwift
import Foundation


struct TakeCareList: Codable, Hashable, Equatable, Identifiable {
    @DocumentID var id: String?
    let ownerID: String
    let name: String
    let recipientID: String?
    let tasks: [ListTask]
    
    static func == (lhs: TakeCareList, rhs: TakeCareList) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
