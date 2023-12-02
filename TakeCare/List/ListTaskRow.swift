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
                            .accessibilityLabel(Text("Task notes: \(notes)"))
                    }
                    
                    switch task.repeatInterval {
                    case .never:
                        if let completionDate = task.completionDate?.formatted(date: .abbreviated, time: .shortened) {
                            Text("\(completionDate)")
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                                .accessibilityLabel(Text("Completion date: \(completionDate)"))
                        }
                    case .daily:
                        Group {
                            if let completionDate = task.completionDate {
                                if Calendar.current.isDateInToday(completionDate) || completionDate < Date.now {
                                    Text("Repeats \(task.repeatInterval.rawValue.lowercased()) at \(completionDate.formatted(date: .omitted, time: .shortened))")
                                } else {
                                    Text("Repeats \(task.repeatInterval.rawValue.lowercased()) starting \(completionDate.formatted(date: .abbreviated, time: .shortened))")
                                }
                            } else {
                                Text("Repeats \(task.repeatInterval.rawValue.lowercased())")
                            }
                        }
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
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
