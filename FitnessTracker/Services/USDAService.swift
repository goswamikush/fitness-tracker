//
//  USDAService.swift
//  FitnessTracker
//

import Foundation

struct USDAFoodResult: Identifiable, Hashable {
    let id: Int // fdcId
    let name: String
    let brand: String?
    // Macros
    let caloriesPer100g: Double
    let proteinPer100g: Double
    let carbsPer100g: Double
    let fatPer100g: Double
    // Fat breakdown
    let saturatedFatPer100g: Double
    let transFatPer100g: Double
    // Carb breakdown
    let fiberPer100g: Double
    let sugarPer100g: Double
    // Minerals
    let sodiumPer100g: Double
    let cholesterolPer100g: Double
    let calciumPer100g: Double
    let ironPer100g: Double
    // Vitamins (stored in mg for C, IU for A and D)
    let vitaminAPer100g: Double
    let vitaminCPer100g: Double
    let vitaminDPer100g: Double
    // Serving
    let servingSize: Double?
    let servingSizeUnit: String?
}

class USDAService {
    static let shared = USDAService()
    private let apiKey = Secrets.usdaAPIKey
    private let baseURL = "https://api.nal.usda.gov/fdc/v1/foods/search"
    private var cache: [String: [USDAFoodResult]] = [:]

    func lookupBarcode(_ barcode: String) async throws -> [USDAFoodResult] {
        let urlString = "https://world.openfoodfacts.org/api/v0/product/\(barcode).json"
        guard let url = URL(string: urlString) else { return [] }

        let (data, _) = try await URLSession.shared.data(from: url)

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let status = json["status"] as? Int, status == 1,
              let product = json["product"] as? [String: Any] else {
            return []
        }

        let name = product["product_name"] as? String ?? "Unknown Product"
        let brand = product["brands"] as? String
        let nutriments = product["nutriments"] as? [String: Any] ?? [:]

        func nutrient(_ key: String) -> Double {
            (nutriments[key] as? NSNumber)?.doubleValue ?? 0.0
        }

        let servingSize = product["serving_quantity"] as? Double
            ?? (product["serving_quantity"] as? String).flatMap(Double.init)
        let servingSizeUnit = product["serving_quantity_unit"] as? String ?? "g"

        let kcalDirect = nutrient("energy-kcal_100g")
        let kcal = kcalDirect > 0 ? kcalDirect : nutrient("energy_100g") / 4.184

        let result = USDAFoodResult(
            id: Int(barcode.suffix(9)) ?? barcode.hashValue,
            name: name,
            brand: brand,
            caloriesPer100g: kcal,
            proteinPer100g: nutrient("proteins_100g"),
            carbsPer100g: nutrient("carbohydrates_100g"),
            fatPer100g: nutrient("fat_100g"),
            saturatedFatPer100g: nutrient("saturated-fat_100g"),
            transFatPer100g: nutrient("trans-fat_100g"),
            fiberPer100g: nutrient("fiber_100g"),
            sugarPer100g: nutrient("sugars_100g"),
            sodiumPer100g: nutrient("sodium_100g") * 1000,
            cholesterolPer100g: nutrient("cholesterol_100g") * 1000,
            calciumPer100g: nutrient("calcium_100g") * 1000,
            ironPer100g: nutrient("iron_100g") * 1000,
            vitaminAPer100g: nutrient("vitamin-a_100g"),
            vitaminCPer100g: nutrient("vitamin-c_100g"),
            vitaminDPer100g: nutrient("vitamin-d_100g"),
            servingSize: servingSize,
            servingSizeUnit: servingSizeUnit
        )

        return [result]
    }

    func searchFoods(query: String) async throws -> [USDAFoodResult] {
        guard !query.isEmpty else { return [] }

        let cacheKey = query.lowercased()
        if let cached = cache[cacheKey] { return cached }

        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "dataType", value: "Branded"),
            URLQueryItem(name: "pageSize", value: "10")
        ]

        guard let url = components.url else { return [] }

        let (data, _) = try await URLSession.shared.data(from: url)

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let foods = json["foods"] as? [[String: Any]] else {
            return []
        }

        let results = foods.compactMap { food -> USDAFoodResult? in
            guard let fdcId = food["fdcId"] as? Int,
                  let description = food["description"] as? String else {
                return nil
            }

            let brand = food["brandName"] as? String ?? food["brandOwner"] as? String
            let nutrients = food["foodNutrients"] as? [[String: Any]] ?? []

            var calories = 0.0, protein = 0.0, carbs = 0.0, fat = 0.0
            var saturatedFat = 0.0, transFat = 0.0
            var fiber = 0.0, sugar = 0.0
            var sodium = 0.0, cholesterol = 0.0, calcium = 0.0, iron = 0.0
            var vitaminA = 0.0, vitaminC = 0.0, vitaminD = 0.0

            for nutrient in nutrients {
                guard let nutrientId = nutrient["nutrientId"] as? Int,
                      let value = nutrient["value"] as? Double else { continue }
                switch nutrientId {
                case 1008: calories = value
                case 1003: protein = value
                case 1005: carbs = value
                case 1004: fat = value
                case 1258: saturatedFat = value
                case 1257: transFat = value
                case 1079: fiber = value
                case 2000: sugar = value
                case 1093: sodium = value
                case 1253: cholesterol = value
                case 1087: calcium = value
                case 1089: iron = value
                case 1104: vitaminA = value   // IU
                case 1162: vitaminC = value   // mg
                case 1110: vitaminD = value   // IU
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
                saturatedFatPer100g: saturatedFat,
                transFatPer100g: transFat,
                fiberPer100g: fiber,
                sugarPer100g: sugar,
                sodiumPer100g: sodium,
                cholesterolPer100g: cholesterol,
                calciumPer100g: calcium,
                ironPer100g: iron,
                vitaminAPer100g: vitaminA,
                vitaminCPer100g: vitaminC,
                vitaminDPer100g: vitaminD,
                servingSize: servingSize,
                servingSizeUnit: servingSizeUnit
            )
        }

        cache[cacheKey] = results
        return results
    }
}
