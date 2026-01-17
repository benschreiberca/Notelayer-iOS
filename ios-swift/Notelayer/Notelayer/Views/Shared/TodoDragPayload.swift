import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct TodoDragPayload: Codable, Hashable, Transferable {
    let taskId: String
    /// The group identifier in the active mode from which the drag originated (e.g. categoryId, priorityRawValue, dateBucketRawValue, "all").
    let sourceGroupId: String

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .notelayerTodoDragPayload)
    }
}

extension UTType {
    static let notelayerTodoDragPayload = UTType(exportedAs: "com.notelayer.todo.dragpayload")
}

