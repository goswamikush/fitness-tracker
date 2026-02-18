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
    var fiberPer100g: Double
    var sugarPer100g: Double
    var sodiumPer100g: Double
    var cholesterolPer100g: Double
    var servingSize: Double?
    var servingSizeUnit: String?

    @Relationship(deleteRule: .cascade, inverse: \MealEntry.foodItem)
    var mealEntries: [MealEntry] = []

    init(fdcId: Int, name: String, brand: String? = nil, caloriesPer100g: Double, proteinPer100g: Double, carbsPer100g: Double, fatPer100g: Double, fiberPer100g: Double = 0, sugarPer100g: Double = 0, sodiumPer100g: Double = 0, cholesterolPer100g: Double = 0, servingSize: Double? = nil, servingSizeUnit: String? = nil) {
        self.fdcId = fdcId
        self.name = name
        self.brand = brand
        self.caloriesPer100g = caloriesPer100g
        self.proteinPer100g = proteinPer100g
        self.carbsPer100g = carbsPer100g
        self.fatPer100g = fatPer100g
        self.fiberPer100g = fiberPer100g
        self.sugarPer100g = sugarPer100g
        self.sodiumPer100g = sodiumPer100g
        self.cholesterolPer100g = cholesterolPer100g
        self.servingSize = servingSize
        self.servingSizeUnit = servingSizeUnit
    }
}
