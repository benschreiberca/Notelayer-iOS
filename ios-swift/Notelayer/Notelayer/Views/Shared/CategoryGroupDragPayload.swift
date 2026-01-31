import Foundation
import SwiftUI
import UniformTypeIdentifiers

/// Drag payload for reordering category groups (including Uncategorized).
struct CategoryGroupDragPayload: Codable, Hashable, Transferable {
    let groupId: String

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .notelayerCategoryGroupDragPayload)
    }
}

extension UTType {
    static let notelayerCategoryGroupDragPayload = UTType(exportedAs: "com.notelayer.categorygroup.dragpayload")
}
