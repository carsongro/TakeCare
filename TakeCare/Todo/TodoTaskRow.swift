//
//  TodoTaskRow.swift
//  TakeCare
//
//  Created by Carson Gross on 10/16/23.
//

import SwiftUI

struct TodoTaskRow: View {
    
    @State var task: ListTask
    @State var isCompleted: Bool
    
    var tapHandler: (Bool) -> Void
    
    var body: some View {
        Button {
            isCompleted.toggle()
            tapHandler(isCompleted)
        } label: {
            HStack {
                checkIndicator(isCompleted: isCompleted)
                
                ListTaskRow(task: task)
            }
        }
        .sensoryFeedback(.impact, trigger: isCompleted)
    }
    
    struct checkIndicator: View {
        var isCompleted: Bool
        
        var body: some View {
            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .foregroundStyle(.accent)
            } else {
                Image(systemName: "circle")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .foregroundStyle(.accent)
            }
        }
    }
}

#Preview {
    TodoTaskRow(task: PreviewData.previewListTask, isCompleted: false) { _ in }
}
