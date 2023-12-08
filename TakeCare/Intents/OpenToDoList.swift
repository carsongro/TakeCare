//
//  OpenToDoList.swift
//  TakeCare
//
//  Created by Carson Gross on 12/6/23.
//

import Foundation
import AppIntents

struct OpenToDoList: AppIntent {
    
    @Parameter(title: "list")
    var list: TakeCareToDoListEntity?
    
    static var title: LocalizedStringResource = "Open To Do List"
    
    static var openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult {
        let selectedList: TakeCareToDoListEntity
        if let list = list {
            selectedList = list
        } else {
            let lists = try await FirebaseManager.shared.userTodoLists()
            let imageDataMap = await FirebaseManager.shared.imagesMap(from: lists)
            
            let listEntities: [TakeCareToDoListEntity] = lists.compactMap {
                guard let id = $0.id else { return nil }
                
                return TakeCareToDoListEntity(
                    id: id,
                    listName: $0.name,
                    listDescription: $0.description ?? "",
                    imageData: imageDataMap[id, default: nil]
                )
            }
            
            selectedList = try await $list.requestDisambiguation(
                among: listEntities,
                dialog: "Which list would you like to open?"
            )
        }
        Navigator.shared.openList(selectedList)
        return .result()
    }
    
    static var parameterSummary: some ParameterSummary {
        Summary("Open \(\.$list)")
    }
    
    init() {}
    
    init(list: TakeCareToDoListEntity) {
        self.list = list
    }
}
