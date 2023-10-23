//
//  TodoModel.swift
//  TakeCare
//
//  Created by Carson Gross on 10/14/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

/// A model for todo lists
@Observable final class TodoModel: @unchecked Sendable {
    var lists = [TakeCareList]()
    var searchText = ""
    var didFetchLists = false
    
    private enum TodoError: Error {
        case listNotFound
        case taskNotFound
    }
    
    init() {
        Task {
            await fetchLists()
        }
    }
    
    func fetchLists(animated: Bool = true) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        do {
            let listRef = FieldPath(["recipient", "id"])
            let updatedLists = try await Firestore.firestore().collection("lists").whereField(listRef, isEqualTo: uid).getDocuments().documents.compactMap { try $0.data(as: TakeCareList.self) }

            Task { @MainActor in
                if animated {
                    withAnimation {
                        self.lists = updatedLists
                        didFetchLists = true
                    }
                } else {
                    self.lists = updatedLists
                    didFetchLists = true
                }
            }
        } catch {
            print(error.localizedDescription)
            didFetchLists = true
        }
    }
    
    @discardableResult
    func updateListTask(list: TakeCareList, task: ListTask, isCompleted: Bool) throws -> TakeCareList {
        guard let listID = list.id else { throw TodoError.listNotFound }
        
        let updatedTask = ListTask(
            id: task.id,
            title: task.title,
            notes: task.notes,
            completionDate: task.completionDate,
            repeatInterval: task.repeatInterval,
            isCompleted: isCompleted
        )
        
        var tasks = list.tasks
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { throw TodoError.taskNotFound }
        tasks[index] = updatedTask
        
        let updatedList = TakeCareList(
            ownerID: list.ownerID,
            name: list.name,
            description: list.description,
            recipient: list.recipient,
            tasks: tasks,
            photoURL: list.photoURL,
            isActive: list.isActive
        )
        
        let docRef = Firestore.firestore().collection("lists").document(listID)
        try docRef.setData(from: updatedList)
        
        return updatedList
    }
}
