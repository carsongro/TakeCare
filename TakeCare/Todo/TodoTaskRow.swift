//
//  TodoTaskRow.swift
//  TakeCare
//
//  Created by Carson Gross on 10/16/23.
//

import SwiftUI

struct TodoTaskRow: View {
    
    var task: ListTask
    @State private var isCompleted: Bool
    let interactionDisabled: Bool // Provides a way to disable interaction without a visual indication of being disabled
    
    init(
        task: ListTask,
        isCompleted: Bool,
        interactionDisabled: Bool,
        tapHandler: ((Bool) -> Void)? = nil
    ) {
        self.task = task
        _isCompleted = State(initialValue: isCompleted)
        self.interactionDisabled = interactionDisabled
        self.tapHandler = tapHandler
    }
    
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
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .resizable()
                .frame(width: 25, height: 25)
                .foregroundStyle(.accent)
                .accessibilityLabel(Text(isCompleted ? "Completed" : "Not complete"))
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
