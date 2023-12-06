//
//  ListDetailHeader.swift
//  TakeCare
//
//  Created by Carson Gross on 10/21/23.
//

import SwiftUI
import IoImage

struct ListDetailHeader: View {
    @Environment(\.prefersTabNavigation) private var prefersTabNavigation
    @Binding var list: TakeCareList
    
    var width: CGFloat
    
    var proportionalWidth: CGFloat { width * (prefersTabNavigation ? 2/3 : 1/4) }
    
    @State private var selectedUserID: String?
    @State private var showUserSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            let imageClipShape = RoundedRectangle(cornerRadius: 10, style: .continuous)
            IoImageView(url: URL(string: list.photoURL ?? ""))
                .resizable()
                .placeholder {
                    Rectangle()
                        .foregroundStyle(Color(.secondarySystemBackground))
                        .frame(width: proportionalWidth, height: proportionalWidth)
                        .clipShape(imageClipShape)
                        .shadow(color: .black.opacity(0.3), radius: 5, y: 8)
                        .overlay {
                            Image(systemName: "list.bullet")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding()
                        }
                }
                .aspectRatio(contentMode: .fill)
                .frame(width: proportionalWidth, height: proportionalWidth)
                .contentShape(imageClipShape)
                .clipShape(imageClipShape)
                .frame(maxWidth: .infinity)
                .shadow(color: .black.opacity(0.3), radius: 6, y: 8)
                .accessibilityHidden(true)
            
            VStack(spacing: 5) {
                Text(list.name)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                
                Button {
                    selectedUserID = list.ownerID
                } label: {
                    Text(list.ownerName)
                        .font(.title3)
                        .foregroundStyle(.accent)
                }
                
                Text(list.isActive ? "Currently Active" : "Not Active")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fontWeight(.semibold)
                    .accessibilityLabel(Text("List status: \(list.isActive ? "Currently Active" : "Not Active")"))
            }
            .frame(maxWidth: .infinity)
            
            Text(list.description ?? "")
                .font(.callout)
                .foregroundStyle(.secondary)
                .accessibilityLabel(Text("Description: \(list.description ?? "No description provided")"))
        }
        .onChange(of: selectedUserID, { oldValue, newValue in
            if newValue != nil {
                showUserSheet = true
            }
        })
        .sheet(isPresented: $showUserSheet) {
            selectedUserID = nil
        } content: {
            if let selectedUserID {
                UserProfileView(userID: selectedUserID)
                    .presentationDetents([.medium, .large])
            }
        }
    }
}

#Preview {
    ListDetailHeader(list: .constant(PreviewData.previewTakeCareList), width: 300)
}
