//
//  TakeCareList.swift
//  TakeCare
//
//  Created by Carson Gross on 10/4/23.
//

import Firebase
@preconcurrency import FirebaseFirestoreSwift
import Foundation


struct TakeCareList: Codable, Hashable, Identifiable, Sendable, Equatable {
    @DocumentID var id: String?
    let ownerID: String
    let name: String
    let description: String?
    let recipientID: String?
    let tasks: [ListTask]
    let photoURL: String?
    let hasRecipientTaskNotifications: Bool
    
    static func == (lhs: TakeCareList, rhs: TakeCareList) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.description == rhs.description &&
        lhs.recipientID == rhs.recipientID &&
        lhs.tasks == rhs.tasks &&
        lhs.photoURL == rhs.photoURL &&
        lhs.hasRecipientTaskNotifications == rhs.hasRecipientTaskNotifications
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension TakeCareList {
    func matches(_ string: String) -> Bool {
        string.isEmpty ||
        name.localizedCaseInsensitiveContains(string)
    }
}
