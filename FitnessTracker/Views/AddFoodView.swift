//
//  AddFoodView.swift
//  FitnessTracker
//
//  Created by Kush Goswami on 2/14/26.
//

import SwiftUI
import SwiftData

struct AddFoodView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let mealName: String
    var logDate: Date = Date()
    @State private var selectedTab = 0
    @State private var searchText = ""
    @State private var searchResults: [USDAFoodResult] = []
    @State private var isSearching = false
    @State private var searchTask: Task<Void, Never>?
    @Query(sort: \MealEntry.date, order: .reverse) private var allEntries: [MealEntry]
    @Query(sort: \CustomMeal.createdAt, order: .reverse) private var customMeals: [CustomMeal]

    private var recentFoods: [FoodItem] {
        var seen = Set<Int>()
        var items: [FoodItem] = []
        for entry in allEntries {
            guard let food = entry.foodItem else { continue }
            if seen.insert(food.fdcId).inserted {
                items.append(food)
            }
            if items.count >= 5 { break }
        }
        return items
    }

    private var yesterdayEntries: [MealEntry] {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: logDate) ?? logDate
        return allEntries.filter { Calendar.current.isDate($0.date, inSameDayAs: yesterday) }
    }

    private var yesterdayMealGroups: [(mealType: String, entries: [MealEntry])] {
        let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snack"]
        return mealTypes.compactMap { type in
            let entries = yesterdayEntries.filter { $0.mealType == type }
            return entries.isEmpty ? nil : (mealType: type, entries: entries)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            TabPicker(selectedTab: $selectedTab)
                .padding(.horizontal)
                .padding(.top, Spacing.md)

            if selectedTab == 0 {
                FoodTabContent(
                    searchText: $searchText,
                    isSearching: isSearching,
                    searchResults: searchResults,
                    recentFoods: recentFoods,
                    yesterdayMealGroups: yesterdayMealGroups,
                    mealName: mealName,
                    logDate: logDate
                )
            } else {
                CustomMealsTabContent(
                    customMeals: customMeals,
                    mealName: mealName,
                    logDate: logDate,
                    onAddMeal: addCustomMealEntries,
                    onDeleteMeal: deleteCustomMeal
                )
            }
        }
        .background(AppColors.background)
        .navigationTitle("Add to \(mealName)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onChange(of: searchText) { _, newValue in
            searchTask?.cancel()
            if newValue.isEmpty {
                searchResults = []
                isSearching = false
                return
            }
            isSearching = true
            searchTask = Task {
                try? await Task.sleep(nanoseconds: 400_000_000)
                guard !Task.isCancelled else { return }
                do {
                    let results = try await USDAService.shared.searchFoods(query: newValue)
                    guard !Task.isCancelled else { return }
                    await MainActor.run {
                        searchResults = results
                        isSearching = false
                    }
                } catch {
                    guard !Task.isCancelled else { return }
                    await MainActor.run {
                        searchResults = []
                        isSearching = false
                    }
                }
            }
        }
    }

    private func addCustomMealEntries(_ meal: CustomMeal) {
        for item in meal.items {
            guard let food = item.foodItem else { continue }
            let entry = MealEntry(
                date: logDate,
                mealType: mealName,
                servingGrams: item.servingGrams,
                foodItem: food
            )
            modelContext.insert(entry)
        }
        dismiss()
    }

    private func deleteCustomMeal(_ meal: CustomMeal) {
        modelContext.delete(meal)
    }

}

// MARK: - Subcomponents

private extension AddFoodView {

    struct TabPicker: View {
        @Binding var selectedTab: Int

        var body: some View {
            HStack(spacing: 0) {
                TabButton(title: "Food", isSelected: selectedTab == 0) {
                    selectedTab = 0
                }
                TabButton(title: "Custom Meals", isSelected: selectedTab == 1) {
                    selectedTab = 1
                }
            }
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

    struct TabButton: View {
        let title: String
        let isSelected: Bool
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Text(title)
                    .foregroundColor(isSelected ? .black : AppColors.lightMacroTextColor)
                    .font(.custom(Fonts.interSemiBold, size: FontSize.md))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.lg)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.sm)
                            .fill(isSelected ? MacroColors.carbs : Color.clear)
                    )
            }
        }
    }

    struct FoodTabContent: View {
        @Binding var searchText: String
        let isSearching: Bool
        let searchResults: [USDAFoodResult]
        let recentFoods: [FoodItem]
        let yesterdayMealGroups: [(mealType: String, entries: [MealEntry])]
        let mealName: String
        let logDate: Date

        var body: some View {
            ScrollView {
                VStack(spacing: Spacing.xl) {
                    SearchBar(searchText: $searchText)
                    ScanBarcodeButton()

                    if isSearching {
                        SwiftUI.ProgressView()
                            .tint(.white)
                            .padding(.vertical, Spacing.xxl)
                    } else if !searchText.isEmpty {
                        SearchResultsSection(results: searchResults, mealName: mealName, logDate: logDate)
                    } else {
                        RecentSection(recentFoods: recentFoods, mealName: mealName, logDate: logDate)
                        YesterdaySection(mealGroups: yesterdayMealGroups, mealName: mealName, logDate: logDate)
                    }
                }
                .padding()
            }
        }
    }

    struct CustomMealsTabContent: View {
        let customMeals: [CustomMeal]
        let mealName: String
        let logDate: Date
        let onAddMeal: (CustomMeal) -> Void
        let onDeleteMeal: (CustomMeal) -> Void

        var body: some View {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    if customMeals.isEmpty {
                        VStack(spacing: Spacing.lg) {
                            Image(systemName: "tray")
                                .font(.system(size: 32))
                                .foregroundColor(AppColors.lightMacroTextColor)
                            Text("No custom meals yet")
                                .foregroundColor(AppColors.lightMacroTextColor)
                                .font(.custom(Fonts.interRegular, size: FontSize.lg))
                            Text("Save a meal from any meal card using the ··· button")
                                .foregroundColor(AppColors.lightMacroTextColor)
                                .font(.custom(Fonts.interRegular, size: FontSize.sm))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, Spacing.xxl)
                    } else {
                        ForEach(customMeals) { meal in
                            CustomMealRow(meal: meal, onAdd: { onAddMeal(meal) }, onDelete: { onDeleteMeal(meal) })
                        }
                    }
                }
                .padding()
            }
        }
    }

    struct CustomMealRow: View {
        let meal: CustomMeal
        let onAdd: () -> Void
        let onDelete: () -> Void

        private var totalCalories: Int {
            Int(meal.items.reduce(0) { $0 + $1.calories })
        }

        private var totalProtein: Int {
            Int(meal.items.reduce(0) { $0 + $1.protein })
        }

        private var totalCarbs: Int {
            Int(meal.items.reduce(0) { $0 + $1.carbs })
        }

        private var totalFat: Int {
            Int(meal.items.reduce(0) { $0 + $1.fat })
        }

        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack {
                    Text(meal.name)
                        .foregroundColor(.white)
                        .font(.custom(Fonts.interSemiBold, size: FontSize.xl))

                    Spacer()

                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: IconSize.lg))
                            .foregroundColor(AppColors.lightMacroTextColor)
                    }
                }

                Text("\(meal.items.count) item\(meal.items.count == 1 ? "" : "s")")
                    .foregroundColor(AppColors.lightMacroTextColor)
                    .font(.custom(Fonts.interRegular, size: FontSize.sm))

                ForEach(meal.items) { item in
                    HStack {
                        Text(item.foodItem?.name.capitalized ?? "Unknown")
                            .foregroundColor(AppColors.macroTextColor)
                            .font(.custom(Fonts.interRegular, size: FontSize.md))
                        Spacer()
                        Text("\(Int(item.servingGrams))g · \(Int(item.calories)) kcal")
                            .foregroundColor(AppColors.lightMacroTextColor)
                            .font(.custom(Fonts.interRegular, size: FontSize.sm))
                    }
                }

                HStack(spacing: Spacing.lg) {
                    HStack(spacing: Spacing.xs) {
                        Circle().fill(MacroColors.protein).frame(width: IconSize.md, height: IconSize.md)
                        Text("\(totalProtein)p")
                            .foregroundStyle(AppColors.lightMacroTextColor)
                            .font(.custom(Fonts.interRegular, size: FontSize.sm))
                    }
                    HStack(spacing: Spacing.xs) {
                        Circle().fill(MacroColors.carbs).frame(width: IconSize.md, height: IconSize.md)
                        Text("\(totalCarbs)c")
                            .foregroundStyle(AppColors.lightMacroTextColor)
                            .font(.custom(Fonts.interRegular, size: FontSize.sm))
                    }
                    HStack(spacing: Spacing.xs) {
                        Circle().fill(MacroColors.fats).frame(width: IconSize.md, height: IconSize.md)
                        Text("\(totalFat)f")
                            .foregroundStyle(AppColors.lightMacroTextColor)
                            .font(.custom(Fonts.interRegular, size: FontSize.sm))
                    }
                    Spacer()
                    Text("\(totalCalories) kcal")
                        .foregroundColor(AppColors.macroTextColor)
                        .font(.custom(Fonts.interRegular, size: FontSize.sm))
                }

                Button(action: onAdd) {
                    Text("Add to Meal")
                        .foregroundColor(.black)
                        .font(.custom(Fonts.interSemiBold, size: FontSize.md))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.lg)
                        .background(MacroColors.carbs)
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
                }
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

    struct SearchBar: View {
        @Binding var searchText: String

        var body: some View {
            HStack(spacing: Spacing.md) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppColors.macroTextColor)
                TextField("Search for a food...", text: $searchText)
                    .foregroundColor(.white)
                    .font(.custom(Fonts.interRegular, size: FontSize.lg))
                    .autocorrectionDisabled()
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppColors.macroTextColor)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.sm)
                    .stroke(MacroColors.carbs, lineWidth: CardStyle.borderWidth)
            )
        }
    }

    struct ScanBarcodeButton: View {
        var body: some View {
            HStack(spacing: Spacing.md) {
                Image(systemName: "barcode.viewfinder")
                    .foregroundColor(.white)
                Text("Scan Barcode")
                    .foregroundColor(.white)
                    .font(.custom(Fonts.interMedium, size: FontSize.lg))
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.sm)
                    .stroke(Color.white.opacity(CardStyle.borderOpacity), lineWidth: CardStyle.borderWidth)
            )
        }
    }

    struct SectionHeader: View {
        let title: String

        var body: some View {
            HStack(spacing: Spacing.md) {
                Image(systemName: "clock")
                    .foregroundColor(AppColors.macroTextColor)
                    .font(.system(size: IconSize.lg))
                Text(title)
                    .foregroundColor(AppColors.macroTextColor)
                    .font(.custom(Fonts.interMedium, size: FontSize.xs))
                    .tracking(1)
            }
        }
    }

    struct MacroBadge: View {
        let color: Color
        let value: String

        var body: some View {
            HStack(spacing: Spacing.xs) {
                Circle()
                    .fill(color)
                    .frame(width: IconSize.sm, height: IconSize.sm)
                Text(value)
                    .foregroundStyle(AppColors.macroTextColor)
                    .font(.custom(Fonts.interRegular, size: FontSize.xs))
            }
        }
    }

    struct SearchResultRow: View {
        let result: USDAFoodResult
        let mealName: String
        let logDate: Date

        var body: some View {
            NavigationLink(destination: AddEntryView(usdaResult: result, mealName: mealName, logDate: logDate)) {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text(result.name.capitalized)
                        .foregroundColor(.white)
                        .font(.custom(Fonts.interSemiBold, size: FontSize.lg))
                        .lineLimit(2)

                    if let brand = result.brand {
                        Text(brand)
                            .foregroundColor(AppColors.lightMacroTextColor)
                            .font(.custom(Fonts.interRegular, size: FontSize.xs))
                    }

                    HStack(spacing: Spacing.sm) {
                        Text("\(Int(result.caloriesPer100g)) kcal")
                            .foregroundColor(AppColors.macroTextColor)
                            .font(.custom(Fonts.interRegular, size: FontSize.xs))

                        MacroBadge(color: MacroColors.protein, value: "\(Int(result.proteinPer100g))p")
                        MacroBadge(color: MacroColors.carbs, value: "\(Int(result.carbsPer100g))c")
                        MacroBadge(color: MacroColors.fats, value: "\(Int(result.fatPer100g))f")

                        Text("|")
                            .foregroundColor(AppColors.macroTextColor)
                            .font(.custom(Fonts.interRegular, size: FontSize.xs))

                        Text("per 100g")
                            .foregroundColor(AppColors.macroTextColor)
                            .font(.custom(Fonts.interRegular, size: FontSize.xs))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
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

    struct SearchResultsSection: View {
        let results: [USDAFoodResult]
        let mealName: String
        let logDate: Date

        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                SectionHeader(title: "SEARCH RESULTS")

                if results.isEmpty {
                    Text("No results found")
                        .foregroundColor(AppColors.lightMacroTextColor)
                        .font(.custom(Fonts.interRegular, size: FontSize.md))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.xxl)
                } else {
                    ForEach(results) { result in
                        SearchResultRow(result: result, mealName: mealName, logDate: logDate)
                    }
                }
            }
        }
    }

    struct RecentFoodRow: View {
        let food: FoodItem
        let mealName: String
        let logDate: Date

        var body: some View {
            NavigationLink(destination: AddEntryView(foodItem: food, mealName: mealName, logDate: logDate)) {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text(food.name.capitalized)
                        .foregroundColor(.white)
                        .font(.custom(Fonts.interSemiBold, size: FontSize.lg))

                    HStack(spacing: Spacing.sm) {
                        Text("\(Int(food.caloriesPer100g)) kcal")
                            .foregroundColor(AppColors.macroTextColor)
                            .font(.custom(Fonts.interRegular, size: FontSize.xs))

                        MacroBadge(color: MacroColors.protein, value: "\(Int(food.proteinPer100g))p")
                        MacroBadge(color: MacroColors.carbs, value: "\(Int(food.carbsPer100g))c")
                        MacroBadge(color: MacroColors.fats, value: "\(Int(food.fatPer100g))f")

                        Text("|")
                            .foregroundColor(AppColors.macroTextColor)
                            .font(.custom(Fonts.interRegular, size: FontSize.xs))

                        Text("per 100g")
                            .foregroundColor(AppColors.macroTextColor)
                            .font(.custom(Fonts.interRegular, size: FontSize.xs))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
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

    struct RecentSection: View {
        let recentFoods: [FoodItem]
        let mealName: String
        let logDate: Date

        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                SectionHeader(title: "RECENT")

                if recentFoods.isEmpty {
                    Text("No recent foods")
                        .foregroundColor(AppColors.lightMacroTextColor)
                        .font(.custom(Fonts.interRegular, size: FontSize.md))
                        .padding(.vertical, Spacing.lg)
                } else {
                    ForEach(recentFoods) { food in
                        RecentFoodRow(food: food, mealName: mealName, logDate: logDate)
                    }
                }
            }
        }
    }

    struct YesterdayMealRow: View {
        let mealType: String
        let entries: [MealEntry]
        let mealName: String
        let logDate: Date

        private var totalCalories: Int {
            Int(entries.reduce(0) { $0 + $1.calories })
        }

        var body: some View {
            NavigationLink(destination: ReviewMealEntriesView(
                mealName: mealName,
                sourceMealType: mealType,
                logDate: logDate,
                entries: entries
            )) {
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text(mealType)
                            .foregroundColor(.white)
                            .font(.custom(Fonts.interSemiBold, size: FontSize.lg))
                        Text("\(entries.count) item\(entries.count == 1 ? "" : "s") \u{2022} \(totalCalories) kcal")
                            .foregroundColor(AppColors.macroTextColor)
                            .font(.custom(Fonts.interRegular, size: FontSize.xs))
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(AppColors.macroTextColor)
                        .font(.system(size: IconSize.lg))
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

    struct YesterdaySection: View {
        let mealGroups: [(mealType: String, entries: [MealEntry])]
        let mealName: String
        let logDate: Date

        var body: some View {
            if !mealGroups.isEmpty {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    SectionHeader(title: "YESTERDAY'S MEALS")

                    ForEach(mealGroups, id: \.mealType) { group in
                        YesterdayMealRow(mealType: group.mealType, entries: group.entries, mealName: mealName, logDate: logDate)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AddFoodView(mealName: "Lunch")
    }
}
