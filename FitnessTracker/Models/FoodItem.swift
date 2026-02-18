//
//  FoodItem.swift
//  FitnessTracker
//

import Foundation
import SwiftData

@Model
final class FoodItem {
    @Attribute(.unique) var fdcId: Int
    var name: String
    var brand: String?
    var caloriesPer100g: Double
    var proteinPer100g: Double
    var carbsPer100g: Double
    var fatPer100g: Double
    var servingSize: Double?
    var servingSizeUnit: String?

    @Relationship(deleteRule: .cascade, inverse: \MealEntry.foodItem)
    var mealEntries: [MealEntry] = []

    init(fdcId: Int, name: String, brand: String? = nil, caloriesPer100g: Double, proteinPer100g: Double, carbsPer100g: Double, fatPer100g: Double, servingSize: Double? = nil, servingSizeUnit: String? = nil) {
        self.fdcId = fdcId
        self.name = name
        self.brand = brand
        self.caloriesPer100g = caloriesPer100g
        self.proteinPer100g = proteinPer100g
        self.carbsPer100g = carbsPer100g
        self.fatPer100g = fatPer100g
        self.servingSize = servingSize
        self.servingSizeUnit = servingSizeUnit
    }
}
