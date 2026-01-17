//
//  TaskSorting.swift
//  Notelayer
//
//  Task sorting utilities matching web app logic
//

import Foundation

extension Array where Element == Task {
    /// Sort tasks by priority (High > Medium > Low > Deferred), then by createdAt (newest first)
    func sortedByPriorityThenDate() -> [Task] {
        sorted { a, b in
            let priorityDiff = a.priority.sortOrder - b.priority.sortOrder
            if priorityDiff != 0 { return priorityDiff < 0 }
            return a.createdAt > b.createdAt
        }
    }
    
    /// Sort tasks by createdAt only (newest first)
    func sortedByDate() -> [Task] {
        sorted { $0.createdAt > $1.createdAt }
    }
}
