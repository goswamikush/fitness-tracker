//
//  AddFoodView.swift
//  FitnessTracker
//
//  Created by Kush Goswami on 2/14/26.
//

import SwiftUI

struct AddFoodView: View {
    let mealName: String

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                SearchBar()
                ScanBarcodeButton()
                RecentSection()
                YesterdaySection()
            }
            .padding()
        }
        .background(AppColors.background)
        .navigationTitle("Add to \(mealName)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

// MARK: - Subcomponents

private extension AddFoodView {

    struct SearchBar: View {
        var body: some View {
            HStack(spacing: Spacing.md) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppColors.macroTextColor)
                Text("Search for a food...")
                    .foregroundColor(AppColors.macroTextColor)
                    .font(.custom(Fonts.interRegular, size: FontSize.lg))
                Spacer()
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

    struct RecentFoodRow: View {
        let name: String
        let calories: String
        let protein: String
        let carbs: String
        let fats: String
        let serving: String

        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text(name)
                    .foregroundColor(.white)
                    .font(.custom(Fonts.interSemiBold, size: FontSize.lg))

                HStack(spacing: Spacing.sm) {
                    Text(calories)
                        .foregroundColor(AppColors.macroTextColor)
                        .font(.custom(Fonts.interRegular, size: FontSize.xs))

                    MacroBadge(color: MacroColors.protein, value: protein)
                    MacroBadge(color: MacroColors.carbs, value: carbs)
                    MacroBadge(color: MacroColors.fats, value: fats)

                    Text("|")
                        .foregroundColor(AppColors.macroTextColor)
                        .font(.custom(Fonts.interRegular, size: FontSize.xs))

                    Text(serving)
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

    struct RecentSection: View {
        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                SectionHeader(title: "RECENT")

                RecentFoodRow(name: "Almonds", calories: "164 kcal", protein: "6p", carbs: "6c", fats: "14f", serving: "1 oz")
                RecentFoodRow(name: "Protein Bar", calories: "200 kcal", protein: "20p", carbs: "22c", fats: "7f", serving: "1 bar")
                RecentFoodRow(name: "Cottage Cheese", calories: "110 kcal", protein: "12p", carbs: "5c", fats: "4f", serving: "1/2 cup")
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
