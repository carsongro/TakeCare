//
//  TodoTaskRow.swift
//  TakeCare
//
//  Created by Carson Gross on 10/16/23.
//

import SwiftUI

struct TodoTaskRow: View {
    
    var task: ListTask
    @State var isCompleted: Bool
    let interactionDisabled: Bool // Provides a way to disable interaction without a visual indication of being disabled
    
    var tapHandler: ((Bool) -> Void)?
    
    var body: some View {
        if interactionDisabled {
            rowView
        } else {
            Button {
                isCompleted.toggle()
                tapHandler?(isCompleted)
            } label: {
                rowView
            }
            .sensoryFeedback(.impact, trigger: isCompleted)
        }
    }
    
    struct checkIndicator: View {
        var isCompleted: Bool
        
        var body: some View {
            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .foregroundStyle(.accent)
                    .accessibilityLabel(Text("Completed"))
            } else {
                Image(systemName: "circle")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .foregroundStyle(.accent)
                    .accessibilityLabel(Text("Not complete"))
            }
        }
    }
    
    var rowView: some View {
        HStack {
            checkIndicator(isCompleted: isCompleted)
            
            ListTaskRow(task: task)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    TodoTaskRow(
        task: PreviewData.previewListTask,
        isCompleted: false,
        interactionDisabled: false
    )
}
