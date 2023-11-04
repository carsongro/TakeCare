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
        HStack {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text(task.title)
                        .font(.headline)
                    
                    if let notes = task.notes {
                        Text(notes)
                            .lineLimit(2)
                            .accessibility(label: Text("Task notes: \(notes)", comment: "Accessibility label containing the full task notes"))
                    }
                    if let completionDate = task.completionDate {
                        switch task.repeatInterval {
                        case .never:
                            Text("\(completionDate.formatted(date: .abbreviated, time: .shortened))")
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        case .daily:
                            Text("Repeats \(task.repeatInterval.rawValue.lowercased()) at \(completionDate.formatted(date: .omitted, time: .shortened))")
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
                
                Spacer(minLength: 0)
            }
        }
        .contentShape(Rectangle())
        .font(.subheadline)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    ListTaskRow(task: PreviewData.previewListTask)
}
