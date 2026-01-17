//
//  DefaultCategories.swift
//  Notelayer
//
//  Default categories matching web app DEFAULT_CATEGORIES
//

import Foundation

extension Category {
    static let defaults: [Category] = [
        Category(id: "house", name: "House & Repairs", icon: "🏠", color: "category-house"),
        Category(id: "garage", name: "Garage & Workshop", icon: "🔧", color: "category-garage"),
        Category(id: "printing", name: "3D Printing", icon: "🖨️", color: "category-printing"),
        Category(id: "vehicle", name: "Vehicle & Motorcycle", icon: "🏍️", color: "category-vehicle"),
        Category(id: "tech", name: "Tech & Apps", icon: "💻", color: "category-tech"),
        Category(id: "finance", name: "Finance & Admin", icon: "📊", color: "category-finance"),
        Category(id: "shopping", name: "Shopping & Errands", icon: "🛒", color: "category-shopping"),
        Category(id: "travel", name: "Travel & Health", icon: "✈️", color: "category-travel"),
    ]
}
