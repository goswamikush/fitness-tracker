//
//  MealCard.swift
//  FitnessTracker
//
//  Created by Kush Goswami on 2/2/26.
//

import SwiftUI
import SwiftData

struct MealCard: View {
    @Environment(\.modelContext) private var modelContext
    let mealName: String
    let entries: [MealEntry]
    var logDate: Date = Date()
    @State private var isExpanded = true

    private var isEmpty: Bool { entries.isEmpty }

    private var totalCalories: Int {
        Int(entries.reduce(0) { $0 + $1.calories })
    }

    private var totalProtein: Int {
        Int(entries.reduce(0) { $0 + $1.protein })
    }

    private var totalCarbs: Int {
        Int(entries.reduce(0) { $0 + $1.carbs })
    }

    private var totalFat: Int {
        Int(entries.reduce(0) { $0 + $1.fat })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            if isEmpty {
                EmptyContent(mealName: mealName, logDate: logDate, isExpanded: $isExpanded)
            } else if isExpanded {
                ExpandedContent(mealName: mealName, logDate: logDate, entries: entries, totalCalories: totalCalories, totalProtein: totalProtein, totalCarbs: totalCarbs, totalFat: totalFat, isExpanded: $isExpanded, onDelete: deleteEntry)
            } else {
                CollapsedContent(mealName: mealName, logDate: logDate, entries: entries, totalCalories: totalCalories, totalProtein: totalProtein, totalCarbs: totalCarbs, totalFat: totalFat, isExpanded: $isExpanded)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .fill(CardStyle.fillColor.opacity(CardStyle.fillOpacity))
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.sm)
                        .stroke(Color.white.opacity(CardStyle.borderOpacity), lineWidth: CardStyle.borderWidth)
                )
        )
        .clipped()
        .animation(.easeInOut(duration: 0.25), value: isExpanded)
    }

    private func deleteEntry(_ entry: MealEntry) {
        modelContext.delete(entry)
    }
}

// MARK: - Subcomponents

private extension MealCard {

    struct EmptyContent: View {
        let mealName: String
        let logDate: Date
        @Binding var isExpanded: Bool

        var body: some View {
            VStack(spacing: Spacing.xl) {
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text(mealName)
                            .foregroundStyle(.white)
                            .font(.custom(Fonts.outfitSemiBold, size: FontSize.xl))
                        Text("No food logged")
                            .foregroundStyle(AppColors.lightMacroTextColor)
                            .font(.custom(Fonts.interRegular, size: FontSize.sm))
                    }

                    Spacer()

                    HStack(spacing: Spacing.xl) {
                        NavigationLink(destination: AddFoodView(mealName: mealName, logDate: logDate)) {
                            Image(systemName: "plus")
                                .font(.system(size: IconSize.lg, weight: .medium))
                                .foregroundColor(AppColors.macroTextColor)
                        }

                        Button {
                            isExpanded.toggle()
                        } label: {
                            Image(systemName: "chevron.up")
                                .font(.system(size: IconSize.lg, weight: .medium))
                                .foregroundColor(AppColors.macroTextColor)
                        }
                    }
                }

                NavigationLink(destination: AddFoodView(mealName: mealName, logDate: logDate)) {
                    Text("Tap + to add food")
                        .foregroundStyle(AppColors.lightMacroTextColor)
                        .font(.custom(Fonts.interRegular, size: FontSize.md))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.lg)
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.sm)
                                .stroke(style: StrokeStyle(lineWidth: 1, dash: [6]))
                                .foregroundStyle(Color.white.opacity(0.15))
                        )
                }
            }
        }
    }

    struct ExpandedContent: View {
        let mealName: String
        let logDate: Date
        let entries: [MealEntry]
        let totalCalories: Int
        let totalProtein: Int
        let totalCarbs: Int
        let totalFat: Int
        @Binding var isExpanded: Bool
        let onDelete: (MealEntry) -> Void

        var body: some View {
            VStack(spacing: 0) {
                ExpandedHeader(mealName: mealName, logDate: logDate, entries: entries, totalCalories: totalCalories, isExpanded: $isExpanded)
                    .padding(.bottom, Spacing.md)

                List {
                    ForEach(entries) { entry in
                        FoodItemRow(
                            name: entry.foodItem?.name ?? "Unknown",
                            calories: Int(entry.calories),
                            protein: Int(entry.protein),
                            carbs: Int(entry.carbs),
                            fat: Int(entry.fat),
                            servingDisplay: entry.servingDisplay
                        )
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 16))
                        .listRowSeparator(.hidden)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                withAnimation {
                                    onDelete(entry)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.red)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .frame(height: CGFloat(entries.count) * 56)
                .scrollDisabled(true)

                Footer(totalCalories: totalCalories, totalProtein: totalProtein, totalCarbs: totalCarbs, totalFat: totalFat)
            }
        }
    }

    struct CollapsedContent: View {
        let mealName: String
        let logDate: Date
        let entries: [MealEntry]
        let totalCalories: Int
        let totalProtein: Int
        let totalCarbs: Int
        let totalFat: Int
        @Binding var isExpanded: Bool

        var body: some View {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(mealName)
                        .foregroundStyle(.white)
                        .font(.custom(Fonts.outfitSemiBold, size: FontSize.xl))
                    Text("\(entries.count) item\(entries.count == 1 ? "" : "s")")
                        .foregroundStyle(AppColors.lightMacroTextColor)
                        .font(.custom(Fonts.interRegular, size: FontSize.sm))
                }

                Spacer()

                HStack(spacing: Spacing.lg) {
                    HStack(spacing: Spacing.xs) {
                        Circle()
                            .fill(MacroColors.protein)
                            .frame(width: IconSize.md, height: IconSize.md)
                        Text("\(totalProtein)p")
                            .foregroundStyle(AppColors.lightMacroTextColor)
                            .font(.custom(Fonts.interRegular, size: FontSize.sm))
                    }

                    HStack(spacing: Spacing.xs) {
                        Circle()
                            .fill(MacroColors.carbs)
                            .frame(width: IconSize.md, height: IconSize.md)
                        Text("\(totalCarbs)c")
                            .foregroundStyle(AppColors.lightMacroTextColor)
                            .font(.custom(Fonts.interRegular, size: FontSize.sm))
                    }

                    HStack(spacing: Spacing.xs) {
                        Circle()
                            .fill(MacroColors.fats)
                            .frame(width: IconSize.md, height: IconSize.md)
                        Text("\(totalFat)f")
                            .foregroundStyle(AppColors.lightMacroTextColor)
                            .font(.custom(Fonts.interRegular, size: FontSize.sm))
                    }

                    Text("\(totalCalories) kcal")
                        .foregroundStyle(AppColors.lightMacroTextColor)
                        .font(.custom(Fonts.interRegular, size: FontSize.sm))

                    NavigationLink(destination: AddFoodView(mealName: mealName, logDate: logDate)) {
                        Image(systemName: "plus")
                            .font(.system(size: IconSize.lg, weight: .medium))
                            .foregroundColor(AppColors.macroTextColor)
                    }

                    NavigationLink(destination: SaveCustomMealView(mealName: mealName, entries: entries)) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: IconSize.lg, weight: .medium))
                            .foregroundColor(AppColors.macroTextColor)
                    }

                    Button {
                        isExpanded.toggle()
                    } label: {
                        Image(systemName: "chevron.down")
                            .font(.system(size: IconSize.lg, weight: .medium))
                            .foregroundColor(AppColors.macroTextColor)
                    }
                }
            }
        }
    }

    struct ExpandedHeader: View {
        let mealName: String
        let logDate: Date
        let entries: [MealEntry]
        let totalCalories: Int
        @Binding var isExpanded: Bool

        var body: some View {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text(mealName)
                        .foregroundStyle(.white)
                        .font(.custom(Fonts.outfitSemiBold, size: FontSize.xl))

                    Text("\(totalCalories) kcal")
                        .foregroundStyle(AppColors.macroTextColor)
                        .font(.custom(Fonts.interMedium, size: FontSize.sm))
                }

                Spacer()

                HStack(spacing: Spacing.xl) {
                    NavigationLink(destination: AddFoodView(mealName: mealName, logDate: logDate)) {
                        Image(systemName: "plus")
                            .font(.system(size: IconSize.lg, weight: .medium))
                            .foregroundColor(AppColors.macroTextColor)
                    }

                    NavigationLink(destination: SaveCustomMealView(mealName: mealName, entries: entries)) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: IconSize.lg, weight: .medium))
                            .foregroundColor(AppColors.macroTextColor)
                    }

                    Button {
                        isExpanded.toggle()
                    } label: {
                        Image(systemName: "chevron.up")
                            .font(.system(size: IconSize.lg, weight: .medium))
                            .foregroundColor(AppColors.macroTextColor)
                    }
                }
            }
        }
    }

    struct Footer: View {
        let totalCalories: Int
        let totalProtein: Int
        let totalCarbs: Int
        let totalFat: Int

        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                Divider()
                    .overlay(AppColors.macroTextColor.opacity(Opacity.divider))
                HStack {
                    HStack(spacing: Spacing.lg) {
                        HStack(spacing: Spacing.xs) {
                            Circle()
                                .fill(MacroColors.protein)
                                .frame(width: IconSize.md, height: IconSize.md)
                            Text("\(totalProtein)p")
                                .foregroundStyle(AppColors.lightMacroTextColor)
                                .font(.custom(Fonts.interRegular, size: FontSize.sm))
                        }

                        HStack(spacing: Spacing.xs) {
                            Circle()
                                .fill(MacroColors.carbs)
                                .frame(width: IconSize.md, height: IconSize.md)
                            Text("\(totalCarbs)c")
                                .foregroundStyle(AppColors.lightMacroTextColor)
                                .font(.custom(Fonts.interRegular, size: FontSize.sm))
                        }

                        HStack(spacing: Spacing.xs) {
                            Circle()
                                .fill(MacroColors.fats)
                                .frame(width: IconSize.md, height: IconSize.md)
                            Text("\(totalFat)f")
                                .foregroundStyle(AppColors.lightMacroTextColor)
                                .font(.custom(Fonts.interRegular, size: FontSize.sm))
                        }
                    }

                    Spacer()

                    Text("\(totalCalories) cal")
                        .foregroundStyle(AppColors.lightMacroTextColor)
                        .font(.custom(Fonts.interRegular, size: FontSize.sm))
                }
            }
        }
    }
}

#Preview {
    ZStack {
        AppColors.background
            .ignoresSafeArea()

        NavigationStack {
            VStack(alignment: .leading, spacing: 8) {
                MealCard(mealName: "Dinner", entries: [], logDate: Date())
            }
            .padding()
        }
    }
}
