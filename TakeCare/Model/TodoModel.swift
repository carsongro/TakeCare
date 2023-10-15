//
//  TodoModel.swift
//  TakeCare
//
//  Created by Carson Gross on 10/14/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

@Observable final class TodoModel: @unchecked Sendable {
    var lists = [TakeCareList]()
    var searchText = ""
    var didFetchLists = false
    
    init() {
        Task {
            await fetchLists()
        }
    }
    
    func fetchLists() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        do {
            let listRef = FieldPath(["recipient", "id"])
            let updatedLists = try await Firestore.firestore().collection("lists").whereField(listRef, isEqualTo: uid).getDocuments().documents.compactMap { try $0.data(as: TakeCareList.self) }

            Task { @MainActor in
                withAnimation {
                    self.lists = updatedLists
                    didFetchLists = true
                }
            }
        } catch {
            print(error.localizedDescription)
            didFetchLists = true
        }
    }
}
