//
//  CustomMealItem.swift
//  FitnessTracker
//

import Foundation
import SwiftData

@Model
final class CustomMealItem {
    var servingGrams: Double
    var foodItem: FoodItem?
    var customMeal: CustomMeal?

    var calories: Double {
        guard let food = foodItem else { return 0 }
        return (food.caloriesPer100g * servingGrams) / 100.0
    }

    var protein: Double {
        guard let food = foodItem else { return 0 }
        return (food.proteinPer100g * servingGrams) / 100.0
    }

    var carbs: Double {
        guard let food = foodItem else { return 0 }
        return (food.carbsPer100g * servingGrams) / 100.0
    }

    var fat: Double {
        guard let food = foodItem else { return 0 }
        return (food.fatPer100g * servingGrams) / 100.0
    }

    init(servingGrams: Double, foodItem: FoodItem? = nil, customMeal: CustomMeal? = nil) {
        self.servingGrams = servingGrams
        self.foodItem = foodItem
        self.customMeal = customMeal
    }
}
