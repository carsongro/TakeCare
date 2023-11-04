//
//  ProgressTasksList.swift
//  TakeCare
//
//  Created by Carson Gross on 10/21/23.
//

import SwiftUI

struct ProgressTasksList: View {
    @Binding var list: TakeCareList
    
    var body: some View {
        ForEach(list.tasks, id: \.self) { task in
            TodoTaskRow(
                task: task,
                isCompleted: task.isCompleted,
                interactionDisabled: true
            )
        }
    }
}

#Preview {
    ProgressTasksList(list: .constant(PreviewData.previewTakeCareList))
}
