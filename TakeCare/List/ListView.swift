//
//  ListListView.swift
//  TakeCare
//
//  Created by Carson Gross on 10/4/23.
//

import SwiftUI

struct ListView: View {
    var list: TakeCareList
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    ListView(
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
