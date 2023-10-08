//
//  PreviewData.swift
//  TakeCare
//
//  Created by Carson Gross on 10/8/23.
//

import Foundation

final class PreviewData {
    static let previewListTask = ListTask(
        id: UUID().uuidString,
        title: "Go for walk",
        notes: "Walk around outside?",
        completionDate: Date(),
        repeatInterval: .never
    )
    
    static let previewTakeCareList = TakeCareList(
        id: nil,
        ownerID: "",
        name: "Carson's list",
        description: "Description for this list.",
        recipient: User(
                id: UUID().uuidString,
                displayName: "Carson Gross",
                email: "test@test.com",
                photoURL: nil
            ),
        tasks: [
            ListTask(
                id: UUID().uuidString,
                title: "Go for walk",
                notes: "Walk around outside?",
                completionDate: nil,
                repeatInterval: .never
            )
        ],
        photoURL: nil,
        isActive: false
    )
}