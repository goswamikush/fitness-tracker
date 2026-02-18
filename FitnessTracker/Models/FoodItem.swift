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
    // Macros
    var caloriesPer100g: Double
    var proteinPer100g: Double
    var carbsPer100g: Double
    var fatPer100g: Double
    // Fat breakdown
    var saturatedFatPer100g: Double
    var transFatPer100g: Double
    // Carb breakdown
    var fiberPer100g: Double
    var sugarPer100g: Double
    // Minerals
    var sodiumPer100g: Double
    var cholesterolPer100g: Double
    var calciumPer100g: Double
    var ironPer100g: Double
    // Vitamins
    var vitaminAPer100g: Double
    var vitaminCPer100g: Double
    var vitaminDPer100g: Double
    // Serving
    var servingSize: Double?
    var servingSizeUnit: String?

    @Relationship(deleteRule: .cascade, inverse: \MealEntry.foodItem)
    var mealEntries: [MealEntry] = []

    @Relationship(deleteRule: .cascade, inverse: \CustomMealItem.foodItem)
    var customMealItems: [CustomMealItem] = []

    init(fdcId: Int, name: String, brand: String? = nil, caloriesPer100g: Double, proteinPer100g: Double, carbsPer100g: Double, fatPer100g: Double, saturatedFatPer100g: Double = 0, transFatPer100g: Double = 0, fiberPer100g: Double = 0, sugarPer100g: Double = 0, sodiumPer100g: Double = 0, cholesterolPer100g: Double = 0, calciumPer100g: Double = 0, ironPer100g: Double = 0, vitaminAPer100g: Double = 0, vitaminCPer100g: Double = 0, vitaminDPer100g: Double = 0, servingSize: Double? = nil, servingSizeUnit: String? = nil) {
        self.fdcId = fdcId
        self.name = name
        self.brand = brand
        self.caloriesPer100g = caloriesPer100g
        self.proteinPer100g = proteinPer100g
        self.carbsPer100g = carbsPer100g
        self.fatPer100g = fatPer100g
        self.saturatedFatPer100g = saturatedFatPer100g
        self.transFatPer100g = transFatPer100g
        self.fiberPer100g = fiberPer100g
        self.sugarPer100g = sugarPer100g
        self.sodiumPer100g = sodiumPer100g
        self.cholesterolPer100g = cholesterolPer100g
        self.calciumPer100g = calciumPer100g
        self.ironPer100g = ironPer100g
        self.vitaminAPer100g = vitaminAPer100g
        self.vitaminCPer100g = vitaminCPer100g
        self.vitaminDPer100g = vitaminDPer100g
        self.servingSize = servingSize
        self.servingSizeUnit = servingSizeUnit
    }
}
