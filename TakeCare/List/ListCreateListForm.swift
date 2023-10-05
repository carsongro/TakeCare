//
//  ListCreateListForm.swift
//  TakeCare
//
//  Created by Carson Gross on 10/4/23.
//

import SwiftUI

struct ListCreateListForm: View {
    @Environment(ListsModel.self) private var listsModel
    
    @State private var list = TakeCareList(
        id: nil,
        ownerID: "",
        name: "",
        recipientID: nil,
        tasks: []
    )
    
    var body: some View {
        Text("Create List")
    }
}

#Preview {
    ListCreateListForm()
        .environment(ListsModel())
}
