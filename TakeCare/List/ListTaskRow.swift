//
//  ListTaskRow.swift
//  TakeCare
//
//  Created by Carson Gross on 10/6/23.
//

import SwiftUI

struct ListTaskRow: View {
    
    @State var task: ListTask
    
    var selectedTaskHandler: () -> Void
    
    var body: some View {
        Button {
            selectedTaskHandler()
        } label: {
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
                        Text("\(completionDate.formatted(date: .abbreviated, time: .shortened)), Repeats: \(task.repeatInterval.rawValue)")
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer(minLength: 0)
            }
            .font(.subheadline)
            .accessibilityElement(children: .combine)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ListTaskRow(task: PreviewData.previewListTask) { }
}
