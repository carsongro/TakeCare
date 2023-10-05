//
//  ListRow.swift
//  TakeCare
//
//  Created by Carson Gross on 10/4/23.
//

import SwiftUI

struct ListRow: View {
    var list: TakeCareList
    
    var body: some View {
        HStack(alignment: .top) {
            let imageClipShape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            Image(systemName: "photo.fill")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 60, height: 60)
                .clipShape(imageClipShape)
                .accessibilityHidden(true)
            
            Text(list.name)
            
            Spacer(minLength: 0)
                
        }
    }
    
    var cornerRadius: Double {
        #if os(iOS)
        return 10
        #else
        return 4
        #endif
    }
}

#Preview {
    ListRow(
        list: TakeCareList(
            id: nil,
            ownerID: "",
            name: "Carson's list",
            recipientID: "",
            tasks: [
                ListTask(
                    name: "Go for walk",
                    notes: "Walk around outside?",
                    completionDate: nil
                )
            ]
        )
    )
}
