//
//  ListTaskRow.swift
//  TakeCare
//
//  Created by Carson Gross on 10/6/23.
//

import SwiftUI

struct ListTaskRow: View {
    
    var task: ListTask
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text(task.name)
                    .font(.headline)
                
                if let notes = task.notes {
                    Text(notes)
                        .lineLimit(2)
                        .accessibility(label: Text("Task notes: \(notes)", comment: "Accessibility label containing the full task notes"))
                }
                
                Text(task.completionDate?.formatted(date: .abbreviated, time: .shortened) ?? "")
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer(minLength: 0)
        }
        .font(.subheadline)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    ListTaskRow(
        task: ListTask(
            name: "Feed Cat",
            notes: "Make sure to give her the right amount of food",
            completionDate: Date.now
        )
    )
}
