//
//  ListRow.swift
//  TakeCare
//
//  Created by Carson Gross on 10/4/23.
//

import SwiftUI
import Kingfisher

struct ListRow: View {
    var list: TakeCareList
    
    var body: some View {
        HStack {
            KFImage(URL(string: list.photoURL ?? ""))
                .resizable()
                .placeholder {
                    ZStack {
                        Rectangle()
                            .listRowImage()
                            .foregroundStyle(Color(.secondarySystemBackground))
                        
                        Image(systemName: "list.bullet")
                            .resizable()
                            .padding()
                            .fontWeight(.light)
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(.secondary)
                    }
                    .listRowImage()
                    .accessibilityHidden(true)
                }
                .listRowImage()
                .accessibilityHidden(true)
            
            VStack(alignment: .leading) {
                Text(list.name)
                    .font(.headline)
                
                if let description = list.description {
                    Text(description)
                        .lineLimit(1)
                        .accessibilityLabel(Text("Description: \(description)."))
                }
                
                if AuthModel.shared.currentUser == list.owner {
                    if let recipientName = list.recipient?.displayName {
                        Text(recipientName)
                            .lineLimit(1)
                            .accessibilityLabel(Text("Recipient: \(recipientName)."))
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text(list.owner.displayName)
                        .lineLimit(1)
                        .accessibilityLabel(Text("Owner: \(list.owner.displayName)."))
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer(minLength: 0)
            
            if list.isActive {
                ListIndicator(isCompleted: list.tasks.filter {
                    if let completionDate = $0.completionDate,
                       (completionDate <= Date.now ||
                        Calendar.current.isDateInToday(completionDate)) {
                        return true
                    } else if $0.completionDate == nil {
                        return true
                    } else {
                        return false
                    }
                }.allSatisfy { $0.isCompleted } && !list.tasks.filter {
                    if let completionDate = $0.completionDate,
                       (completionDate <= Date.now ||
                        Calendar.current.isDateInToday(completionDate)) {
                        return true
                    } else if $0.completionDate == nil {
                        return true
                    } else {
                        return false
                    }
                }.isEmpty)
            }
        }
        .font(.subheadline)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
    
    struct ListIndicator: View {
        let isCompleted: Bool
        
        var body: some View {
            Image(systemName: isCompleted ? "checkmark.circle" : "checklist")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 22, height: 22)
                .padding(.leading, 8)
                .foregroundStyle(isCompleted ? .green : .accentColor)
                .accessibilityLabel(Text(isCompleted ? "All of today's tasks completed" : "Today's tasks not complete"))
        }
    }
}

struct ListRowImage: ViewModifier {
    func body(content: Content) -> some View {
        let imageClipShape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        content
            .aspectRatio(contentMode: .fill)
            .frame(width: 60, height: 60)
            .clipShape(imageClipShape)
            .contentShape(imageClipShape)
            .accessibilityHidden(true)
    }
    
    private var cornerRadius: Double { 10 }
}

extension View {
    func listRowImage() -> some View {
        modifier(ListRowImage())
    }
}

#Preview {
    ListRow(list: PreviewData.previewTakeCareList)
}
