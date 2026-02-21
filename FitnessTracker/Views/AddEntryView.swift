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
    let saturatedFatPer100g: Double
    let transFatPer100g: Double
    let fiberPer100g: Double
    let sugarPer100g: Double
    let sodiumPer100g: Double
    let cholesterolPer100g: Double
    let calciumPer100g: Double
    let ironPer100g: Double
    let vitaminAPer100g: Double
    let vitaminCPer100g: Double
    let vitaminDPer100g: Double
    let logDate: Date
    let initialServingSize: Double?
    let servingSizeUnit: String?
    var onUpdateServing: ((Double) -> Void)?
    var entryToEdit: MealEntry?

    @State private var servingGrams: Double
    @State private var selectedUnit: ServingUnit

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
        self.saturatedFatPer100g = usdaResult.saturatedFatPer100g
        self.transFatPer100g = usdaResult.transFatPer100g
        self.fiberPer100g = usdaResult.fiberPer100g
        self.sugarPer100g = usdaResult.sugarPer100g
        self.sodiumPer100g = usdaResult.sodiumPer100g
        self.cholesterolPer100g = usdaResult.cholesterolPer100g
        self.calciumPer100g = usdaResult.calciumPer100g
        self.ironPer100g = usdaResult.ironPer100g
        self.vitaminAPer100g = usdaResult.vitaminAPer100g
        self.vitaminCPer100g = usdaResult.vitaminCPer100g
        self.vitaminDPer100g = usdaResult.vitaminDPer100g
        self.initialServingSize = usdaResult.servingSize
        self.servingSizeUnit = usdaResult.servingSizeUnit
        self.onUpdateServing = nil
        self.entryToEdit = nil
        let units = ServingUnit.availableUnits(foodServingSize: usdaResult.servingSize, foodServingSizeUnit: usdaResult.servingSizeUnit)
        self._selectedUnit = State(initialValue: units.first ?? .grams)
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
        self.saturatedFatPer100g = foodItem.saturatedFatPer100g
        self.transFatPer100g = foodItem.transFatPer100g
        self.fiberPer100g = foodItem.fiberPer100g
        self.sugarPer100g = foodItem.sugarPer100g
        self.sodiumPer100g = foodItem.sodiumPer100g
        self.cholesterolPer100g = foodItem.cholesterolPer100g
        self.calciumPer100g = foodItem.calciumPer100g
        self.ironPer100g = foodItem.ironPer100g
        self.vitaminAPer100g = foodItem.vitaminAPer100g
        self.vitaminCPer100g = foodItem.vitaminCPer100g
        self.vitaminDPer100g = foodItem.vitaminDPer100g
        self.initialServingSize = foodItem.servingSize
        self.servingSizeUnit = foodItem.servingSizeUnit
        self.onUpdateServing = nil
        self.entryToEdit = nil
        let units = ServingUnit.availableUnits(foodServingSize: foodItem.servingSize, foodServingSizeUnit: foodItem.servingSizeUnit)
        self._selectedUnit = State(initialValue: units.first ?? .grams)
        self._servingGrams = State(initialValue: foodItem.servingSize ?? 100)
    }

    init(entry: MealEntry) {
        let food = entry.foodItem
        self.entryToEdit = entry
        self.fdcId = food?.fdcId ?? 0
        self.foodName = food?.name ?? "Unknown"
        self.brand = food?.brand ?? ""
        self.mealName = entry.mealType
        self.logDate = entry.date
        self.caloriesPer100g = food?.caloriesPer100g ?? 0
        self.proteinPer100g = food?.proteinPer100g ?? 0
        self.carbsPer100g = food?.carbsPer100g ?? 0
        self.fatPer100g = food?.fatPer100g ?? 0
        self.saturatedFatPer100g = food?.saturatedFatPer100g ?? 0
        self.transFatPer100g = food?.transFatPer100g ?? 0
        self.fiberPer100g = food?.fiberPer100g ?? 0
        self.sugarPer100g = food?.sugarPer100g ?? 0
        self.sodiumPer100g = food?.sodiumPer100g ?? 0
        self.cholesterolPer100g = food?.cholesterolPer100g ?? 0
        self.calciumPer100g = food?.calciumPer100g ?? 0
        self.ironPer100g = food?.ironPer100g ?? 0
        self.vitaminAPer100g = food?.vitaminAPer100g ?? 0
        self.vitaminCPer100g = food?.vitaminCPer100g ?? 0
        self.vitaminDPer100g = food?.vitaminDPer100g ?? 0
        self.initialServingSize = food?.servingSize
        self.servingSizeUnit = food?.servingSizeUnit
        self.onUpdateServing = nil
        let units = ServingUnit.availableUnits(foodServingSize: food?.servingSize, foodServingSizeUnit: food?.servingSizeUnit)
        let matchedUnit = units.first(where: { $0.label == entry.servingUnit }) ?? units.first ?? .grams
        self._selectedUnit = State(initialValue: matchedUnit)
        self._servingGrams = State(initialValue: entry.servingGrams)
    }

    init(foodItem: FoodItem, servingGrams: Double, onUpdateServing: @escaping (Double) -> Void) {
        self.fdcId = foodItem.fdcId
        self.foodName = foodItem.name
        self.brand = foodItem.brand ?? ""
        self.mealName = ""
        self.logDate = Date()
        self.caloriesPer100g = foodItem.caloriesPer100g
        self.proteinPer100g = foodItem.proteinPer100g
        self.carbsPer100g = foodItem.carbsPer100g
        self.fatPer100g = foodItem.fatPer100g
        self.saturatedFatPer100g = foodItem.saturatedFatPer100g
        self.transFatPer100g = foodItem.transFatPer100g
        self.fiberPer100g = foodItem.fiberPer100g
        self.sugarPer100g = foodItem.sugarPer100g
        self.sodiumPer100g = foodItem.sodiumPer100g
        self.cholesterolPer100g = foodItem.cholesterolPer100g
        self.calciumPer100g = foodItem.calciumPer100g
        self.ironPer100g = foodItem.ironPer100g
        self.vitaminAPer100g = foodItem.vitaminAPer100g
        self.vitaminCPer100g = foodItem.vitaminCPer100g
        self.vitaminDPer100g = foodItem.vitaminDPer100g
        self.initialServingSize = foodItem.servingSize
        self.servingSizeUnit = foodItem.servingSizeUnit
        self.onUpdateServing = onUpdateServing
        self.entryToEdit = nil
        let units = ServingUnit.availableUnits(foodServingSize: foodItem.servingSize, foodServingSizeUnit: foodItem.servingSizeUnit)
        self._selectedUnit = State(initialValue: units.first ?? .grams)
        self._servingGrams = State(initialValue: servingGrams)
    }

    private var availableUnits: [ServingUnit] {
        ServingUnit.availableUnits(foodServingSize: initialServingSize, foodServingSizeUnit: servingSizeUnit)
    }

    private var calories: Int { Int((caloriesPer100g * servingGrams) / 100) }
    private var protein: Int { Int((proteinPer100g * servingGrams) / 100) }
    private var carbs: Int { Int((carbsPer100g * servingGrams) / 100) }
    private var fat: Int { Int((fatPer100g * servingGrams) / 100) }
    private var saturatedFat: Double { (saturatedFatPer100g * servingGrams) / 100 }
    private var transFat: Double { (transFatPer100g * servingGrams) / 100 }
    private var fiber: Double { (fiberPer100g * servingGrams) / 100 }
    private var sugar: Double { (sugarPer100g * servingGrams) / 100 }
    private var sodium: Double { (sodiumPer100g * servingGrams) / 100 }
    private var cholesterol: Double { (cholesterolPer100g * servingGrams) / 100 }
    private var calcium: Double { (calciumPer100g * servingGrams) / 100 }
    private var iron: Double { (ironPer100g * servingGrams) / 100 }
    private var vitaminA: Double { (vitaminAPer100g * servingGrams) / 100 }
    private var vitaminC: Double { (vitaminCPer100g * servingGrams) / 100 }
    private var vitaminD: Double { (vitaminDPer100g * servingGrams) / 100 }

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
                    ServingRow(servingGrams: $servingGrams, selectedUnit: $selectedUnit, availableUnits: availableUnits)
                    CalculateByDivider()
                    TargetCaloriesRow(servingGrams: $servingGrams, caloriesPer100g: caloriesPer100g)
                    MacroRingsRow(protein: protein, carbs: carbs, fat: fat)
                    MicronutrientsSection(
                        saturatedFat: saturatedFat, transFat: transFat,
                        fiber: fiber, sugar: sugar,
                        sodium: sodium, cholesterol: cholesterol,
                        calcium: calcium, iron: iron,
                        vitaminA: vitaminA, vitaminC: vitaminC, vitaminD: vitaminD
                    )
                }
                .padding()
                .padding(.bottom, 80)
            }

            AddToMealButton(title: entryToEdit != nil || onUpdateServing != nil ? "Update Serving" : "Add to Meal", calories: calories) {
                if let entry = entryToEdit {
                    entry.servingGrams = servingGrams
                    entry.servingUnit = selectedUnit.label
                    entry.servingQuantity = selectedUnit.fromGrams(servingGrams)
                    dismiss()
                } else if let onUpdate = onUpdateServing {
                    onUpdate(servingGrams)
                    dismiss()
                } else {
                    addToMeal()
                }
            }
        }
        .background(AppColors.background)
        .navigationTitle(entryToEdit != nil || onUpdateServing != nil ? "Edit Serving" : "Add Entry")
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
                saturatedFatPer100g: saturatedFatPer100g,
                transFatPer100g: transFatPer100g,
                fiberPer100g: fiberPer100g,
                sugarPer100g: sugarPer100g,
                sodiumPer100g: sodiumPer100g,
                cholesterolPer100g: cholesterolPer100g,
                calciumPer100g: calciumPer100g,
                ironPer100g: ironPer100g,
                vitaminAPer100g: vitaminAPer100g,
                vitaminCPer100g: vitaminCPer100g,
                vitaminDPer100g: vitaminDPer100g,
                servingSize: initialServingSize,
                servingSizeUnit: servingSizeUnit
            )
            modelContext.insert(food)
        }

        let entry = MealEntry(
            date: logDate,
            mealType: mealName,
            servingGrams: servingGrams,
            foodItem: food,
            servingUnit: selectedUnit.label,
            servingQuantity: selectedUnit.fromGrams(servingGrams)
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
        @Binding var selectedUnit: ServingUnit
        let availableUnits: [ServingUnit]

        @State private var quantityText: String = ""
        @FocusState private var isFocused: Bool

        var body: some View {
            HStack(spacing: 0) {
                TextField("0", text: $quantityText)
                    .foregroundColor(.white)
                    .font(.custom(Fonts.interMedium, size: FontSize.lg))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .focused($isFocused)
                    .onChange(of: quantityText) { _, newValue in
                        if isFocused, let qty = Double(newValue), qty > 0 {
                            servingGrams = selectedUnit.toGrams(qty)
                        }
                    }

                Divider()
                    .frame(height: 24)
                    .overlay(Color.white.opacity(CardStyle.borderOpacity))

                Menu {
                    ForEach(availableUnits) { unit in
                        Button {
                            let qty = unit.fromGrams(servingGrams)
                            selectedUnit = unit
                            quantityText = formatQty(qty)
                        } label: {
                            if unit == selectedUnit {
                                Label(unit.menuLabel, systemImage: "checkmark")
                            } else {
                                Text(unit.menuLabel)
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(selectedUnit.label)
                            .foregroundColor(AppColors.macroTextColor)
                            .font(.custom(Fonts.interMedium, size: FontSize.lg))
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(AppColors.macroTextColor)
                    }
                    .frame(width: 90)
                }
            }
            .padding(.vertical, Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.sm)
                    .stroke(Color.white.opacity(CardStyle.borderOpacity), lineWidth: CardStyle.borderWidth)
            )
            .onAppear {
                quantityText = formatQty(selectedUnit.fromGrams(servingGrams))
            }
            .onChange(of: servingGrams) { _, newValue in
                if !isFocused {
                    quantityText = formatQty(selectedUnit.fromGrams(newValue))
                }
            }
        }

        private func formatQty(_ qty: Double) -> String {
            qty == Double(Int(qty)) ? "\(Int(qty))" : String(format: "%.2f", qty)
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
        let saturatedFat: Double
        let transFat: Double
        let fiber: Double
        let sugar: Double
        let sodium: Double
        let cholesterol: Double
        let calcium: Double
        let iron: Double
        let vitaminA: Double
        let vitaminC: Double
        let vitaminD: Double

        // FDA Daily Values
        private let saturatedFatDV = 20.0   // g
        private let fiberDV = 28.0          // g
        private let sugarDV = 50.0          // g
        private let sodiumDV = 2300.0       // mg
        private let cholesterolDV = 300.0   // mg
        private let calciumDV = 1300.0      // mg
        private let ironDV = 18.0           // mg
        private let vitaminADV = 3000.0     // IU
        private let vitaminCDV = 90.0       // mg
        private let vitaminDDV = 800.0      // IU

        private func dvPercent(_ value: Double, _ dv: Double) -> Int {
            guard dv > 0 else { return 0 }
            return Int((value / dv) * 100)
        }

        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                HStack {
                    Text("NUTRITION FACTS")
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

                // Fat breakdown
                VStack(spacing: 0) {
                    MicronutrientRow(name: "Saturated Fat", value: String(format: "%.1fg", saturatedFat), dvPercent: dvPercent(saturatedFat, saturatedFatDV), showTopDivider: false)
                    MicronutrientRow(name: "Trans Fat", value: String(format: "%.1fg", transFat))
                }
                .padding()
                .background(sectionBackground)

                // Carb breakdown
                VStack(spacing: 0) {
                    MicronutrientRow(name: "Fiber", value: String(format: "%.1fg", fiber), dvPercent: dvPercent(fiber, fiberDV), showTopDivider: false)
                    MicronutrientRow(name: "Sugar", value: String(format: "%.1fg", sugar), dvPercent: dvPercent(sugar, sugarDV))
                }
                .padding()
                .background(sectionBackground)

                // Minerals
                VStack(spacing: 0) {
                    MicronutrientRow(name: "Cholesterol", value: String(format: "%.0fmg", cholesterol), dvPercent: dvPercent(cholesterol, cholesterolDV), showTopDivider: false)
                    MicronutrientRow(name: "Sodium", value: String(format: "%.0fmg", sodium), dvPercent: dvPercent(sodium, sodiumDV))
                    MicronutrientRow(name: "Calcium", value: String(format: "%.0fmg", calcium), dvPercent: dvPercent(calcium, calciumDV))
                    MicronutrientRow(name: "Iron", value: String(format: "%.1fmg", iron), dvPercent: dvPercent(iron, ironDV))
                }
                .padding()
                .background(sectionBackground)

                // Vitamins
                VStack(spacing: 0) {
                    MicronutrientRow(name: "Vitamin A", value: String(format: "%.0f IU", vitaminA), dvPercent: dvPercent(vitaminA, vitaminADV), showTopDivider: false)
                    MicronutrientRow(name: "Vitamin C", value: String(format: "%.1fmg", vitaminC), dvPercent: dvPercent(vitaminC, vitaminCDV))
                    MicronutrientRow(name: "Vitamin D", value: String(format: "%.0f IU", vitaminD), dvPercent: dvPercent(vitaminD, vitaminDDV))
                }
                .padding()
                .background(sectionBackground)
            }
        }

        private var sectionBackground: some View {
            RoundedRectangle(cornerRadius: CornerRadius.sm)
                .fill(CardStyle.fillColor.opacity(CardStyle.fillOpacity))
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.sm)
                        .stroke(Color.white.opacity(CardStyle.borderOpacity), lineWidth: CardStyle.borderWidth)
                )
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
        var title: String = "Add to Meal"
        let calories: Int
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                HStack {
                    Text(title)
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
                saturatedFatPer100g: 3.8,
                transFatPer100g: 0,
                fiberPer100g: 12.5,
                sugarPer100g: 4.4,
                sodiumPer100g: 1,
                cholesterolPer100g: 0,
                calciumPer100g: 269,
                ironPer100g: 3.7,
                vitaminAPer100g: 0,
                vitaminCPer100g: 0,
                vitaminDPer100g: 0,
                servingSize: 28,
                servingSizeUnit: "g"
            ),
            mealName: "Lunch"
        )
    }
}
