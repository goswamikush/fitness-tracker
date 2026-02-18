//
//  AddFoodView.swift
//  FitnessTracker
//
//  Created by Kush Goswami on 2/14/26.
//

import SwiftUI
import SwiftData

struct AddFoodView: View {
    let mealName: String
    @State private var searchText = ""
    @State private var searchResults: [USDAFoodResult] = []
    @State private var isSearching = false
    @State private var searchTask: Task<Void, Never>?
    @Query(sort: \MealEntry.date, order: .reverse) private var allEntries: [MealEntry]

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
                    SearchResultsSection(results: searchResults, mealName: mealName)
                } else {
                    RecentSection(recentFoods: recentFoods, mealName: mealName)
                    YesterdaySection()
                }
            }
            .padding()
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
}

// MARK: - Subcomponents

private extension AddFoodView {

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

        var body: some View {
            NavigationLink(destination: AddEntryView(usdaResult: result, mealName: mealName)) {
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
                        SearchResultRow(result: result, mealName: mealName)
                    }
                }
            }
        }
    }

    struct RecentFoodRow: View {
        let food: FoodItem
        let mealName: String

        var body: some View {
            NavigationLink(destination: AddEntryView(foodItem: food, mealName: mealName)) {
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
                        RecentFoodRow(food: food, mealName: mealName)
                    }
                }
            }
        }
    }

    struct YesterdayMealRow: View {
        let mealName: String
        let itemCount: String
        let calories: String

        var body: some View {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text(mealName)
                        .foregroundColor(.white)
                        .font(.custom(Fonts.interSemiBold, size: FontSize.lg))
                    Text("\(itemCount) items \u{2022} \(calories) kcal")
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

    struct YesterdaySection: View {
        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                SectionHeader(title: "YESTERDAY'S MEALS")

                YesterdayMealRow(mealName: "Lunch", itemCount: "2", calories: "545")
                YesterdayMealRow(mealName: "Breakfast", itemCount: "2", calories: "425")
                YesterdayMealRow(mealName: "Dinner", itemCount: "2", calories: "625")
            }
        }
    }
}

#Preview {
    NavigationStack {
        AddFoodView(mealName: "Lunch")
    }
}
