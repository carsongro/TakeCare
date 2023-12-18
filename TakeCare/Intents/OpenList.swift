//
//  OpenList.swift
//  TakeCare
//
//  Created by Carson Gross on 12/18/23.
//

import Foundation
import AppIntents

struct OpenList: AppIntent {
    
    @Parameter(title: "list")
    var list: TakeCareListEntity?
    
    static var title: LocalizedStringResource = "Check List Progress"
    
    static var openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some ProvidesDialog {
        let selectedList: TakeCareListEntity
        if let list = list {
            selectedList = list
        } else {
            let lists = try await FirebaseManager.shared.userLists(isRecipient: false)
            let imageDataMap = await FirebaseManager.shared.imagesMap(from: lists)
            
            let listEntities: [TakeCareListEntity] = lists.compactMap {
                guard let id = $0.id else { return nil }
                
                return TakeCareListEntity(
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
        return .result(dialog: "Okay, opening the list for \(selectedList.listName).")
    }
    
    static var parameterSummary: some ParameterSummary {
        Summary("Open \(\.$list)")
    }
    
    init() {}
    
    init(list: TakeCareListEntity) {
        self.list = list
    }
}
