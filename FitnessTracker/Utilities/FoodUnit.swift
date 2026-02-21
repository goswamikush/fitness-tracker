//
//  FoodUnit.swift
//  FitnessTracker
//

import Foundation

struct ServingUnit: Equatable, Identifiable {
    let label: String
    let gramsPerUnit: Double

    var id: String { label }

    func toGrams(_ quantity: Double) -> Double { quantity * gramsPerUnit }
    func fromGrams(_ grams: Double) -> Double { grams / gramsPerUnit }

    var menuLabel: String {
        switch label {
        case "g":       return "Grams (g)"
        case "oz":      return "Ounces (oz)"
        case "lb":      return "Pounds (lb)"
        case "tbsp":    return "Tablespoon (tbsp)"
        case "tsp":     return "Teaspoon (tsp)"
        case "cup":     return "Cup"
        case "ml":      return "Milliliters (ml)"
        case "serving": return "Serving (\(Int(gramsPerUnit))g each)"
        default:        return label
        }
    }

    static let grams       = ServingUnit(label: "g",    gramsPerUnit: 1.0)
    static let ounces      = ServingUnit(label: "oz",   gramsPerUnit: 28.3495)
    static let pounds      = ServingUnit(label: "lb",   gramsPerUnit: 453.592)
    static let tablespoons = ServingUnit(label: "tbsp", gramsPerUnit: 14.787)
    static let teaspoons   = ServingUnit(label: "tsp",  gramsPerUnit: 4.929)
    static let cups        = ServingUnit(label: "cup",  gramsPerUnit: 236.588)
    static let milliliters = ServingUnit(label: "ml",   gramsPerUnit: 1.0)

    static var standards: [ServingUnit] {
        [.grams, .ounces, .pounds, .tablespoons, .teaspoons, .cups, .milliliters]
    }

    /// Returns available units for a food, with a "serving" option prepended when
    /// the food has a known serving size.
    static func availableUnits(foodServingSize: Double?, foodServingSizeUnit: String?) -> [ServingUnit] {
        var units = standards
        if let size = foodServingSize, size > 0 {
            let gramsEach = toBaseGrams(size, unit: foodServingSizeUnit)
            if gramsEach > 0 {
                units.insert(ServingUnit(label: "serving", gramsPerUnit: gramsEach), at: 0)
            }
        }
        return units
    }

    private static func toBaseGrams(_ value: Double, unit: String?) -> Double {
        switch unit?.lowercased() {
        case "oz":   return value * 28.3495
        case "lb":   return value * 453.592
        case "tbsp": return value * 14.787
        case "tsp":  return value * 4.929
        case "cup":  return value * 236.588
        case "ml":   return value
        default:     return value   // assume grams (nil, "g", or unknown unit)
        }
    }
}
