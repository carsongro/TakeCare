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
        repeatInterval: .daily,
        isCompleted: false,
        lastCompletionDate: nil
    )
    
    static let previewListTask2 = ListTask(
        id: UUID().uuidString,
        title: "Exercise",
        notes: "Move around",
        completionDate: Date(),
        repeatInterval: .never,
        isCompleted: true,
        lastCompletionDate: nil
    )
    
    static let previewTakeCareList = TakeCareList(
        ownerID: UUID().uuidString,
        ownerName: "Owner Name",
        name: "Carson's list",
        description: "This is the description for this list.",
        recipientID: UUID().uuidString,
        tasks: [
            previewListTask,
            previewListTask2
        ],
        photoURL: nil,
        hasRecipientTaskNotifications: true
    )
}
