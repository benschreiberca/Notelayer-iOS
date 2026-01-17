//
//  IDGenerator.swift
//  Notelayer
//
//  ID generation matching web app (Math.random().toString(36).slice(2, 11))
//

import Foundation

enum IDGenerator {
    static func generate() -> String {
        // Web app uses: Math.random().toString(36).slice(2, 11)
        // Swift equivalent: use UUID and take first 9 chars
        // For better compatibility, use UUID but format similarly
        return UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased().prefix(9).description
    }
}
