//
//  ProgressModel.swift
//  TakeCare
//
//  Created by Carson Gross on 10/21/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

@Observable final class ProgressModel: @unchecked Sendable {
    var lists = [TakeCareList]()
    var searchText = ""
    var didFetchLists = false
    var canShowDetail = true
    
    init() {
        Task {
            await fetchLists()
        }
        registerNotificationObserver()
    }
    
    func fetchLists() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        do {
            let updatedLists = try await Firestore.firestore().collection("lists").whereField("ownerID", isEqualTo: uid).whereField("isActive", isEqualTo: true).getDocuments().documents.compactMap { try $0.data(as: TakeCareList.self) } // TODO: Handle isActive

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
    
    private func registerNotificationObserver() {
        // If a user updates, creates, deletes, etc. a list from the lists tab, we refresh our lists here
        NotificationCenter.default.addObserver(self, selector: #selector(updateLists), name: Notification.Name("UpdatedLists"), object: nil)
    }
    
    @objc private func updateLists() {
        Task {
            await fetchLists()
        }
    }
}
