//
//  USDAService.swift
//  FitnessTracker
//

import Foundation

struct USDAFoodResult: Identifiable {
    let id: Int // fdcId
    let name: String
    let brand: String?
    let caloriesPer100g: Double
    let proteinPer100g: Double
    let carbsPer100g: Double
    let fatPer100g: Double
    let servingSize: Double?
    let servingSizeUnit: String?
}

class USDAService {
    static let shared = USDAService()
    private let apiKey = "DEMO_KEY"
    private let baseURL = "https://api.nal.usda.gov/fdc/v1/foods/search"

    func searchFoods(query: String) async throws -> [USDAFoodResult] {
        guard !query.isEmpty else { return [] }

        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "pageSize", value: "25"),
            URLQueryItem(name: "dataType", value: "Survey (FNDDS),Foundation,SR Legacy")
        ]

        guard let url = components.url else { return [] }

        let (data, _) = try await URLSession.shared.data(from: url)

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let foods = json["foods"] as? [[String: Any]] else {
            return []
        }

        return foods.compactMap { food -> USDAFoodResult? in
            guard let fdcId = food["fdcId"] as? Int,
                  let description = food["description"] as? String else {
                return nil
            }

            let brand = food["brandName"] as? String ?? food["brandOwner"] as? String
            let nutrients = food["foodNutrients"] as? [[String: Any]] ?? []

            var calories = 0.0
            var protein = 0.0
            var carbs = 0.0
            var fat = 0.0

            for nutrient in nutrients {
                guard let nutrientId = nutrient["nutrientId"] as? Int,
                      let value = nutrient["value"] as? Double else { continue }
                switch nutrientId {
                case 1008: calories = value
                case 1003: protein = value
                case 1005: carbs = value
                case 1004: fat = value
                default: break
                }
            }

            let servingSize = food["servingSize"] as? Double
            let servingSizeUnit = food["servingSizeUnit"] as? String

            return USDAFoodResult(
                id: fdcId,
                name: description,
                brand: brand,
                caloriesPer100g: calories,
                proteinPer100g: protein,
                carbsPer100g: carbs,
                fatPer100g: fat,
                servingSize: servingSize,
                servingSizeUnit: servingSizeUnit
            )
        }
    }
}
