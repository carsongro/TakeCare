//
//  TCAuthCheckView.swift
//  TakeCare
//
//  Created by Carson Gross on 9/29/23.
//

import SwiftUI

struct TCAuthCheckView: View {
    @State private var viewModel = TCAuthViewModel()
    
    var body: some View {
        Group {
            if viewModel.userSession == nil {
                TCLoginView()
                    .environment(viewModel)
            } else {
                TCTabView()
                    .environment(viewModel)
            }
        }
    }
}

#Preview {
    TCAuthCheckView()
}
