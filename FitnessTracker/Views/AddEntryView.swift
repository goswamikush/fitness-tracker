//
//  AddEntryView.swift
//  FitnessTracker
//
//  Created by Kush Goswami on 2/14/26.
//

import SwiftUI
import SwiftData

struct AddEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let fdcId: Int
    let foodName: String
    let brand: String
    let mealName: String
    let caloriesPer100g: Double
    let proteinPer100g: Double
    let carbsPer100g: Double
    let fatPer100g: Double
    let fiberPer100g: Double
    let sugarPer100g: Double
    let sodiumPer100g: Double
    let cholesterolPer100g: Double
    let logDate: Date
    let initialServingSize: Double?
    let servingSizeUnit: String?

    @State private var servingGrams: Double

    init(usdaResult: USDAFoodResult, mealName: String, logDate: Date = Date()) {
        self.fdcId = usdaResult.id
        self.foodName = usdaResult.name
        self.brand = usdaResult.brand ?? ""
        self.mealName = mealName
        self.logDate = logDate
        self.caloriesPer100g = usdaResult.caloriesPer100g
        self.proteinPer100g = usdaResult.proteinPer100g
        self.carbsPer100g = usdaResult.carbsPer100g
        self.fatPer100g = usdaResult.fatPer100g
        self.fiberPer100g = usdaResult.fiberPer100g
        self.sugarPer100g = usdaResult.sugarPer100g
        self.sodiumPer100g = usdaResult.sodiumPer100g
        self.cholesterolPer100g = usdaResult.cholesterolPer100g
        self.initialServingSize = usdaResult.servingSize
        self.servingSizeUnit = usdaResult.servingSizeUnit
        self._servingGrams = State(initialValue: usdaResult.servingSize ?? 100)
    }

    init(foodItem: FoodItem, mealName: String, logDate: Date = Date()) {
        self.fdcId = foodItem.fdcId
        self.foodName = foodItem.name
        self.brand = foodItem.brand ?? ""
        self.mealName = mealName
        self.logDate = logDate
        self.caloriesPer100g = foodItem.caloriesPer100g
        self.proteinPer100g = foodItem.proteinPer100g
        self.carbsPer100g = foodItem.carbsPer100g
        self.fatPer100g = foodItem.fatPer100g
        self.fiberPer100g = foodItem.fiberPer100g
        self.sugarPer100g = foodItem.sugarPer100g
        self.sodiumPer100g = foodItem.sodiumPer100g
        self.cholesterolPer100g = foodItem.cholesterolPer100g
        self.initialServingSize = foodItem.servingSize
        self.servingSizeUnit = foodItem.servingSizeUnit
        self._servingGrams = State(initialValue: foodItem.servingSize ?? 100)
    }

    private var calories: Int { Int((caloriesPer100g * servingGrams) / 100) }
    private var protein: Int { Int((proteinPer100g * servingGrams) / 100) }
    private var carbs: Int { Int((carbsPer100g * servingGrams) / 100) }
    private var fat: Int { Int((fatPer100g * servingGrams) / 100) }
    private var fiber: Double { (fiberPer100g * servingGrams) / 100 }
    private var sugar: Double { (sugarPer100g * servingGrams) / 100 }
    private var sodium: Double { (sodiumPer100g * servingGrams) / 100 }
    private var cholesterol: Double { (cholesterolPer100g * servingGrams) / 100 }

    private var servingDisplay: String {
        if let unit = servingSizeUnit, !unit.isEmpty {
            return "\(Int(servingGrams))\(unit)"
        }
        return "\(Int(servingGrams))g"
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: Spacing.xl) {
                    FoodHeader(brand: brand, name: foodName, servingSize: servingDisplay)
                    ServingRow(servingGrams: $servingGrams)
                    CalculateByDivider()
                    TargetCaloriesRow(servingGrams: $servingGrams, caloriesPer100g: caloriesPer100g)
                    MacroRingsRow(protein: protein, carbs: carbs, fat: fat)
                    MicronutrientsSection(fiber: fiber, sugar: sugar, sodium: sodium, cholesterol: cholesterol)
                }
                .padding()
                .padding(.bottom, 80)
            }

            AddToMealButton(calories: calories) {
                addToMeal()
            }
        }
        .background(AppColors.background)
        .navigationTitle("Add Entry")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private func addToMeal() {
        let searchId = fdcId
        let descriptor = FetchDescriptor<FoodItem>(predicate: #Predicate { $0.fdcId == searchId })
        let existing = try? modelContext.fetch(descriptor)
        let food: FoodItem
        if let found = existing?.first {
            food = found
        } else {
            food = FoodItem(
                fdcId: fdcId,
                name: foodName,
                brand: brand.isEmpty ? nil : brand,
                caloriesPer100g: caloriesPer100g,
                proteinPer100g: proteinPer100g,
                carbsPer100g: carbsPer100g,
                fatPer100g: fatPer100g,
                fiberPer100g: fiberPer100g,
                sugarPer100g: sugarPer100g,
                sodiumPer100g: sodiumPer100g,
                cholesterolPer100g: cholesterolPer100g,
                servingSize: initialServingSize,
                servingSizeUnit: servingSizeUnit
            )
            modelContext.insert(food)
        }

        let entry = MealEntry(
            date: logDate,
            mealType: mealName,
            servingGrams: servingGrams,
            foodItem: food
        )
        modelContext.insert(entry)

        dismiss()
    }
}

// MARK: - Subcomponents

private extension AddEntryView {

    struct FoodHeader: View {
        let brand: String
        let name: String
        let servingSize: String

        var body: some View {
            VStack(spacing: Spacing.md) {
                if !brand.isEmpty {
                    Text(brand.uppercased())
                        .foregroundColor(AppColors.macroTextColor)
                        .font(.custom(Fonts.interMedium, size: FontSize.sm))
                        .tracking(1)
                }

                Text(name.capitalized)
                    .foregroundColor(.white)
                    .font(.custom(Fonts.outfitSemiBold, size: 24))
                    .multilineTextAlignment(.center)

                Text("\(servingSize) per serving")
                    .foregroundColor(AppColors.macroTextColor)
                    .font(.custom(Fonts.interRegular, size: FontSize.md))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.xl)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.sm)
                    .fill(CardStyle.fillColor.opacity(CardStyle.fillOpacity))
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.sm)
                            .stroke(Color.white.opacity(CardStyle.borderOpacity), lineWidth: CardStyle.borderWidth)
                    )
                    .overlay(alignment: .top) {
                        MacroColors.carbs
                            .frame(height: 3)
                            .clipShape(UnevenRoundedRectangle(topLeadingRadius: CornerRadius.sm, topTrailingRadius: CornerRadius.sm))
                    }
            )
        }
    }

    struct ServingRow: View {
        @Binding var servingGrams: Double
        @State private var servingText: String = ""
        @FocusState private var isFocused: Bool

        var body: some View {
            HStack(spacing: 0) {
                TextField("100", text: $servingText)
                    .foregroundColor(.white)
                    .font(.custom(Fonts.interMedium, size: FontSize.lg))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .focused($isFocused)
                    .onChange(of: servingText) { _, newValue in
                        if isFocused, let val = Double(newValue), val > 0 {
                            servingGrams = val
                        }
                    }

                Divider()
                    .frame(height: 24)
                    .overlay(Color.white.opacity(CardStyle.borderOpacity))

                Text("g")
                    .foregroundColor(AppColors.macroTextColor)
                    .font(.custom(Fonts.interMedium, size: FontSize.lg))
                    .frame(width: 80)
            }
            .padding(.vertical, Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.sm)
                    .stroke(Color.white.opacity(CardStyle.borderOpacity), lineWidth: CardStyle.borderWidth)
            )
            .onAppear {
                servingText = "\(Int(servingGrams))"
            }
            .onChange(of: servingGrams) { _, newValue in
                if !isFocused {
                    servingText = "\(Int(newValue))"
                }
            }
        }
    }

    struct CalculateByDivider: View {
        var body: some View {
            HStack(spacing: Spacing.lg) {
                line
                Text("OR CALCULATE BY")
                    .foregroundColor(AppColors.macroTextColor)
                    .font(.custom(Fonts.interMedium, size: FontSize.xs))
                    .tracking(0.5)
                line
            }
        }

        private var line: some View {
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(height: 1)
        }
    }

    struct TargetCaloriesRow: View {
        @Binding var servingGrams: Double
        let caloriesPer100g: Double
        @State private var calorieText: String = ""
        @FocusState private var isFocused: Bool

        private var calories: Int {
            Int((caloriesPer100g * servingGrams) / 100)
        }

        var body: some View {
            HStack {
                Text("Target Calories")
                    .foregroundColor(AppColors.macroTextColor)
                    .font(.custom(Fonts.interRegular, size: FontSize.lg))
                Spacer()
                TextField("0", text: $calorieText)
                    .foregroundColor(.white)
                    .font(.custom(Fonts.interMedium, size: FontSize.lg))
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 70)
                    .focused($isFocused)
                    .onChange(of: calorieText) { _, newValue in
                        if isFocused, let target = Double(newValue), target > 0, caloriesPer100g > 0 {
                            servingGrams = (target / caloriesPer100g) * 100
                        }
                    }
                Text("kcal")
                    .foregroundColor(AppColors.lightMacroTextColor)
                    .font(.custom(Fonts.interRegular, size: FontSize.lg))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.sm)
                    .stroke(Color.white.opacity(CardStyle.borderOpacity), lineWidth: CardStyle.borderWidth)
            )
            .onAppear {
                calorieText = "\(calories)"
            }
            .onChange(of: servingGrams) { _, _ in
                if !isFocused {
                    calorieText = "\(calories)"
                }
            }
        }
    }

    struct MacroRingsRow: View {
        let protein: Int
        let carbs: Int
        let fat: Int

        var body: some View {
            HStack(spacing: Spacing.xxl) {
                MacroRing(current: Double(protein), goal: 180, color: MacroColors.protein, label: "Protein")
                MacroRing(current: Double(carbs), goal: 250, color: MacroColors.carbs, label: "Carbs")
                MacroRing(current: Double(fat), goal: 70, color: MacroColors.fats, label: "Fat")
            }
            .padding(.vertical, Spacing.md)
        }
    }

    struct MicronutrientsSection: View {
        let fiber: Double
        let sugar: Double
        let sodium: Double
        let cholesterol: Double

        // Daily reference values
        private let fiberDV = 28.0    // g
        private let sugarDV = 50.0    // g
        private let sodiumDV = 2300.0 // mg
        private let cholesterolDV = 300.0 // mg

        private func dvPercent(_ value: Double, _ dv: Double) -> Int {
            Int((value / dv) * 100)
        }

        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                HStack {
                    Text("MICRONUTRIENTS")
                        .foregroundColor(AppColors.macroTextColor)
                        .font(.custom(Fonts.interMedium, size: FontSize.xs))
                        .tracking(1)

                    Spacer()

                    Text("% Daily Value")
                        .foregroundColor(MacroColors.carbs)
                        .font(.custom(Fonts.interMedium, size: FontSize.xs))
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.sm)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(MacroColors.carbs, lineWidth: 1)
                        )
                }

                VStack(spacing: 0) {
                    MicronutrientRow(name: "Fiber", value: String(format: "%.1fg", fiber), dvPercent: dvPercent(fiber, fiberDV), showTopDivider: false)
                    MicronutrientRow(name: "Sugar", value: String(format: "%.1fg", sugar), dvPercent: dvPercent(sugar, sugarDV))
                    MicronutrientRow(name: "Sodium", value: String(format: "%.0fmg", sodium), dvPercent: dvPercent(sodium, sodiumDV))
                    MicronutrientRow(name: "Cholesterol", value: String(format: "%.0fmg", cholesterol), dvPercent: dvPercent(cholesterol, cholesterolDV))
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.sm)
                        .fill(CardStyle.fillColor.opacity(CardStyle.fillOpacity))
                        .overlay(
                            RoundedRectangle(cornerRadius: CornerRadius.sm)
                                .stroke(Color.white.opacity(CardStyle.borderOpacity), lineWidth: CardStyle.borderWidth)
                        )
                )
            }
        }
    }

    struct MicronutrientRow: View {
        let name: String
        let value: String
        var dvPercent: Int = 0
        var showTopDivider: Bool = true

        var body: some View {
            VStack(spacing: 0) {
                if showTopDivider {
                    Divider()
                        .overlay(Color.white.opacity(0.08))
                }

                HStack {
                    Text(name)
                        .foregroundColor(.white)
                        .font(.custom(Fonts.interMedium, size: FontSize.lg))
                    Spacer()
                    Text(value)
                        .foregroundColor(AppColors.macroTextColor)
                        .font(.custom(Fonts.interRegular, size: FontSize.lg))
                    Text("\(dvPercent)%")
                        .foregroundColor(AppColors.lightMacroTextColor)
                        .font(.custom(Fonts.interRegular, size: FontSize.xs))
                        .frame(width: 40, alignment: .trailing)
                }
                .padding(.vertical, Spacing.lg)
            }
        }
    }

    struct AddToMealButton: View {
        let calories: Int
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                HStack {
                    Text("Add to Meal")
                        .foregroundColor(.black)
                        .font(.custom(Fonts.interSemiBold, size: FontSize.xl))

                    Spacer()

                    HStack(spacing: Spacing.sm) {
                        Text("\(calories)")
                            .foregroundColor(.black)
                            .font(.custom(Fonts.outfitSemiBold, size: FontSize.xl))
                        Text("kcal")
                            .foregroundColor(.black.opacity(0.7))
                            .font(.custom(Fonts.interRegular, size: FontSize.lg))
                    }
                }
                .padding()
                .background(MacroColors.carbs)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
                .padding()
            }
        }
    }
}

#Preview {
    NavigationStack {
        AddEntryView(
            usdaResult: USDAFoodResult(
                id: 123,
                name: "Almonds",
                brand: "Blue Diamond",
                caloriesPer100g: 579,
                proteinPer100g: 21,
                carbsPer100g: 22,
                fatPer100g: 50,
                fiberPer100g: 12.5,
                sugarPer100g: 4.4,
                sodiumPer100g: 1,
                cholesterolPer100g: 0,
                servingSize: 28,
                servingSizeUnit: "g"
            ),
            mealName: "Lunch"
        )
    }
}
