//
//  CustomMeal.swift
//  FitnessTracker
//

import Foundation
import SwiftData

@Model
final class CustomMeal {
    var name: String
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \CustomMealItem.customMeal)
    var items: [CustomMealItem] = []

    init(name: String, createdAt: Date = Date()) {
        self.name = name
        self.createdAt = createdAt
    }
}
